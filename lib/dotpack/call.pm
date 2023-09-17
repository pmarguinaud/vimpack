package dotpack::call;

use strict;
use Data::Dumper;
use FileHandle;
use File::Basename;
use File::Find;

my %data;

sub slurp
{
  my ($file, $discard) = @_;

  unless (exists $data{$file})
    {
      my $fh = 'FileHandle'->new ("<$file");
      local $/ = undef;
      $data{$file} = <$fh>;
    }

  return delete ($data{$file}) if ($discard);

  return $data{$file};
}

sub scan
{
  shift;

  my %f2f;
  my %seen;
  
  my $wanted = sub
  {
    return unless (m/\.F90$/o);
    my $f = $File::Find::name;
    return if ($seen{&basename ($f)}++);
    my $code = &slurp ($f, 1);
    my ($s) = ($code =~ m/(?:MODULE|FUNCTION|PROGRAM|SUBROUTINE)[ ]+(\w+)/goms);
    return unless ($s);
    $s = uc ($s);
    $f2f{$s} = $f;
  };
  
  my @view = do { my $fh = 'FileHandle'->new ("<.gmkview"); my @v = <$fh>; chomp for (@v); @v };
  
  if (-f 'f2f.pl')
    {
      %f2f = %{ do ('./f2f.pl') };
      pop (@view) while (scalar (@view) > 1);
    }
  
  for my $view (@view)
    {
      &find ({wanted => $wanted, no_chdir => 1}, "src/$view/");
    }
  
  'FileHandle'->new (">f2f.pl")->print (&Dumper (\%f2f));

  return \%f2f;
}


my %call;

sub call
{
  shift;

  my $file = shift;

  unless (exists $call{$file})
    {
      my $code = uc (&slurp ($file));
      my @code = grep { !/^\s*!/o } split (m/\n/o, $code);
      $code = join (" ; ", @code);

      my @call = ($code =~ m/\bCALL\s+(\S+)/goms);

      for (@call)
        {
          s/\&.*//o;
          s/\(.*//o;
        }


      $call{$file} = \@call;
    }

  return $call{$file};
}

my %size;

sub size
{
  shift;

  my $file = shift;
  
  die $file unless (-f $file);

  unless (exists $size{$file})
    {
      my @code = do { my $fh = 'FileHandle'->new ("<$file"); <$fh> };
      $size{$file} = scalar (@code);
    }

  return $size{$file};
}

1;
