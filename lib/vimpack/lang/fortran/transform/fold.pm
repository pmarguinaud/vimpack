package vimpack::lang::fortran::transform::fold;

use strict;
use base qw (vimpack::lang::fortran::transform);

use Data::Dumper;

sub _do_transform_fold_unfold
{
  my ($class, %args) = @_;

  my $edtr   = $args{editor};
  my $action = $args{action};

  my $buf = $edtr->getcurbuf ();
  my $win = $edtr->getcurwin ();

  my $dom = $class->xml_parse (editor => $edtr, buffer => $buf, file => $args{file});

  return unless ($dom);

  my ($row, $col) = $win->Cursor ();

  (my $xpc = 'XML::LibXML::XPathContext'->new ()) 
     ->registerNs ('f', 'http://fxtran.net/#syntax');

  my $Target = $class->xml_find_node_by_row_col (dom => $dom, row => $row, 
                                                 col => $col, xpc => $xpc);

   
  my ($stmt) = $xpc->findnodes ('(./ancestor::f:' . $class->xpath_by_type ('stmt') . ')[last()]', $Target);

  return unless ($stmt);

  my @stmt = $class->xml_if_construct_skeleton (xpc => $xpc, stmt => $stmt);

  return unless (@stmt);

  my @row = map { $class->xml_get_row (node => $_, xpc => $xpc) } @stmt;

  if ($action eq 'fold')
    {
      for my $i (0 .. $#row-1)
        {
          my ($r1, $r2) = ($row[$i]+1, $row[$i+1]-1);
          &VIM::DoCommand ("${r1},${r2}fold")
            if ($r2 > $r1);
        }
    }
  elsif ($action eq 'unfold')
    {
      my ($r1, $r2) = ($row[0], $row[-1]);
      &VIM::DoCommand ("${r1},${r2}foldopen");
    }

}

sub apply
{
  my ($class, %args) = @_;
  $class->_do_transform_fold_unfold (action => 'fold', %args);
}

sub xml_if_construct_skeleton
{
  my ($class, %args) = @_;

  my $stmt = $args{stmt};
  my $xpc = $args{xpc};

  return undef
    unless ($stmt->nodeName =~ m/^(?:if-then|else-if|else|end-if)-stmt$/o);

  my ($if_construct) = $xpc->findnodes ('(./ancestor::f:if-construct)[last()]', $stmt);

  my @if_block = $xpc->findnodes ('./f:if-block', $if_construct);
  
  my @if_stmt;
  for my $if_block (@if_block)
    {
      push @if_stmt, 
        $xpc->findnodes ('(.//f:' . $class->xpath_by_type ('stmt') . ')[1]', $if_block);
    }
  push @if_stmt, 
    $xpc->findnodes ('(.//f:' . $class->xpath_by_type ('stmt') . ')[last()]', $if_block[-1]);
  
  return @if_stmt;
}

1;
