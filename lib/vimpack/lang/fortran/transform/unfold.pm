package vimpack::lang::fortran::transform::unfold;

use strict;
use base qw (vimpack::lang::fortran::transform::fold);

use Data::Dumper;

sub apply
{
  my ($class, %args) = @_;
  $class->_do_transform_fold_unfold (action => 'unfold', %args);
}

1;
