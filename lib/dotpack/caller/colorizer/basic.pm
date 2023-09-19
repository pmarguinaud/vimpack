package dotpack::caller::colorizer::basic;

use strict;

sub new
{
  my $class = shift;
  my %opts = @_;
  my $self = bless \%opts, $class;
  return $self;
}

sub color
{
  my ($self, %opts) = @_;
  my $name = $opts{name};
  return ();
}


1;
