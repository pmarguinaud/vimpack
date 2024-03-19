package ini;

use FileHandle;
use Data::Dumper;
use strict;

sub read
{
  shift;

  my $f = shift;
  
  my @line = do { my $fh = 'FileHandle'->new ("<$f"); <$fh> };
  
  my ($section, $current, $key) = ('') x 3;
  
  my $h = {};
  
  my $push = sub
  {
    return unless (length ($section) && length ($current));
    $h->{$section}{$key} = $current;
    ($current, $key) = ('') x 2;
  };
  
  for my $i (0 .. $#line)
    {
      my $line = $line[$i];
  
      for ($line)
        {
          chomp;
          s/^\s*//o;
          s/ [;#].*//o;
          s/^[;#].*//o;
        }
  
      next unless (length ($line));
  
      if ($line =~ m/^\[(\w+)\]\s*$/o)
        {
          my $s = $1;
          $push->();
          $section = $s;
        }
      elsif ($line =~ s/^(\w+)\s*=\s*//o)
        {
          die unless ($section);
          my $k = $1;
          $push->();
          $key = $k;
          $current = $line;
        }
      else
        {
          $current .= ' ';
          $current .= $line;
        }
  
    }

  return $h;
}

sub write
{
  shift;
  my ($f, $h) = @_;

  my $fh = 'FileHandle'->new (">$f");

  my @key;

  for my $section (sort keys (%$h))
    {
      push @key, sort keys (%{ $h->{$section} });
    }

  my @len = sort { $b <=> $a } map { length ($_) } @key;
  my $len = $len[0];

  for my $section (sort keys (%$h))
    {
      $fh->printf ("[%s]\n", $section);

      next unless (my @key = sort keys (%{ $h->{$section} }));
     
      for my $key (@key)
        {
          $fh->printf ("%-${len}s = %s\n", $key, $h->{$section}{$key});
	}

      $fh->print ("\n");
    }

  $fh->close ();
}

1;
