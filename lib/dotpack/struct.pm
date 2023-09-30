package dotpack::struct;

use strict;
use Data::Dumper;
use FileHandle;
use File::Basename;
use File::Find;
use List::MoreUtils qw (uniq);
use Storable;

#se dotpack::struct::selector;
#se dotpack::struct::colorizer;
#se dotpack::struct::content;

use base qw (dotpack::graphv);

sub new
{
  my $class = shift;
  my %opts = @_;
  my $self = bless {type => {}, %opts}, $class;

# $self->{selector}  = 'dotpack::struct::selector' ->new (%opts);
# $self->{colorizer} = 'dotpack::struct::colorizer'->new (%opts);
# $self->{content}   = 'dotpack::struct::content'  ->new (%opts);

  return $self;
}

sub getopts
{
  my $class = shift;

  my %args = @_;
  push @{$args{opts_s}}, qw (rankdir); # selector colorizer content);
  %{$args{opts}} = (%{$args{opts}}, 
                      qw (
                        rankdir    LR
                        ));
#                       selector   basic
#                       colorizer  basic
#                       content    basic
 
  $class->getsubopts ();
}

sub getMembers
{
  my ($self, $name) = @_;

  unless (exists $self->{type}{$name})
    {
      my $file = $self->{finder}->getFileFromType ($name);

      my $code = uc ($self->{finder}->getFileContent ($file));

      for ($code)
        {
          s/!.*//gom;
        }

      my @code = grep { !/^\s*!/o } split (m/\n/o, $code);

      my ($def, %def);

      for my $line (@code)
        {
          if ($line =~ m/^\s*TYPE\s*(?:,\s*PUBLIC\s*)?(?:,\s*EXTENDS\s*\(\s*\w+\s*\))?(?:\s*::)?\s*\b$name\s*$/ig)
            {
              $def = 1;
            }
          elsif ($line =~ m/^\s*END\s*TYPE\s*/ig)
            {
              $def = 0;
            }
          elsif ($def)
            {
              my $type;
              if ($line =~ s/^\s*(LOGICAL|REAL|INTEGER|CHARACTER|COMPLEX).*:://o)
                {
                  next;
                }
              elsif ($line =~ s/\s*(?:TYPE|CLASS)\s*\(\s*(\w+)\s*\).*:://o)
                {
                  $type = uc ($1);
                }
              else
                {
                  next;
                }

              my @memb = ($line =~ m/\b(\w+)\b/goms);
              for my $memb (@memb)
                {
                  $memb = uc ($memb);
                  $def{$memb} = $type;
                }
            }
        }  

      $self->{type}{$name} = [&uniq (values (%def))];

    }

  return $self->{type}{$name};
}

sub createGraph
{
  my ($self, @name) = @_;

  $self->{graph} = {};

  while (my $name = shift (@name))
    {
      next if ($self->{graph}{$name});

      my $memb = $self->getMembers ($name);
      
      $self->{graph}{$name} = $memb;

      push @name, grep { ! $self->{graph}{$_} } @$memb;
    }

  $self->{graph0} = &Storable::dclone ($self->{graph});
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
#     next if ($self->{selector}->skip ($k));

      $g->add_node 
        (
          name => $k, shape => 'box', 
#         label => $self->{content}->label (name => $k, finder => $self->{finder}), 
#         $self->{colorizer}->color (name => $k, graph => $self->{graph0}, finder => $self->{finder})
        );
      for my $v (@$v)
        {   
#         next if ($self->{selector}->skip ($v));
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

# $self->{selector}->filter ($self->{graph}, @unit);

  $self->renderGraph ();
}

1;
