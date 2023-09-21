package dotpack::caller::content::basic;

use strict;

sub new
{
  my $class = shift;
  my %opts = @_;
  my $self = bless \%opts, $class;
  return $self;
}

sub label
{
  my ($self, %opts) = @_;
  my $name = $opts{name};
  my $finder = $opts{finder};
  
  my $file = $finder->getFileFromUnit ($name);

  return $name unless ($file);

  my $line = $finder->getFileLineCount ($file);

  return "$name\n$line";
}

sub getopts
{
  shift;
  my %opts = @_;

}


1;
