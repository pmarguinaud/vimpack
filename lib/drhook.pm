package drhook;

use strict;

my %cache;

sub read
{
  my $file = shift;

  goto RETURN if ($cache{$file});

  my @line = do { my $fh = 'FileHandle'->new ("<$file"); <$fh> };
  shift (@line) for (1 .. 13); 

  my %Name;

  for my $line (@line)
    {   
      chomp ($line);

      $line =~ s/^\s*(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+//go;
      my ($Rank, $Time, $Cumul, $Self, $Total, $Calls, $SelfPerCall, $TotalPerCall) = ($1, $2, $3, $4, $5, $6, $7, $8);


      $line =~ s/^\*//o;
      my ($Name, $Thread);

      unless (($Name, $Thread) = ($line =~ m/^(.*)\@(\d+)$/o))
        {
          ($Name, $Thread) = ($line, 1); 
        }

      $Name{$Name} = 1;
    }   

  $cache{$file} = \%Name;

  return $cache{$file};
}

1;
