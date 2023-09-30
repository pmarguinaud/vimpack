package dotpack::graphv;

use strict;

use dotpack::caller;
use dotpack::struct;

sub new
{
  my $class = shift;
  my %opts = @_;
  ($class = $opts{class}) or die;
  $class = 'dotpack::' . $class;
  my $self = $class->new (%opts);
  return $self;
}

sub getopts
{
  shift;
  my %args = @_;
  'dotpack::caller'->getopts (%args);
  'dotpack::struct'->getopts (%args);
}

sub getsubopts
{
  my $Class = shift;

  my %args = @_;
 
  (my $file = $Class) =~ s,::,/,go;
  (my $dir = $INC{"$file.pm"}) =~ s/\.pm$//o;
  use File::Find;

  my @pm;
  &find ({wanted => sub { my $f = $File::Find::name; push @pm, $f if ($f =~ m/\.pm$/o); }, 
          no_chdir => 1}, $dir);

  my @class;
  for (@pm)
    {
      s,\.pm$,,o;
      s,^$dir,,o;
      s,/,::,go;
      push @class, "$Class$_";
    }

  for my $class (sort @class)
    {
      $class->getopts (%args);
    }
}

1;
