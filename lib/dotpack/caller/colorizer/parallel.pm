package dotpack::caller::colorizer::parallel;

use strict;
use Data::Dumper;

use base qw (dotpack::caller::colorizer::basic);

sub color
{
  my ($self, %opts) = @_;
  my $name = $opts{name};
  my $finder = $opts{finder};
  
  if ($finder->getFileFromUnit ("${name}_OPENACC"))
    {
      return (style => 'filled', fillcolor => 'green', color => 'black');
    }
  elsif ($finder->getFileFromUnit ("${name}_PARALLEL"))
    {
      return (style => 'filled', fillcolor => 'red', color => 'black');
    }

  return $self->SUPER::color (%opts);
}

sub getopts
{
  shift;
  my %args = @_;
}


1;
