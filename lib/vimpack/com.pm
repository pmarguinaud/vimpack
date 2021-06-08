package vimpack::com;

use FileHandle;
use Data::Dumper;
use File::Basename;
use File::stat;
use strict;

my ($M1, $M2) = ('<{', '}>');

sub style
{
  &VIM::DoCommand (':syntax region Remark start="<{[a-z]\+:" end="}>"');
  &VIM::DoCommand (':hi def Remark cterm=underline ctermfg=yellow');
}

sub insert
{
  my ($class, %args) = @_;

  my $win = $args{win};
  my $buf = $args{buf};
  my $lst = $args{lst};
  my $src = $args{src};

  $class->style ();

  my ($Line0, $Column0) = $win->Cursor (); 
  $Line0--; $Column0--;
  my $Line1 = $Line0;

  my $fh = 'FileHandle'->new ("<$lst");
  unless ($fh)
    {
      &VIM::Msg ("$lst was not found");
      return;
    }

  my $st_src = stat ($src);
  my $st_lst = stat ($lst);

  if ($st_lst->mtime () < $st_src->mtime ())
    {
      &VIM::Msg ("$lst is outdated");
      return;
    }

  my @lines = <$fh>;
  $fh->close ();

  $src = &basename ($src);
  
  my %Message;
  while (defined (my $line = shift (@lines)))
    {
      chomp ($line);

# Intel Fortran compiler
      if ($line =~ m/^(\S*?)\((\d+)\):\s*(?:\(col\.\s*(\d+)\))?\s+(\S+?)(?:\s+\#\d+)?:\s*(\S.*\S)/o)
        {
          my ($File, $Line, $Column, $Level, $Message) = ($1, $2, $3, $4, $5);
          $Column ||= 1; $Column--; $Line--;
          $Message{$File}[$Line][$Column]{$Level}{$Message} = 1;
        }
# GNU Fortran compiler
      elsif ($line =~ m/^(\S+):(\d+)\.(\d+):$/o)
        {
          my ($File, $Line, $Column) = ($1, $2, $3);
          $Line--;
          $File = &basename ($File);
          while (defined (my $l = shift (@lines)))
            {
              if ($l =~ m/^(Warning|Error):\s*(\S.*\S)$/o)
                {
                  my ($Level, $Message) = ($1, $2);
                  $Message =~ s/ at \(1\)$//o;
                  $Message{$File}[$Line][$Column]{$Level}{$Message} = 1;
                  last;
                }
            }
        }
# GNU C compiler
# cma_open.c:595:19: warning: unused variable ‘scheme_change’ [-Wunused-variable]
      elsif ($line =~ m/^(\S+):(\d+):(\d+):\s+(\w+):\s*(\S.*\S)$/o)
        {
          my ($File, $Line, $Column, $Level, $Message) = ($1, $2, $3, $4, $5);
          $Line--; $Column--;
          $Column = 0 if ($Column < 0);
          $File = &basename ($File);
          $Message{$File}[$Line][$Column]{$Level}{$Message} = 1;
        }
    }
  
  my @text = map { $buf->Get ($_) . "\n" } (1 .. $buf->Count ());
  my $imess = 0;
  my $iloca = 0;
  
  for my $Line (reverse (0 .. $#{$Message{$src}}))
    {
      for my $Column (reverse (0 .. $#{$Message{$src}[$Line]}))
       {
          for my $Level (sort keys (%{ $Message{$src}[$Line][$Column] }))
            {
              my @Message = sort keys (%{ $Message{$src}[$Line][$Column]{$Level} });
              my $stl = substr ($text[$Line], 0, $Column);
              if ($stl =~ m/^\s*$/o)
                {
                  my $Message = join ('', map { "$stl$_\n" } (@Message));
                  my $T = "$M1$Level:\n$Message$stl$M2";
                  substr ($text[$Line], $Column, 0, $T);
                  my @T = split (m/\n/o, $T);
                  if ($Line <= $Line0)
                    {
                      $Line1 += (scalar (@T)-1);
                    }
                }
              else
                {
                  my $Message = join (' ', @Message);
                  substr ($text[$Line], $Column, 0, "$M1$Level: $Message$M2");
                }
              $imess += scalar (@Message);
              $iloca++;
            }
       }
    }
  
  my $text = join ('', @text);

  my @text = split (m/\n/o, $text);
  chomp for (@text);
  
  for my $line (1 .. $buf->Count())
    {
      $buf->Delete (1);
    }

  $buf->Append (0, @text);
  &VIM::DoCommand (':set nomodified');

  $win->Cursor ($Line1+1, $Column0+1);

  unless ($args{silent})
    {
      if ($imess > 0)
        {
          &VIM::Msg (sprintf ("%d warnings were inserted at %d locations", $imess, $iloca));
        }
      else
        {
          &VIM::Msg ("No warning was inserted");
        }
    }
}

sub remove
{
  my ($class, %args) = @_;

  my $win = $args{win};
  my $buf = $args{buf};

  my @text = map { $buf->Get ($_) . "\n" } (1 .. $buf->Count ());
  my $text = join ('', @text);

  my ($Line0, $Column0) = $win->Cursor (); 
  $Line0--; $Column0--;
  my $Line1 = $Line0;
  
# $text =~ s/{\w+:.*?}//goms;

  my $Line = 0;
  @text = ();
  while ($text =~ s/^(.*?)($M1\w+:.*?$M2)//oms)
    {
      my ($T, $C) = ($1, $2);
      push @text, $T;
      my $nT = scalar (split (m/\n/o, $T));
      my $nC = scalar (split (m/\n/o, $C));
      $Line += ($nT-1) + ($nC-1);
      if ($Line < $Line0)
        {
          $Line1 -= ($nC-1);
        }
    }
  push @text, $text;
  my $text = join ('', @text);

  my @text = split (m/\n/o, $text);
  chomp for (@text);
  
  for my $line (1 .. $buf->Count())
    {
      $buf->Delete (1);
    }

  $buf->Append (0, @text);
  &VIM::DoCommand (':set nomodified');

  $win->Cursor ($Line1+1, $Column0+1);

# &VIM::Msg ($Line1+1);
}

1;

