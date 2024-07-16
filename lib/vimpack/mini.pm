package vimpack;

use strict;
use DB_File;
use FileHandle;
use Fcntl qw (O_RDWR O_CREAT);
use File::Find qw ();
use File::Basename;

use vimpack::history;
use log;

sub new
{
  my $class = shift;

  my $self = bless 
               { 
                 history => 'vimpack::history'->new (), 
                 maxfind => 200,
                 @_ 
               }, $class;

  $self->{log} = 'log'->new (">>/home/gmap/mrpm/marguina/tmp/vimpack.log");

  return $self;
}

sub windex_
{

# find words in file and build index

  my $f = shift;
  my $b = shift;

  my @w = map { lc ($_) } ($_[0] =~ m/\b([a-z][a-z_0-9]+|\d\d\d+)\b/igoms);
  for my $w (@w) 
    {
      push @{ $b->{$w} }, $f;
    }
}

sub cindex_
{
  my ($f, $cindex, $text) = @_;
}

sub wanted_windex_
{

# helper function to build indexes
# windex : word index
# findex : seen files index
# sindex : file location index
# cindex : call index

  my %args = @_;

  my $windex   = $args{windex};
  my $findex   = $args{findex};
  my $sindex   = $args{sindex};
  my $cindex   = $args{cindex};
  my $fhlog    = $args{fhlog};
  my $callback = $args{callback};

  my $f = $File::Find::name;

# skip generated files
  return if ($f =~ m,/\.(?:intfb|include)/,o);

# skip non file elements
  return unless (-f $f);

  if ($sindex)
    {
      push @{ $sindex->{&basename ($f)} }, $f;
    }

# fortran & C & C++
  return unless ($f =~ m/\.(f90|f|c|cc)$/io);

  $callback && $callback->($f);

  $f =~ s,^((?:src|jet)/[^/]+)/,,goms;  
  my $src = $1;

# skip if already seen
  return if ($findex && $findex->{$f}++);

  $fhlog && $fhlog->print ("$src/$f\n");

  my $text;

  if ($windex)
    {
      $text ||= do { my $fh = 'FileHandle'->new ("<$src/$f"); local $/ = undef; <$fh> };
      &windex_ ($f, $windex, $text);
    }
  if ($cindex)
    {
      $text ||= do { my $fh = 'FileHandle'->new ("<$src/$f"); local $/ = undef; <$fh> };
      &cindex_ ($f, $cindex, $text);
    }
}

sub idx
{
  my ($self, %args) = @_;

  my $callback = $args{callback};

# create indexes

  my $fhlog = $self->{fhlog};

  my @gmkview = $self->gmkview ();
  my $local = shift (@gmkview);

  unless ((-f "$self->{TOP}/windex.db") && (-f "$self->{TOP}/sindex.db"))
    {
      my %windex;
      my %findex;
      my %sindex;

      mkdir ($self->{TOP});

      my $follow = 0;

      for my $dir (map { ("jet/$_/", "src/$_/") } @gmkview)
        {
          next unless (-d $dir);
          &File::Find::find ({wanted => sub { &wanted_windex_ (windex => \%windex, findex => \%findex, 
                                                               sindex => \%sindex, fhlog  => $fhlog, 
                                                               callback => $callback) }, 
                             no_chdir => 1, follow => $follow}, $dir);
        }
  
      tie (my %WINDEX,  'DB_File', "$self->{TOP}/windex.db",  O_RDWR | O_CREAT, 0666, $DB_HASH);
      &cidx (\%windex, \%WINDEX);
      untie (%WINDEX);
  
      tie (my %SINDEX,  'DB_File', "$self->{TOP}/sindex.db",  O_RDWR | O_CREAT, 0666, $DB_HASH);
      &cidx (\%sindex, \%SINDEX);
      untie (%SINDEX);
    }
}

sub cidx
{
  my ($lh, $sh) = @_;

# transform list values in strings

  while (my ($key, $val) = each (%$lh))
    {
      my %seen;
      my @val = grep { ! $seen{$_}++ } @{$val};
      $sh->{$key} = join (' ', @val);
    }
}
  
sub gmkview
{

# read gmkview

  my $self = shift;

  unless (-f '.gmkview')
    {
      &VIM::Msg (".gmkview was not found; are you in a pack ?\n");
      return;
    }

  my @gmkview = do { my $fh = 'FileHandle'->new ("<.gmkview"); my @x = <$fh>; chomp for (@x); @x };

  return @gmkview;
}

1;
