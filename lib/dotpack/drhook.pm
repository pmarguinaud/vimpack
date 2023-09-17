package dotpack::drhook;

use strict;

use base qw (dotpack::caller);

sub new
{
  my $class = shift;
  my %opts = @_;
  my $self = $class->SUPER::new (%opts);
  $self->readDrHook ();
  return $self;
}

sub readDrHook
{
  my $self = shift;

  my $file = $self->{drhook};

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

  $self->{drhook} = \%Name;
}

sub skip
{
  my ($self, $unit) = @_;
  return ((! $self->{drhook}{$unit}) || $self->SUPER::skip ($unit));
}

sub pruneGraph
{
  my ($self, @unit) = @_;
  
  my %seen;

  my $walk;

  $walk = sub
  {
    my $k = shift;
    return if ($self->skip ($k));
    return if ($seen{$k}++);
    for my $v (@{ $self->{graph}{$k} })
      {
        $walk->($v);
      }
  };

  $walk->($_) for (@unit);

  for my $k (keys (%{ $self->{graph} }))
    {
      next if ($seen{$k});
      delete $self->{graph}{$k};
    }

}

sub graph
{
  my ($self, @unit) = @_;

  $self->createGraph (@unit);

  $self->pruneGraph (@unit);

  $self->renderGraph ();
}

1;
