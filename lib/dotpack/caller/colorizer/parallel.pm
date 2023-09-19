package dotpack::caller::colorizer::parallel;

use strict;

use base qw (dotpack::caller::colorizer::basic);

sub color
{
  my ($self, %opts) = @_;
  my $name = $opts{name};
  my $graph = $opts{graph};
  
  if ($graph->{"${name}_OPENACC"})
    {
      return (style => 'filled', fillcolor => 'green', color => 'black');
    }
  elsif ($graph->{"${name}_OPENACC"})
    {
      return (style => 'filled', fillcolor => 'red', color => 'black');
    }

  return $self->SUPER::color (%opts);
}


1;
