package vimpack;

=head1 NAME

vimpack

=head1 DESCRIPTION

An extension to vim for editing packs.

=head1 AUTHOR

Philippe.Marguinaud@meteo.fr

=cut


use strict;

use DB_File;
use List::Util qw (min max);
use Fcntl qw (O_RDONLY);

use File::Temp;
use File::Copy;
use File::stat;
use File::Spec;
use File::Find qw ();
use File::Basename;
use File::Path;
use Cwd;
use Getopt::Long;
use FileHandle;
use Data::Dumper;

use vimpack::com;
use vimpack::mini;
use vimpack::lang;
use vimpack::file;
use vimpack::tools;
use vimpack::history;

sub setlog
{

# open logfile

  my $self = shift;
  my $verbose = shift;

  if ($verbose)
    {
      mkdir ($self->{TOP});
      my $fhlog = 'FileHandle'->new (">>$self->{TOP}/log");
      $fhlog->autoflush (1);
      $self->{fhlog} = $fhlog;
    }
}

sub getsindex
{

# get file location index; local index is built on the fly

  my ($self, @args) = @_;

  my %args = map { ($_, 1) } @args;

  $self->checkidx ('sindex');

  my @gmkview = $self->gmkview ();
  my $local = shift (@gmkview);

  my @i;

  if ($args{sindex})
    {
      my %s;

      my %sindex;

      my $follow = 0;
      &File::Find::find ({wanted => sub { &wanted_windex_ (sindex => \%s, fhlog => $self->{fhlog}) }, 
                          no_chdir => 1, follow => $follow}, "src/$local/");

      &cidx (\%s, \%sindex);

      push @i, \%sindex;

    }

  if ($args{SINDEX})
    {
      unless ($self->{SINDEX})
        {
          my %SINDEX;
          tie (%SINDEX,  'DB_File', "$self->{TOP}/sindex.db", O_RDONLY);
          $self->{SINDEX} = \%SINDEX;
        }
      push @i, $self->{SINDEX};
    }

  return @i;
}

sub getwindex
{
  my ($self, @args) = @_;

  my @gmkview = $self->gmkview ();
  my $local = shift (@gmkview);

  $self->checkidx ('windex');

  my %WINDEX;
  my %windex;
  my %findex;

  tie (%WINDEX,  'DB_File', "$self->{TOP}/windex.db", O_RDONLY);
  
  {
    my %b;
    my $follow = 0;
    &File::Find::find ({wanted => sub { &wanted_windex_ (windex => \%b, findex => \%findex, 
                                                         fhlog => $self->{fhlog}) }, 
                       no_chdir => 1, follow => $follow}, "src/$local/");
    
    &cidx (\%b, \%windex);
  }

  return (\%WINDEX, \%windex, \%findex);
}

sub DIFF
{

# diff of current file with version N-1

  my $self = shift;

  eval
    {

      $self->{history}->clear ();
      
      if (@_)
        {
          $self->diff (files => \@_);
        }
      else
        {
          my $curbuf = $self->getcurbuf ();
          my $file = $curbuf->Name ();
          $self->diff (files => [&basename ($file)])
            if ('vimpack::file'->issrc ($file));
        }
     
    };

  $self->reportbug ($@);

}


sub diff
{

# diff of file passed as argument with version N-1

  my ($self, %args) = @_;

  my ($sindex, $SINDEX) = $self->getsindex (qw (sindex SINDEX));

  my ($F) = @{ $args{files} }; # single file

  my ($P) = ($sindex->{$F} ? ($sindex->{$F}) : (), split (m/\s+/o, $SINDEX->{$F}));

  return unless ($P);

  my $file = 'vimpack::file'->new (file => $P);

  $file->do_diff (editor => $self);

}

sub checkidx
{

# check index and build it if missing

  my ($self, $idx) = @_;
  
  unless (-f "$self->{TOP}/$idx.db") 
    {
      &VIM::Msg ("Indexing files; please wait...");
      $self->idx ();
    }

}

