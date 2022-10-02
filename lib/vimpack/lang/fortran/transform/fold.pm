package vimpack::lang::fortran::transform::fold;

use strict;
use base qw (vimpack::lang::fortran::transform);
use Fxtran;
use List::MoreUtils qw (uniq);
use List::Util qw (min max);

use Data::Dumper;


sub normalizeCommas
{
  my $x = shift;
  my @c = &F ('.//text()[normalize-space(.)=","]', $x);
  for my $c (@c)
    {
      my $t = $c->getData;
      $t =~ s/\s*,\s*/, /go;
      $c->setData ($t);
    }
}

sub apply
{
  my ($class, %args) = @_;
  
  my $edtr = $args{editor};
  my $args = $args{args};

  my $buf = $edtr->getcurbuf ();
  my $win = $edtr->getcurwin ();

  my $dom = $class->xml_parse (editor => $edtr, buffer => $buf, file => $args{file});

  return unless ($dom);

  my @xpath = @$args;
  my ($row, $col) = $win->Cursor ();


  my @nodes;
  
  if (@xpath)
    {
      for my $xpath (@xpath)
        {
          push @nodes, &F ($xpath, $dom);
        }
    }
  else
    {
      my $xpc = 'XML::LibXML::XPathContext'->new ();
      $xpc->registerNs (f => 'http://fxtran.net/#syntax');

      my $node = $class->xml_find_node_by_row_col (dom => $dom, row => $row, 
                                                   col => $col, xpc => $xpc);
      my $stmt = &Fxtran::stmt ($node);
      push @nodes, $stmt;
    }


  for my $node (@nodes)
    {
      &Fxtran::expand ($node);
      &normalizeCommas ($node);
      &Fxtran::fold ($node);
    }


  my $n = $buf->Count ();
  $buf->Delete (1, $n);
  $buf->Append (0, split (m/\n/o, $dom->textContent));
  $win->Cursor ($row, $col);
}

1;
