package vimpack::lang::fortran::transform::new_module;

use strict;
use Data::Dumper;
use File::Basename;

sub apply
{
  my ($class, %args) = @_;
  my @args = @{ $args{args} };

  my $edtr = $args{editor};
  my $buf  = $edtr->getcurbuf ();
  my $file = $args{file};

# $edtr->{fhlog}->print (&Dumper ([$file, \@args]));

  my ($module) = @args;

  ($module ||= &basename ($file->{file})) =~ s/\.f(?:90)?$//io;
  $module = uc ($module);

  my @code = split (m/\n/o, << "EOF");
MODULE $module

USE PARKIND1, ONLY : JPRB, JPIM
USE YOMHOOK, ONLY : LHOOK, DR_HOOK
IMPLICIT NONE

SAVE

END MODULE $module
EOF

  $buf->Append (0, @code);

}

1;
