package dotpack::struct::colorizer;

use strict;

use dotpack::struct::colorizer::basic;

sub new
{
  my $class = shift;
  my %opts = @_;
  $class = 'dotpack::struct::colorizer::' . $opts{colorizer};
  my $self = $class->new (%opts);
  return $self;
}

sub getopts
{
  shift;
  my %opts = @_;

}

1;
