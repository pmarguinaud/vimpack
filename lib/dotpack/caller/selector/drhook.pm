package dotpack::caller::selector::drhook;

use strict;

use base qw (dotpack::caller::selector::basic);

use drhook;

sub new
{
  my $class = shift;
  my %opts = @_;
  my $self = $class->SUPER::new (%opts);
  $self->{drhook} = &drhook::read ($self->{drhook});
  return $self;
}

sub skip
{
  my ($self, $unit) = @_;
  return ((! $self->{drhook}{$unit}) || $self->SUPER::skip ($unit));
}

sub filter
{
  my ($self, $graph, @unit) = @_;
  
  my %seen;

  my $walk;

  $walk = sub
  {
    my $k = shift;
    return if ($self->skip ($k));
    return if ($seen{$k}++);
    for my $v (@{ $graph->{$k} })
      {
        $walk->($v);
      }
  };

  $walk->($_) for (@unit);

  for my $k (keys (%{ $graph }))
    {
      next if ($seen{$k});
      delete $graph->{$k};
    }

}

1;
