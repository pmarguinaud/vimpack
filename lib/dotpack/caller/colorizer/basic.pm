package dotpack::caller::colorizer::basic;

use strict;
use Data::Dumper;

sub new
{
  my $class = shift;
  my %opts = @_;
  my $self = bless \%opts, $class;

  for my $k (qw (color-map))
    {
      $self->{$k} = {split (m/,/o, $self->{$k})};
    }
  
  return $self;
}

sub color
{
  my ($self, %opts) = @_;
  my $name = $opts{name};
  my $graph = $opts{graph};
  if (my $color = $self->{'color-map'}{$name})
    {
      return (style => 'filled', fillcolor => $color, color => 'black');
    }
  return ();
}

sub getopts
{
  shift;
  my %args = @_;
  push @{$args{opts_s}}, qw (color-map);
  $args{opts}{'color-map'} = '';
}


1;
