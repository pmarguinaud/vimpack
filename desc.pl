#!/usr/bin/perl -w

use FileHandle;
use strict;

for my $f (@ARGV)
  {
    next unless (my $fh = 'FileHandle'->new ("<$f"));

    my $on = 0;

    while (my $line = <$fh>)
      {
        if ($line =~ m/^=head1 DESCRIPTION/o)
          {
            $on = 1;
            $line = "=pod\n";
          }
        elsif ($on && ($line =~ m/^=head1/o))
         {
            $on = 0;
         }

        print $line if ($on);
      }

    print "\n";
  }

print "=cut\n";
