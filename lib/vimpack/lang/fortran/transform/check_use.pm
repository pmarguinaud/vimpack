package vimpack::lang::fortran::transform::check_use;

use strict;
use base qw (vimpack::lang::fortran::transform);

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

  (my $xpc = 'XML::LibXML::XPathContext'->new ()) 
     ->registerNs ('f', 'http://fxtran.net/#syntax');

  my $Target = $class->xml_find_node_by_row_col (dom => $dom, row => $row, 
                                                 col => $col, xpc => $xpc);

   
  my ($use_stmt) = $xpc->findnodes ('(./ancestor::f:' . $class->xpath_by_type ('stmt') . ')[last()]', $Target);

  return unless ($use_stmt->nodeName eq 'use-stmt');

  my $use_stmt_row = $class->xml_get_row (xpc => $xpc, node => $use_stmt);

  $use_stmt = $use_stmt->cloneNode (1);

  my @useN = $xpc->findnodes ('.//f:use-N', $use_stmt);

  for my $useN (@useN)
    {
      next unless ((my $N = $useN->textContent ()) =~ m/^\w+$/o);
      my @N = $xpc->findnodes ('.//f:N[string (.)="' . $N . '"]', $dom);

      if (scalar (@N) == 1)
        {
          my ($rename) = $xpc->findnodes ('./ancestor::f:rename', $useN);
          $rename->unbindNode ();
        }

    }

  my @text = split (m/\n/o, $use_stmt->textContent ());

  for (my $i = $use_stmt_row-1; ; $i++)
    {
      my $text = shift (@text);
      $buf->Append ($i, "! $text");
      @text or last;
    }

}

1;
