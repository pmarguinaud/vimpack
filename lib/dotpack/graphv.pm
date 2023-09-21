package dotpack::graphv;

use strict;

use dotpack::caller;

sub new
{
  my $class = shift;
  my %opts = @_;
  ($class = $opts{class}) or die;
  $class = 'dotpack::' . $class;
  my $self = $class->new (%opts);
  return $self;
}

sub getopts
{
  shift;
  my %args = @_;
  'dotpack::caller'->getopts (%args);
}

1;
