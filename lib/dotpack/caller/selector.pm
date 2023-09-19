package dotpack::caller::selector;

use strict;

use dotpack::caller::selector::basic;
use dotpack::caller::selector::drhook;

sub new
{
  my $class = shift;
  my %opts = @_;
  $class = 'dotpack::caller::selector::' . $opts{selector};
  my $self = $class->new (%opts);
  return $self;
}

1;
