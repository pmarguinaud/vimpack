package dotpack::caller;

use strict;
use Data::Dumper;
use FileHandle;
use File::Basename;
use File::Find;

use base qw (dotpack::graphv);

sub new
{
  my $class = shift;
  my $self = bless {call => {}, @_}, $class;
  return $self;
}

sub getCallees
{
  my ($self, $name) = @_;

  unless (exists $self->{call}{$name})
    {
      my $file = $self->{finder}->getFileFromUnit ($name);
      my $code = uc ($self->{finder}->getFileContent ($file));
      my @code = grep { !/^\s*!/o } split (m/\n/o, $code);
      $code = join (" ; ", @code);

      my @call = ($code =~ m/\bCALL\s+(\S+)/goms);

      for (@call)
        {
          s/\&.*//o;
          s/\(.*//o;
        }

      my %seen; 
      @call = grep { ! $seen{$_}++ } @call;

      $self->{call}{$name} = \@call;
    }

  return $self->{call}{$name};
}

sub color
{
}

sub skip
{

}

sub graph
{
  my $self = shift;

  my @unit = @_;

  my %g;

  while (my $unit = shift (@unit))
    {
      next if ($g{$unit});

      my $call = $self->getCallees ($unit);
      
      $g{$unit} = $call;

      push @unit, grep { ! $g{$_} } @$call;
    }

  my $g = 'GraphViz2'->new (graph => {rankdir => 'LR', ordering => 'out'}, global => {rank => 'source'});

  while (my ($k, $v) = each (%g))
    {
      next if ($self->skip ($k));

      $g->add_node (name => $k, label => "$k", shape => 'box', $self->color ($k));
      for my $v (@$v)
        {   
          next if ($self->skip ($k));
          $g->add_edge (from => $k, to => $v);
        }   
    }
  
  my @root = keys (%g); # Never called by any other routine belonging to the graph

  while (my ($k, $v) = each (%g))
    {
      my %v = map { ($_, 1) } @$v;
      @root = grep { ! $v{$_} } @root;
    }

  my $root = join ('-', sort @root);
  $g->run (format => 'svg', output_file => "$root.svg");

}

1;
