package vimpack::source;

use strict;

use Data::Dumper;
use File::Basename;
use File::stat;
use File::Copy;
use File::Temp;
use Fcntl 'S_IWUSR';

use base qw (vimpack::file);

sub singleLink
{
  my $file = shift;

  return unless (my $st = stat ($file));
  return unless ($st->cando (S_IWUSR, 1));

  # Make file single link
  if ($st->nlink > 1)
    {
      my $fh = 'File::Temp'->new (); 
      &copy ($file, $fh->filename ());
      unlink ($file);
      &copy ($fh->filename (), $file);
    }
  
}

sub new
{
  my $class = shift;
  my $self = bless { @_ }, $class;

  $self->{lang} ||= 'vimpack::lang'->lang ($self->{file});

  return $self;
}

sub do_edit
{

# edit a file; goto line passed as argument or previous location

  my ($self, %args) = @_;

  my $edtr = $args{editor};

  if ($self->islocal () || $self->istmp ())
    {
      &singleLink ($self->{file});
      &VIM::DoCommand ("e $self->{file}");
    }
  else
    {
      &VIM::DoCommand ("view $self->{file}");
    }

  if ($args{line})
    {
      &VIM::DoCommand (":$args{line}");
      if ($args{column})
        {
          my $win = $edtr->getcurwin ();
          $win->Cursor ($args{line}, $args{column});
        }
    }
  else
    {
# last seen location
      &VIM::DoCommand (":silent normal '\"");
    }

}

sub islocal
{

# check if file is a local source file

  my ($self, $file) = @_;

  if (ref ($self) && (! $file))
    {
      $file = $self->{file};
    }

  return $file =~ m,^src/local/,o;
}

sub ispack
{

# check if file belongs to a pack

  my ($self, $file) = @_;

  if (ref ($self) && (! $file))
    {
      $file = $self->{file};
    }

  return $file =~ m,^src/[^/]+/,o;
}

sub istmp
{

# check if file is a scratch file

  my ($self, $file) = @_;

  if (ref ($self) && (! $file))
    {
      $file = $self->{file};
    }

  return $file =~ m,=,;
}

sub path
{
  my ($self, $file) = @_;

  if (ref ($self) && (! $file))
    {
      $file = $self->{file};
    }

  for ($file)
    {
      s,^.*src=/,,o;
      s,^src/[^/]+/,,o;
    }

  return $file;
}

sub do_find
{

# make a search on word pointed to by cursor

  my ($self, %args) = @_;

  my $edtr = $args{editor};
  my $defn = $args{defn};
  my $call = $args{call};
  my $hist = $args{hist};

  my $curbuf = $edtr->getcurbuf ();
  my $curwin = $edtr->getcurwin ();

  my ($row, $col) = $curwin->Cursor ();
  
  my ($line) = $curbuf->Get ($row);

# find word pointed by cursor; this word is delimited by $i1 and $i2 in $line
  
  my ($word, $i1, $i2) = &vimpack::tools::findword ($col, $line);

  unless ($word)
    {
      &VIM::Msg (' ');
      return;
    }

  "vimpack::lang::$self->{lang}"->do_find (word => $word, i1 => $i1, i2 => $i2, line => $line, 
                                           editor => $edtr, defn => $defn, call => $call, 
                                           hist => $hist);

}


sub backup_copy
{
  my ($self, %args) = @_;

  my $edtr = $args{editor};

  (my $file = $self->{file}) =~ s,^src/([^/]+)/,,o;

# save to history
  my $f_his = "$edtr->{TOP}/hst=/$file";
  my $idx = 0;
  while (-f "$f_his.$idx") 
    { 
      $idx++;
    }
  &vimpack::tools::copy (fi => $self->{file}, fo => "$f_his.$idx", fhlog => $edtr->{fhlog});
}


sub do_commit
{
  my ($self, %args) = @_;


  my $edtr = $args{editor};
  my $curwin = $edtr->getcurwin ();

  my ($file, $f_old, $f_new);

  $self->backup_copy (editor => $edtr);

  if ($self->istmp ())
    {
      ($file = $self->{file}) =~ s,^.*src=/,,;
      &VIM::DoCommand ('silent write')
        if ($args{write});
      ($f_old, $f_new) = ("$edtr->{TOP}/src=/$file", "src/local/$file");
    }
  elsif ((! $self->islocal ()) && $self->ispack ())
    {
      ($file = $self->{file}) =~ s,^src/([^/]+)/,,o;
      my $view = $1;
      ($f_old, $f_new) = ("src/$view/$file", "src/local/$file");
    }
  else
    {
      return;
    }

  if ($args{auto})
    {
      
      my ($SINDEX) = $edtr->getsindex ('SINDEX');

      my ($P) = split (m/\s+/o, $SINDEX->{&basename ($self->{file})});

      unless (&vimpack::tools::fcmp ($P, $f_old))
        {
          &VIM::Msg ("$self->{file} was not modified");
          goto QUIT;
        };

    }


# copy to local

  &vimpack::tools::copy (fi => $f_old, fo => $f_new, fhlog => $edtr->{fhlog});

# save cursor location & syntax mode

  my @pos = $curwin->Cursor ();

  (undef, my $syntax) = &VIM::Eval ('&syntax');

# open new file

  &VIM::DoCommand ("e $f_new");

# kill old buffer 
  &VIM::DoCommand ("bdelete $f_old");

# restore cursor & syntax

  $curwin = $edtr->getcurwin (); # reload curwin
  $curwin->Cursor (@pos);
  
  &VIM::DoCommand ("set syntax=$syntax")
    if ($syntax);


# quit ?
QUIT:

  &VIM::DoCommand ('q')
    if ($args{quit});

}

sub do_diff
{

# diff of file passed as argument with version N-1

  my ($self, %args) = @_;

  my $edtr = $args{editor};

  my ($sindex, $SINDEX) = $edtr->getsindex (qw (sindex SINDEX));

  my $F = &basename ($self->{file});

  my ($P1, $P2) = ($sindex->{$F} ? ($sindex->{$F}) : (), split (m/\s+/o, $SINDEX->{$F}));

  unless ($P1 && $P2)
    {
      &VIM::Msg ("`$F' was not modified");
      return;
    }

  my ($view, $G) = ($P1 =~ m,^src/([^/]+)/(.*)$,go);

  unless ($view eq 'local')
    {
      my $P3 = "$edtr->{TOP}/src=/$G";
      &vimpack::tools::copy (fi => $P1, fo => $P3, fhlog => $edtr->{fhlog});
      $P1 = $P3;
    }

  &singleLink ($P1);

# Edit base file readonly
  &VIM::DoCommand ("view $P2");
# diff with P1
  &VIM::DoCommand ("vert diffsplit $P1");
# change to left window
  &VIM::DoCommand ("wincmd r");

}

sub do_transform
{
  my ($self, %args) = @_;

  my $edtr = $args{editor};
  my ($transform, @args) = @{ $args{args} };

  my $lang = $self->{lang};

  my $class = "vimpack::lang::$lang\::transform::$transform";

  eval "use $class";

  $@ && die ($@);

  if ($class->can ('apply'))
    {
      $class->apply (editor => $edtr, file => $self, args => \@args);
    }
  else
    {
      &VIM::Msg ("`$transform' is not supported by $lang");
    }

}

1;
