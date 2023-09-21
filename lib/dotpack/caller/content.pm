package dotpack::caller::content;

use strict;

use dotpack::caller::content::basic;

sub new
{
  my $class = shift;
  my %opts = @_;
  $class = 'dotpack::caller::content::' . $opts{content};
  my $self = $class->new (%opts);
  return $self;
}

sub getopts
{
  shift;
  my %opts = @_;

}


1;
