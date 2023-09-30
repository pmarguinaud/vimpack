package dotpack::finder;

use strict;
use dotpack::pack;

sub new
{
  my $class = shift;
  if (-f '.gmkview')
    {
      return 'dotpack::pack'->new ();
    }
  else
    {
      die;
    }
}

sub getFileFromUnit
{
  my ($self, $name) = @_;
  return $self->{scan}{f2f}{$name};
}

sub getFileFromType
{
  my ($self, $name) = @_;
  return $self->{scan}{t2f}{$name};
}

sub getUnitContent
{
  my ($self, $name) = @_;
  my $file = $self->getFileFromUnit ($name);
  return $self->getFileContent ($name);
}

sub getFileContent
{
  my ($self, $file, $discard) = @_;

  return '' unless ($file);

  unless (exists $self->{data}{$file})
    {
      my $fh = 'FileHandle'->new ("<$file");
      local $/ = undef;
      $self->{data}{$file} = <$fh>;
    }

  return delete ($self->{data}{$file}) if ($discard);

  return $self->{data}{$file};
}

sub getFileLineCount
{
  my $self = shift;
  my $file = shift;
  
  die $file unless (-f $file);

  unless (exists $self->{linecount}{$file})
    {
      my @code = do { my $fh = 'FileHandle'->new ("<$file"); <$fh> };
      $self->{linecount}{$file} = scalar (@code);
    }

  return $self->{linecount}{$file};
}

sub scanFile
{
  my ($self, $file, $f2f, $t2f) = @_;

  my $code = $self->getFileContent ($file, 1);

  for ($code)
    {
      s/!.*//gom;
    }

  my ($s) = ($code =~ m/(?:MODULE|FUNCTION|PROGRAM|SUBROUTINE)[ ]+(\w+)/igoms);
  if ($s)
    {
      $s = uc ($s);
      $f2f->{$s} = $file;
    }

  my @t = ($code =~ m/\n\s*TYPE\s*(?:,\s*PUBLIC\s*)?(?:,\s*EXTENDS\s*\(\s*\w+\s*\))?(?:\s*::)?\s*\b(\w+)\s*$/igom);

  for my $t (@t)
    {
      $t = uc ($t);
      $t2f->{$t} = $file;
    }

}

1;
