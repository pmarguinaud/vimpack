package dotpack::caller::colorizer::drhook;

use strict;

use base qw (dotpack::caller::colorizer::basic);

use drhook;

sub new
{  
  my $class = shift;
  my %opts = @_;
  my $self = $class->SUPER::new (%opts);
  $self->{drhook} = &drhook::read ($self->{drhook});
  return $self;
}

sub color
{
  my ($self, %opts) = @_;
  my $name = $opts{name};
  return $self->SUPER::color (%opts) unless ($self->{drhook}{$name});
  return (style => 'filled', fillcolor => 'red', color => 'black');
}

1;
