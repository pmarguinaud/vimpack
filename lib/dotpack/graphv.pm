package dotpack::graphv;

use strict;

use dotpack::caller;
use dotpack::drhook;

sub new
{
  my $class = shift;
  my %opts = @_;
  ($class = $opts{class}) or die;
  $class = 'dotpack::' . $class;
  my $self = $class->new (%opts);
  return $self;
}

1;
