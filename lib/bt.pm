package bt;

use strict;

sub bt
{ 
  print @_;

  print "\n";
  for (my $i = 0; ; $i++)
    {
      last unless (my @call = caller ($i));
      print " $i ", $call[1], ':', $call[2], "\n";
    }
  die "\n";
}

$SIG{__WARN__} = \&bt;
$SIG{__DIE__} = \&bt;

1;
