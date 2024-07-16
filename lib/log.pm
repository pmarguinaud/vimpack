package log;

use strict;
use base qw (FileHandle);
use FindBin qw ($Bin);
use File::Spec;

sub print : method
{
  my $self = shift;

  (undef, my $file, my $line) = caller (0);

  $file = 'File::Spec'->abs2rel ($file);

  $self->SUPER::print ("$file:$line >> ", @_);
  $self->flush ();

}

1;
