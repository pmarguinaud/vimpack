package dotpack::caller::colorizer;

use strict;

use dotpack::caller::colorizer::basic;
use dotpack::caller::colorizer::drhook;
use dotpack::caller::colorizer::parallel;

sub new
{
  my $class = shift;
  my %opts = @_;
  $class = 'dotpack::caller::colorizer::' . $opts{colorizer};
  my $self = $class->new (%opts);
  return $self;
}

1;
