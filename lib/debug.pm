package debug;

use strict;
use Cwd;
use FileHandle;
use Data::Dumper;
use File::Basename;

sub patchbin
{
  my $pack = shift;

  my $cwd = &cwd ();

  chdir ($pack);

  if (chdir ('bin'))
    {
      for my $bin (<*>)
        {
          next unless (-f $bin);
  
          my $f = ".$bin.pl";
          my $fh = 'FileHandle'->new (">$f");
  
          system ("readelf -p .gmkpack $bin > $f");
  
          unless (-s $f)
            {
              my $gmkpack = {pack => $pack, bin => $bin};
      
              local 
                $Data::Dumper::Terse  = 1,
                $Data::Dumper::Indent = 0
              ;
      
              $fh->print ("__PERL__\n\n\n" . &Dumper ($gmkpack) . "\n\n\n");
              $fh->close ();
              chmod (0755, $bin);
              system ('objcopy', '--add-section' => ".gmkpack=$f", $bin);
            }
  
          unlink ($f);
      
        }
      chdir ('..');
    }

  chdir ($cwd);
}

sub link
{
  my $pack = shift;

  my $gmkpack = {pack => $pack};
  
  local 
    $Data::Dumper::Terse  = 1,
    $Data::Dumper::Indent = 0
  ;
  
  my @gmkpack = split (m//o, "__PERL__\n\n\n" . &Dumper ($gmkpack) . "\n\n\n");
  
  my $f = "$pack/.gmkpack.lnk";
  my $fh = 'FileHandle'->new (">$f");

  $fh->print (<< 'EOF');
SECTIONS
{
  .gmkpack :
  {
EOF

  for (@gmkpack)
    {
      $fh->printf ("    BYTE (%d)\n", ord ($_));
    }

  $fh->print (<< 'EOF');
  }
}
INSERT AFTER .text;
EOF

  $fh->close ();


  print "-Wl,-T,$f";

}

sub readbin
{
  my $bin = shift;
  
  my $section = '.gmkpack';
 
  my $f = "/tmp/.$$" . $section . '.' . &basename ($bin);

  my $c = ! system ("readelf -p $section $bin > $f");

  my $X; 

  if ($c && (-s $f))
    {   
      $X = do { local $/ = undef; my $fh = 'FileHandle'->new ("<$f"); <$fh> };
      $X =~ s/^.*?__PERL__//goms;
      $X =~ s/\^J//goms;
      $X = eval $X; 
      if ($@)
        {
          die ($@);
        }
    }   

  unlink ($f);

  return $X; 
}

1;
