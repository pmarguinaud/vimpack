package vimpack::lang::fortran::transform::new_subroutine;

use strict;
use Data::Dumper;
use File::Basename;

sub apply
{
  my ($class, %args) = @_;
  my @args = @{ $args{args} };

  my $edtr = $args{editor};
  my $buf  = $edtr->getcurbuf ();
  my $win  = $edtr->getcurwin ();

  my $file = $args{file};

  my ($subroutine) = @args;

  ($subroutine ||= &basename ($file->{file})) =~ s/\.f(?:90)?$//io;
  $subroutine = uc ($subroutine);

  my $host = $class->grok_hostname (buf => $buf);

  my $use = $host ? '' : << 'EOF';

USE PARKIND1, ONLY : JPRB, JPIM
USE YOMHOOK, ONLY : LHOOK, DR_HOOK
IMPLICIT NONE
EOF
  chomp ($use);

  if ($host)
    {
      $host = "$host:";
    }

  my ($row, $col) = $win->Cursor ();

  my @code = split (m/\n/o, << "EOF");
SUBROUTINE $subroutine
$use
REAL (KIND=JPRB) :: ZHOOK_HANDLE

IF (LHOOK) CALL DR_HOOK ('$host$subroutine',0,ZHOOK_HANDLE)
IF (LHOOK) CALL DR_HOOK ('$host$subroutine',1,ZHOOK_HANDLE)

END SUBROUTINE $subroutine
EOF

  $buf->Append ($row-1, @code);

}

sub grok_hostname
{
  my ($class, %args) = @_;

  my $buf = $args{buf};
 
  my $line = $buf->Get (1);

  if ($line && ($line =~ m/(?:MODULE|SUBROUTINE)\s+(\w+)/io))
    {
      return uc ($1);
    }

  return '';
}

1;
