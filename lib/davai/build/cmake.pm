package davai::build::cmake;

use File::Basename;
use Data::Dumper;
use File::Path;
use Cwd;

use strict;

use base qw (davai::build);

sub getExecutablePath
{
  my ($self, $exec) = @_;

  if ($self->{executablePath}{$exec})
    {
      return $self->{executablePath}{$exec};
    }

  my @install = do 
  { 
    my $fh = 'FileHandle'->new ("<$self->{path}/build/install_manifest.txt")
          || 'FileHandle'->new ("<$self->{path}/install_manifest.txt");
    $fh ? <$fh>  : ()
  };

  chomp for (@install);

  # Use build directory if not installed

  unless (@install)
    {
      my $path = $self->{path};
      for my $bin (<$path/bin/*>)
        {
          push @install, $bin;
        }
    }

  for my $path (@install)
    {
      if ($exec eq &basename ($path))
        {
          $self->{executablePath}{$exec} = $path;
          return $path;
        }
    }

  die ("Executable $exec was not found in $self->{path}");
}

sub getInstallPath
{
  my $self = shift;
  my $path = $self->getExecutablePath ('MASTERODB');

  for (1 .. 2)
    {
      $path = &dirname ($path);
    }
 
  return $path;
}

sub getLabel
{
  my $self = shift;

  my @cmd = ('git', -C => $self->{path}, qw (branch --show-current));

  my $branch = `@cmd`;

  return $branch unless ($?);

  return &basename ($self->{path});
}

sub getVersion
{
  my $self = shift;
  return undef;
}

sub getIALGitDir
{
  my $self = shift;
  return "$self->{path}/../source/ial-source";
}

sub getIALGitFile
{
  my ($self, $file) = @_;
  return "$self->{path}/../source/ial-source/$file";
}

sub runGitCommand
{
  my $self = shift;

  my %args = @_;

  my @cmd = @{ ${args}{command} };
  unshift (@cmd, 'git', -C => $self->getIALGitDir ());

  print "@cmd\n" if ($args{verbose});

  my $out = `@cmd`;
  my $c = $?;
  $c && die ("Git command `@cmd' failed\n");

  return $out;
}

sub getBuilds
{
  my $self = shift;
  return ($self);
}

my %cmake2davai =
(
  ioassign                  => 'ioassign'                         ,
  'bator.x'                 => 'batodb'                           ,
  lfitools_dp               => 'lfitools'                         ,
  MASTERODB                 => 'masterodb'                        ,
  'ifs4dvar.DP'             => 'oopsbinary.ifs-oovar'             ,
  pgd_dp                    => 'buildpgd'                         ,
  prep_dp                   => 'prep'                             ,
  MASTERODB                 => 'ifsmodel.ifs'                     ,
  'TestSuiteVariational.DP' => 'oopsbinary.ifs-ootestcomponent'   ,
);
      
sub compileBinaries
{
  my $self = shift;
}

sub setBinaryLinks
{
  my $self = shift;

  my %args = @_;
  my ($nrv) = @args{qw (nrv)};

  my $pack = $self->{path};

  my $conf = &davai::getConf (nrv => $nrv);

  my ($compilation_flavour) = grep ({ $pack =~ m/$_$/ } @{ $conf->{compilation_flavours} });
  $compilation_flavour = lc ($compilation_flavour);
  
  my $mtoolroot = &davai::getMtoolRoot (conf => $conf);

  my @pack2bin = map ({ "$mtoolroot/${_}pack2bin.$compilation_flavour" } 
                 (
                  '',                  # old one
                  'build.gmkpack@',    # new one
                  'build@gmkpack.',    # new one
                 ));

  for my $pack2bin (@pack2bin)
    {
       &mkpath ($pack2bin);
      
       for my $bin (sort keys (%cmake2davai))
         {
           my $davaiLink = $cmake2davai{$bin};

           $davaiLink = "$pack2bin/$davaiLink.$conf->{executables_fmt}";

           die ("Missing `$pack/bin/$bin'") unless (-f "$pack/bin/$bin");
           my ($o, $t) = ("$pack/bin/$bin", $davaiLink);
           next if (-l $t);
           symlink ($o, $t) or die ("Cannot symlink $o -> $t");
           print "symlink $o -> $t\n" if ($args{verbose});
         }
    }
  
}

1;
