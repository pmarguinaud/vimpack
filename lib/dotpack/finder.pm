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

1;
