package vimpack::file;

use strict;

sub new
{
  my ($class, %args) = @_;

  my $self;

  if ('vimpack::file'->issrc ($args{file}))
    {
      use vimpack::source;
      $self = 'vimpack::source'->new (%args);
    } 
  elsif ('vimpack::file'->issearch ($args{file}))
    {
      use vimpack::search;
      $self = 'vimpack::search'->new (%args);
    }
  else
    {
      $self = bless { @_ }, $class;
    }

  return $self;
}

sub issrc
{

# check if file is a source code file

  my ($self, $file) = @_;

  if (ref ($self) && (! $file))
    {
      $file = $self->{file};
    }
  
  return $file =~ m/(?:^jet|src=)/o;
# return (ref ($self) ? $self->{file} : $file) !~ m/search=/o;
}

sub issearch
{

# check if file is a search result

  my ($self, $file) = @_;

  if (ref ($self) && (! $file))
    {
      $file = $self->{file};
    }

  return $file =~ m/search=/o;
# return (ref ($self) ? $self->{file} : $file) =~ m/search=/o;
}

sub do_edit
{

}

sub do_commit
{

}

sub do_find
{

}

1;
