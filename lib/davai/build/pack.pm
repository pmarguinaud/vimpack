package davai::build::pack;

use File::Basename;
use File::Path;
use Data::Dumper;
use Cwd;

use strict;

use base qw (davai::build);

sub runCommand
{
  my %args = @_;
  my @cmd = @{ ${args}{command} };

  print "@cmd\n" if ($args{verbose});

  system (@cmd) 
    and die ("Command `@cmd' failed\n");
}

sub getExecutablePath
{
  my ($self, $exec) = @_;
  return "$self->{path}/bin/$exec";
}

sub getLabel 
{
  my $self = shift;
  return &basename ($self->{path});
}

sub slurp
{
  my $f = shift;
  (my $fh = 'FileHandle'->new ("<$f")) or die ("Cannot open `$f'");
  local $/ =  undef; 
  my $text = <$fh>;
  return $text;
}

sub getGenesis
{
  my $self = shift;
  die unless (-f "$self->{path}/.genesis");
  chomp (my $genesis = &slurp ("$self->{path}/.genesis"));
  my @genesis = split (m/\s+/o, $genesis);
  return @genesis;
}

sub getCycle
{
  my $self = shift;
  my @genesis = $self->getGenesis ();
  for my $i (0 .. $#genesis)
    {
      return $genesis[$i+1] if ($genesis[$i] eq '-r');
    }
}

sub getVersion
{
  my $self = shift;
  my $cycle = $self->getCycle ();

  my %cycle2version =
  (
    '49t1' => 'CY49T1',
    '50'   => 'CY50',
  );

  return $cycle2version{$cycle} if ($cycle2version{$cycle});

  my $davai_default_version = '.gitpack/git/.davai_default_version';
  if (-f $davai_default_version)
    {
      my ($version) = do { my $fh = 'FileHandle'->new ("<$davai_default_version"); <$fh> };
      chomp ($version);
      return $version;
    }
}

sub getInstallPath
{
  my $self = shift;
  return $self->{path};
}

sub checkEnv
{
  my @PATH = split (m/:/o, $ENV{PATH});
  for my $PATH (@PATH)
    {
      my $gmkpack = "$PATH/gmkpack";
      goto FOUND if (-f $gmkpack && -x $gmkpack);
    }

  die ("gmkpack was not found in:\n" . join ("\n   ", '', @PATH, '', ''));
  
FOUND:
}

sub getIALGitDir
{
  my $self = shift;
  return "$self->{path}/.gitpack/git";
}

sub getIALGitFile
{
  my ($self, $file) = @_;
  return "$self->{path}/.gitpack/git/$file";
}

sub runGitCommand
{
  my $self = shift;

  my %args = @_;

  my @cmd = @{ ${args}{command} };
  unshift (@cmd, 'gitpack');

  print "@cmd\n" if ($args{verbose});

  my $out = `@cmd`;
  my $c = $?;
  $c && die ("Gitpack command `@cmd' failed\n");

  return $out;
}

sub getBuilds
{
  my $self = shift;

  my %args = @_;
  my ($nrv) = @args{qw (nrv)};

  my $pack = $self->{path};

  my $conf = &davai::getConf (nrv => $nrv);

  for my $flavour (@{ $conf->{compilation_flavours} })
    {
      $pack =~ s/$flavour$//;
    }

  my @pack;

  for my $flavour (@{ $conf->{compilation_flavours} })
    {
      my $path = "$pack$flavour";
      if ($path eq $self->{path})
        {
          push @pack, $self;
        }
      else
        {
          push @pack, 'davai::build'->new (path => $path)
            if (-d "$pack$flavour");
        }
    }

  return @pack;
}

my %pack2davai =
(
  ioassign  => ['ioassign'                         ,  ''                         ],
  BATOR     => ['batodb'                           ,  ''                         ],
  lfitools  => ['lfitools'                         ,  'FALFILFA/bin/lfitools'    ],
  MASTERODB => ['masterodb'                        ,  ''                         ],
  OOTESTVAR => ['oopsbinary.ifs-ootestvar'         ,  ''                         ],
  OOVAR     => ['oopsbinary.ifs-oovar'             ,  ''                         ],
  PGD       => ['buildpgd'                         ,  'SURFEX/bin/pgd'           ],
  PREP      => ['prep'                             ,  'SURFEX/bin/prep'          ],
  MASTERODB => ['ifsmodel.ifs'                     ,  ''                         ],
  OOTESTVAR => ['oopsbinary.ifs-ootestcomponent'   ,  ''                         ],
);
      
sub compileBinaries
{
  my $self = shift;

  my %args = @_;
  my $pack = $self->{path};

  my @binlist = ('MASTERODB');

  my $allok = 1;

  for my $program (sort keys (%pack2davai))
    {
      my $desc = $pack2davai{$program};
      next if ($desc->[1]);
      $allok = $allok && (-f "$pack/bin/$program");
      push @binlist, $program unless ($program eq 'MASTERODB');
    }

  return if ($allok);

  my $cwd = &Cwd::cwd ();

  chdir ($pack);

  my @genesis = $self->getGenesis ();

  my $binlist = join (',', map { lc ($_) } @binlist);

  if (grep { $_ eq '-p' } @genesis)
    {
      for my $i (0 .. $#genesis)
        {
          if ($genesis[$i] eq '-p')
            {
              $genesis[$i+1] = $binlist;
            }
        }
    }
  else
    {
      push @genesis, (-p => $binlist);
    }

  unlink ('ics_masterodb_etc');

  rename ('ics_packages', 'ics_packages.bak') if (-f 'ics_packages');

  &runCommand (command => [@genesis], %args);

  rename ('ics_packages.bak', 'ics_packages') if (-f 'ics_packages.bak');

  (my $ics = &slurp ('ics_masterodb_etc')) =~ s/GMK_THREADS=1\b/GMK_THREADS=16/goms;
  'FileHandle'->new ('>ics_masterodb_etc')->print ($ics);
  chmod (0755, $ics);

  &runCommand (command => ['./ics_masterodb_etc'], %args);
  
  chdir ($cwd);
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

  chomp for (my @view = do { my $fh = 'FileHandle'->new ("<$pack/.gmkview"); <$fh> });

  for my $pack2bin (@pack2bin)
    {
       &mkpath ($pack2bin);
      
       for my $bin (sort keys (%pack2davai))
         {
           my $desc = $pack2davai{$bin};
           my ($davaiLink, $hubName) = @$desc;

           $davaiLink = "$pack2bin/$davaiLink.$conf->{executables_fmt}";

           if ($hubName)
             {
               for my $view (@view)
                 {
                   for my $prec (qw (_sp _dp))
                     {
                       next unless (-f (my $hub = "$pack/hub/$view/install/$hubName$prec"));
                       my ($o, $t) = ($hub, $davaiLink);
                       goto FOUND_IN_HUB if (-l $t);
                       symlink ($o, $t) or die ("Cannot symlink $o -> $t");
                       print "symlink $o -> $t\n" if ($args{verbose});
                       goto FOUND_IN_HUB;
                     }
                 }
               die ("Executable `$bin' was not found in hub");
FOUND_IN_HUB:

             }
           else
             {
               die ("Missing `$pack/bin/$bin'") unless (-f "$pack/bin/$bin");
               my ($o, $t) = ("$pack/bin/$bin", $davaiLink);
               next if (-l $t);
               symlink ($o, $t) or die ("Cannot symlink $o -> $t");
               print "symlink $o -> $t\n" if ($args{verbose});
             }
         }
    }
  
}

1;
