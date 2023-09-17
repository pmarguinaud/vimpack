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
      $self->{f2f} = do ("./.dotpack.pl");
    }
  else
    {
      $self->scan ();
    }
  return $self;
}

sub scan
{
  my $self = shift;

  my %f2f;
  my %seen;
  
  my $wanted = sub
  {
    return unless (m/\.F90$/o);
    my $f = $File::Find::name;
    return if ($seen{&basename ($f)}++);
    my $code = $self->getFileContent ($f, 1);
    my ($s) = ($code =~ m/(?:MODULE|FUNCTION|PROGRAM|SUBROUTINE)[ ]+(\w+)/goms);
    return unless ($s);
    $s = uc ($s);
    $f2f{$s} = $f;
  };
  
  my @view = do { my $fh = 'FileHandle'->new ("<.gmkview"); my @v = <$fh>; chomp for (@v); @v };
  
  for my $view (@view)
    {
      &find ({wanted => $wanted, no_chdir => 1}, "src/$view/");
    }
  
  'FileHandle'->new (">.dotpack.pl")->print (&Dumper (\%f2f));

  $self->{f2f} = \%f2f;
}

sub getFileFromUnit
{
  my ($self, $name) = @_;
  return $self->{f2f}{$name};
}

1;