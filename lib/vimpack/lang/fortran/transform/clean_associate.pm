package vimpack::lang::fortran::transform::clean_associate;

use strict;
use base qw (vimpack::lang::fortran::transform);
use Fxtran;
use List::MoreUtils qw (uniq);
use List::Util qw (min max);

use Data::Dumper;

sub apply
{
  my ($class, %args) = @_;
  
  my $edtr = $args{editor};
  my $buf = $edtr->getcurbuf ();
  my $win = $edtr->getcurwin ();

  my $dom = $class->xml_parse (editor => $edtr, buffer => $buf, file => $args{file});

  return unless ($dom);

  my ($row, $col) = $win->Cursor ();

  my @assoc = &F ('.//associate-construct', $dom);
  
  for my $assoc (@assoc)
    {
      my $stmt = $assoc->firstChild;
      &Fxtran::expand ($stmt);
  
      my @N = &F ('./associate-LT/associate/associate-N', $stmt);
  
      for my $N (@N)
        {   
          my $n = $N->textContent;
          my @expr = &F ('.//named-E[string(N)="?"]', $n, $dom);
          next if (@expr);
          my $associate = $N->parentNode;
          &Fxtran::removeListElement ($associate);
        }   
      &Fxtran::fold ($stmt);
    }

  $buf->Delete (1, $buf->Count ());
  $buf->Append (0, split (m/\n/o, $dom->textContent));
  $win->Cursor ($row, $col);
}

1;
