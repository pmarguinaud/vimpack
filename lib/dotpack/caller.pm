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
  my %opts = @_;
  my $self = bless {call => {}, %opts}, $class;
  $self->{skip} = {map { ($_, 1) } split (m/,/o, $opts{skip})};
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
  my ($self, $name) = @_;
  return $self->{skip}{$name};
}

sub createGraph
{
  my ($self, @unit) = @_;

  $self->{graph} = {};

  while (my $unit = shift (@unit))
    {
      next if ($self->{graph}{$unit});

      my $call = $self->getCallees ($unit);
      
      $self->{graph}{$unit} = $call;

      push @unit, grep { ! $self->{graph}{$_} } @$call;
    }

}

sub renderGraph
{
  my $self = shift;

  my $g = 'GraphViz2'->new 
  (
    graph => {rankdir => $self->{rankdir}, ordering => 'out'}, 
    global => {rank => 'source'},
  );

  while (my ($k, $v) = each (%{ $self->{graph} }))
    {
      next if ($self->skip ($k));

      $g->add_node (name => $k, label => "$k", shape => 'box', $self->color ($k));
      for my $v (@$v)
        {   
          next if ($self->skip ($v));
          $g->add_edge (from => $k, to => $v);
        }   
    }
  
  my @root = keys (%{ $self->{graph} }); # Never called by any other routine belonging to the graph

  while (my ($k, $v) = each (%{ $self->{graph} }))
    {
      my %v = map { ($_, 1) } @$v;
      @root = grep { ! $v{$_} } @root;
    }

  my $root = join ('-', sort @root);
  $g->run (format => 'svg', output_file => "$root.svg");
}

sub graph
{
  my ($self, @unit) = @_;

  $self->createGraph (@unit);
  $self->renderGraph ();
}

1;