sub edit
{

# edit a list of files

  my ($self, %args) = @_;

  my ($sindex, $SINDEX) = $self->getsindex (qw (sindex SINDEX));

  my @HlF;

# prepare file list

  for my $F (@{ $args{files} })
    {
      my ($line, $column) = ('', '');

      my $Q = 'File::Spec'->canonpath (&dirname ($F));
      $Q = $Q eq '.' ? '' : $Q;

      $F = &basename ($F);

      if ($F =~ s/:(\d+)(?:(?:\.|:)(\d+))?$//go)
        {
          ($line, $column) = ($1, $2);
        }
      elsif ($F =~ s/\((\d+)\)(?::.*)?$//o)
        {
          ($line) = ($1);
        }
  
      my ($P) = (($sindex->{$F} ? ($sindex->{$F}) : ()), split (m/\s+/o, $SINDEX->{$F}));

      my ($view, $G) = ($P =~ m,^src/([^/]+)/(.*)$,go);
      
      unless ($G)
        {
          &VIM::DoCommand ("echohl WarningMsg | echo \"`$F' was not found; skip...\" | echohl None");
          next;
        }
      if ($Q && !("$Q/$F" eq $G))
        {
          &VIM::DoCommand ("echohl WarningMsg | echo \"`$Q/$F' was not found (maybe you mean `$G'); skip...\" | echohl None");
          next;
        }
      
      my ($H1, $H2, $H3) = map { 'File::Spec'->canonpath ($_) } ("src/local/$G", "src/$view/$G", "$self->{TOP}/src=/$G");

      &mkpath (&dirname ($H3));
      
      if (-f $H1)
        {
# already in local set
          push @HlF, [ $H1, $line, $column, $F ];
        }
      else
        {
# copy to scratch
          &vimpack::tools::copy (fi => $H2, fo => $H3, fhlog => $self->{fhlog});
          push @HlF, [ $H3, $line, $column, $F ];
        }
      
    }

# open files; vertical split

  for my $i (reverse (0 .. $#HlF))
    {
      my ($H, $line, $column, $F) = @{ $HlF[$i] };

      my $f = 'vimpack::source'->new (file => $H);

      $f->do_edit (line => $line, column => $column, editor => $self);

      if ($args{hist})
        {
          my $Flc = $F;
          $Flc .= ":$line" if ($line);
          $Flc .= ".$column" if ($column);
          $self->{history}->push ($self->getcurwin (), 'edit', %args, files => [ $Flc ]);
        }

      &VIM::DoCommand ($args{split} || 'vsplit')
        if ($i > 0);
    }

  
}

sub EDIT
{
  my $self = shift;

  eval
    {
      return $self->edit (files => [ @_ ], hist => 1);
    };

  $self->reportbug ($@);
}

sub BT
{
  my $self = shift;

  eval
    {
      return $self->edit (files => [ @_ ], hist => 1, split => 'split');
    };

  $self->reportbug ($@);
}

sub reportbug
{
  my ($self, $e) = @_;

  $e && &VIM::Msg ("An error occurred: `$e'; please exit the editor");

}

sub getcurbuf
{

# returns VIM current buffer

  my $self = shift;
  no warnings;
  return $main::curbuf;
}

sub getcurwin
{

# returns VIM current window

  my $self = shift;
  no warnings;
  return $main::curwin;
}

sub getcurfile
{
  my $self = shift;
  no warnings;
  return 'vimpack::file'->new (file => $main::curbuf->Name ());
}

sub TRANSFORM
{
  my ($self, @args) = @_;

  eval
    {
      return $self->transform (@args);
    };

  $self->reportbug ($@);

}

sub transform
{
  my ($self, @args) = @_;

  my $file = $self->getcurfile ();

  if ($file->can ('do_transform'))
    {
      $file->do_transform (editor => $self, args => [map { split (m/\s+/o, $_) } @args]);
    }
  else
    {
      &VIM::Msg (sprintf ("`%s' do not accept transform", &basename ($file->{file})));
    }

}

sub FIND
{
  my ($self, %args) = @_;

  eval
    {
      if ($args{new_window})
        {
          &VIM::DoCommand (':split');
        }
      return $self->find (hist => 1, %args);
    };

  $self->reportbug ($@);

}

sub find
{

# find word using index and create a listing 
# regex filters the results; if this is a single file, then we edit this file

  my ($self, %args) = @_;


  if ($args{auto})
    {
      my $file = $self->getcurfile ();
      return $file->do_find (editor => $self, %args);
    }


  if ($args{hist})
    {
      $self->{history}->push ($self->getcurwin (), 'find', %args);
    }


  my $word  = lc ($args{word});
  my $regex = $args{regex};
  my $rank  = $args{rank} || 0;
  my $defn  = $args{defn};
  my $call  = $args{call};

  return 'vimpack::search'->create (editor => $self, word => $word, regex => $regex, 
                                    rank => $rank, defn => $defn, call => $call);
}

sub COMMIT
{
  my ($self, %args) = @_;

  eval 
    {
      if ($args{auto})
        {
          return $self->commit (%args, write => 0);
        }
      else
        {
          return $self->commit (%args, write => 1);
        }
    };

  $self->reportbug ($@);
}

sub commit
{

# move scratch file to local

  my ($self, %args) = @_;


  my $file = $self->getcurfile ();
  return $file->do_commit (editor => $self, %args);
}

sub BACK
{
  my $self = shift;

  eval
    {

      my $curwin = $self->getcurwin ();
     
     
      my ($method0, %args0) = $self->{history}->pop ($curwin);
      my ($method1, %args1) = $self->{history}->pop ($curwin);
     
     
      if ($method1) 
        {
          my $fhlog = $self->{fhlog};
          $fhlog && $fhlog->print (&Dumper ([$method1, \%args1]));
          return $self->$method1 (%args1);
        }
      else
        {
          &VIM::Msg (' ');
        }

    };

  $self->reportbug ($@);

}

sub LOGHIST
{
  my $self = shift;
  my $fhlog = $self->{fhlog};
  $fhlog && $self->{history}->log ($fhlog);
}

sub NEWFILE
{
  my $self = shift;

  eval
    {
      return $self->newfile (@_);
    };

  $self->reportbug ($@);

}

sub newfile
{
  my ($self, $f) = @_;

  my $F = &basename ($f);

  my ($sindex, $SINDEX) = $self->getsindex (qw (sindex SINDEX));
  my ($P) = (($sindex->{$F} ? ($sindex->{$F}) : ()), split (m/\s+/o, $SINDEX->{$F}));

  if ($P)
    {
      &VIM::Msg ("`$F' already exists at `$P'");
      return;
    }

  'FileHandle'->new (">src/local/$f");

  return $self->edit (files => [ $F ], hist => 1);
}

sub icom
{
  my ($self, %args) = @_;

  my $curwin = $self->getcurwin ();
  my $curbuf = $self->getcurbuf ();

  my $s = &basename ($curbuf->Name ());
  my $p = "$s.list";

  my ($sindex, $SINDEX) = $self->getsindex (qw (sindex SINDEX));

  my ($P) = (($sindex->{$p} ? ($sindex->{$p}) : ()), split (m/\s+/o, $SINDEX->{$p}));
  my ($S) = (($sindex->{$s} ? ($sindex->{$s}) : ()), split (m/\s+/o, $SINDEX->{$s}));

  unless (-f $P)
    {
      $p =~ s/\.(?:F(?:90)|c)\.list$/.lst/io;
      ($P) = (($sindex->{$p} ? ($sindex->{$p}) : ()), split (m/\s+/o, $SINDEX->{$p}));
    }

  if ($P)
    {
      'vimpack::com'->insert (win => $curwin, buf => $curbuf, lst => $P, src => $S, %args);
    }
}

sub iopt
{
  my ($self, %args) = @_;

  my $curwin = $self->getcurwin ();
  my $curbuf = $self->getcurbuf ();

  my $s = &basename ($curbuf->Name ());
  my $p = "$s.optrpt";

  my ($sindex, $SINDEX) = $self->getsindex (qw (sindex SINDEX));

  my ($P) = (($sindex->{$p} ? ($sindex->{$p}) : ()), split (m/\s+/o, $SINDEX->{$p}));
  my ($S) = (($sindex->{$s} ? ($sindex->{$s}) : ()), split (m/\s+/o, $SINDEX->{$s}));

  unless (-f $P)
    {
      $p =~ s/\.(?:F(?:90)|c)\.optrpt$/.optrpt/io;
      ($P) = (($sindex->{$p} ? ($sindex->{$p}) : ()), split (m/\s+/o, $SINDEX->{$p}));
    }

  if ($P)
    {
      'vimpack::com'->insert (win => $curwin, buf => $curbuf, lst => $P, src => $S, %args);
    }
}

sub ICOM
{
  my ($self, %args) = @_;

  my $fhlog = $self->{fhlog};
  $fhlog && $fhlog->print (&Dumper (['ICOM', \%args]));

  eval
    {
      my @opts;
      if ($args{auto})
        {
          return if (! $self->{WARN});
          @opts = (silent => 1);
        }
      $self->icom (@opts);
    };

  $self->reportbug ($@);

}

sub IOPT
{
  my ($self, %args) = @_;

  my $fhlog = $self->{fhlog};
  $fhlog && $fhlog->print (&Dumper (['IOPT', \%args]));

  eval
    {
      my @opts;
      if ($args{auto})
        {
          return if (! $self->{WARN});
          @opts = (silent => 1);
        }
      $self->iopt (@opts);
    };

  $self->reportbug ($@);

}

sub ucom
{
  my $self = shift;

  my $curwin = $self->getcurwin ();
  my $curbuf = $self->getcurbuf ();
  
  'vimpack::com'->remove (win => $curwin, buf => $curbuf);

}

sub UCOM
{
  my ($self, %args) = @_;

  if (my $file = $self->getcurfile ())
    {
      $file->singleLink ();
    }

  eval
    {
      return if ($args{auto} && (! $self->{WARN}));
      $self->ucom ();
    };

  $self->reportbug ($@);
}

1;

