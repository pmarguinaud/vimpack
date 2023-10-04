package dotpack::caller::colorizer::parallel;

use strict;
use Data::Dumper;

use base qw (dotpack::caller::colorizer::basic);

sub color
{
  my ($self, %opts) = @_;
  my $name = $opts{name};
  my $finder = $opts{finder};
  
  my @copts = $self->SUPER::color (%opts);

  @copts && return @copts;

  if ($finder->getFileFromUnit ("${name}_OPENACC"))
    {
      @copts = (style => 'filled', fillcolor => 'green', color => 'black');
    }
  elsif ($finder->getFileFromUnit ("${name}_PARALLEL"))
    {
      @copts = (style => 'filled', fillcolor => 'red', color => 'black');
    }

  return @copts;
}

sub getopts
{
  shift;
  my %args = @_;
}


1;
