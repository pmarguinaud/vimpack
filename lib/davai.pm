package davai;

use strict;

use Data::Dumper;

sub getMtoolRoot
{
  my %args = @_;
  my $conf = $args{conf};

  return "/scratch/mtool/$conf->{user}/cache/vortex/davai/nrv/$conf->{id}";
}

sub slurp
{
  my $f = shift;
  (my $fh = 'FileHandle'->new ("<$f")) or die ("Cannot open `$f'");
  local $/ =  undef; 
  my $text = <$fh>;
  return $text;
}

sub getConfPath
{
  my %args = @_;

  my ($nrv) = @args{qw (nrv)};

  my ($id) = ($nrv =~ m,\b(dv-\d+-\w+\@\w+)/,o);
  
  die unless ($id);
  
  my ($host, $user) = ($id =~ m/^dv-\d+-(\w+)\@(\w+)$/o);
  
  die unless ($host && $user);
  
  return "$nrv/conf/davai_nrv.ini";
}


sub getConf
{
  my %args = @_;

  my ($nrv) = @args{qw (nrv)};

  my ($id) = ($nrv =~ m,\b(dv-\d+-\w+\@\w+)/,o);
  
  die unless ($id);
  
  my ($host, $user) = ($id =~ m/^dv-\d+-(\w+)\@(\w+)$/o);
  
  die unless ($host && $user);

  my $conf = -f "$nrv/DAVAI-tests/conf/$host.ini"  
           ? &slurp ("$nrv/DAVAI-tests/conf/$host.ini")
           : &slurp ("$nrv/conf/davai_nrv.ini");

  my @conf = grep { !/^\s*#/o } split (m/\n/o, $conf);
  $conf = join ("\n", @conf, "");

  my ($compilation_flavour) = ($conf =~ m/compilation_flavour\s*=\s*(\S+)/goms);
  my ($compilation_flavours) = ($conf =~ m/compilation_flavours\s*=\s*list\(\s*(.[^\n]*?)\s*\)/goms);
  $compilation_flavours = [split (m/\s*,\s*/o, $compilation_flavours)];

  my ($executables_fmt) = ($conf =~ m/executables_fmt\s*=\s*(\S+)/goms);
  die unless ($compilation_flavour && $executables_fmt);
  
  $conf = 
    {
      conf => "$nrv/DAVAI-tests/conf/$host.ini",
      host => $host,
      user => $user,
      id   => $id,
      compilation_flavour  => $compilation_flavour,
      compilation_flavours => $compilation_flavours,
      executables_fmt      => $executables_fmt,
    };

  return $conf;
}



1;
