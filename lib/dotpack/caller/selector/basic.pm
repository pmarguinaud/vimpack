package dotpack::caller::selector::basic;

use strict;

use base qw (dotpack::caller::selector);

sub new
{
  my $class = shift;
  my %opts = @_;

  if ($opts{'skip-usual'})
    {
      $opts{skip} .= ',' if ($opts{skip});
      $opts{skip} .= join (',', qw (DR_HOOK ABOR1_SFX ABOR1 WRSCMR SC2PRG VERDISINT VEXP NEW_ADD_FIELD_3D ADD_FIELD_3D FMLOOK_LL FIELD_NEW FIELD_DELETE
                                    FMWRIT LES_MEAN_SUBGRID SECOND_MNH ABORT_SURF SURF_INQ SHIFT ABORT LFAECRR FLUSH LFAFER LFAECRI LFAOUV LFAECRC
                                    LFAPRECR NEW_ADD_FIELD_2D ADD_FIELD_2D WRITEPROFILE WRITEMUSC WRITEPHYSIO CONVECT_SATMIXRATIO COMPUTE_FRAC_ICE
                                    TRIDIA LFAPRECI PPP2DUST GET_LUOUT ALLOCATE DEALLOCATE PUT GET SAVE_INPUTS GET_FRAC_N DGEMM SGEMM ABOR1_ACC));
    }

  my $self = bless \%opts, $class;
  $self->{skip} = {map { ($_, 1) } split (m/,/o, $opts{skip})};
  return $self;
}

sub skip
{
  my ($self, $name) = @_;
  return $self->{skip}{$name};
}

sub filter
{
  my ($self, $graph, @unit) = @_;

}

sub getopts
{
  shift;
  my %args = @_;

  push @{$args{opts_s}}, qw (skip);
  push @{$args{opts_f}}, qw (skip-usual);
  %{$args{opts}} = (%{$args{opts}}, 
                      qw (
                        rankdir    LR
                        selector   basic
                        colorizer  basic
                        content    basic
                        ), skip => '');

}

1;
