package dotpack::pack;

use strict;
use Data::Dumper;
use FileHandle;
use File::Basename;
use File::Find;

use base qw (dotpack::finder);

sub new
{
  my $class = shift;
  my $self = bless {}, $class;

  if (-f ".dotpack.pl")
    {
      $self->{scan} = do ("./.dotpack.pl");
    }
  else
    {
      my @view = do { my $fh = 'FileHandle'->new ("<.gmkview"); my @v = <$fh>; chomp for (@v); @v };
      shift (@view);
      $self->{scan} = $self->scan (@view);
      'FileHandle'->new (">.dotpack.pl")->print (&Dumper ($self->{scan}));
    }

  my $scan = $self->scan ('local');

  $self->{scan}{f2f} = {%{ $self->{scan}{f2f} }, %{ $scan->{f2f} }};
  $self->{scan}{t2f} = {%{ $self->{scan}{t2f} }, %{ $scan->{t2f} }};

  return $self;
}


sub scan
{
  my ($self, @view) = @_;

  my ($f2f, $t2f) = ({}, {});

  my %seen;
  
  my $wanted = sub
  {
    return unless (m/\.F90$/o);
    my $file = $File::Find::name;
    return if ($seen{&basename ($file)}++);
    $self->scanFile ($file, $f2f, $t2f);
  };
  
  for my $view (@view)
    {
      &find ({wanted => $wanted, no_chdir => 1}, "src/$view/");
    }
  
  return {f2f => $f2f, t2f => $t2f};
}

1;
