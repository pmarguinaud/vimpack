package dotpack::struct::selector;

use strict;

use dotpack::struct::selector::basic;

sub new
{
  my $class = shift;
  my %opts = @_;
  $class = 'dotpack::struct::selector::' . $opts{selector};
  my $self = $class->new (%opts);
  return $self;
}

sub getopts
{
  shift;
  my %opts = @_;

}

1;
