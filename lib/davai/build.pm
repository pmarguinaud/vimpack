package davai::build;

use strict;
use Cwd;

use davai::build::pack;
use davai::build::cmake;

sub new
{
  my $class = shift;
  my %args = @_;

  $args{path} ||= &cwd ();
  $args{path} = 'File::Spec'->rel2abs ($args{path});

  if ($class eq __PACKAGE__)
    {
      if (-f "$args{path}/.genesis")
        {
          $class = 'davai::build::pack';
        }
      elsif ((-f "$args{path}/install_manifest.txt") || (-f "$args{path}/CMakeCache.txt"))
        {
          $class = 'davai::build::cmake';
        }
      elsif (-f "$args{path}/build/install_manifest.txt")
        {
          $class = 'davai::build::cmake';
        }
      else
        {
          return;
        }
    }
  else
    {
      my $self = bless \%args, $class;
      $self->checkEnv ();
      return $self;
    }
  
  return $class->new (%args);
}

sub getPath
{
  my $self = shift;
  return $self->{path};
}

sub checkEnv
{

}

sub getBranch
{
  my $self = shift;
  chomp (my $branch = $self->runGitCommand (@_, command => [qw (rev-parse --abbrev-ref HEAD)]));
  return $branch;
}

sub getCommit
{
  my $self = shift;
  chomp (my $commit = $self->runGitCommand (@_, command => [qw (rev-parse HEAD)]));
  return $commit;
}

sub getBuilds
{
  my $self = shift;
  return ($self->{path});
}

1;
