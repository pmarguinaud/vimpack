package dotpack::struct::selector::basic;

use strict;

use base qw (dotpack::struct::selector);

sub new
{
  my $class = shift;
  my %opts = @_;
  my $self = bless \%opts, $class;
  $self->{skip} ||= '';
  $self->{skip} = {map { ($_, 1) } split (m/,/o, $opts{skip})};
  return $self;
}

sub skip
{
  my ($self, $name) = @_;
  return $self->{skip}{$name};
}

sub filter
{
  my ($self, $graph, @unit) = @_;

}

sub getopts
{
  shift;
  my %args = @_;

  push @{$args{opts_s}}, qw (skip);

}

1;
