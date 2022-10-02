package Fxtran::XPath;

use strict;

use XML::XPath::Parser;

sub walk_XML_XPath_Expr
{
  (undef, my ($e, $seen)) = @_;

  &walk ($e->{lhs}, $seen);
  &walk ($e->{rhs}, $seen);

  for my $p (@{ $e->{predicates} || [] })
    {
      &walk ($p, $seen);
    }
}

sub walk_XML_XPath_LocationPath
{
  (undef, my ($l, $seen)) = @_;

  for my $p (@$l)
    {
      &walk ($p, $seen);
    }
}

sub walk_XML_XPath_Number
{
}

sub walk_XML_XPath_Root
{
}

sub walk_XML_XPath_Step
{
  (undef, my ($s, $seen)) = @_;

  if (defined ($s->{literal}))
    {
      if ($s->{axis} && ($s->{axis} eq 'attribute') && $s->{literal} && ($s->{literal} eq 'NAME'))
        {
          my $p = 'XML::XPath::Parser'->new ();
     
          my $t = $p->parse ('f:N/f:n/text()');
     
          delete $seen->{$s};
     
          bless ($s, ref ($t));
          %$s = %$t;
     
          &walk ($s, $seen);
          return;
        }
      elsif ($s->{literal} =~ m/^ANY-/o)
        {
          my @p = @{ $s->{predicates} || [] };
          my $p = 'XML::XPath::Parser'->new ();
          (my $type = $s->{literal}) =~ s/^ANY-//o;
          my $size = length ($type);
          my $t = $p->parse ('./f:*[substring(name(),string-length(name())-' . $size . ')="-'.$type.'"]');
          $t = $t->{lhs}[1];

          my ($axis, $axis_method) = @{$s}{qw (axis axis_method)};

          delete $seen->{$s};

          bless ($s, ref ($t));
          %$s = %$t;
          push @{ $s->{predicates} || [] }, @p;

          $s->{axis} = $axis if ($axis);
          $s->{axis_method} = $axis_method if ($axis_method);

          &walk ($s, $seen);
          return;
        }
      elsif (($s->{literal} !~ m/^\w+:/o) && (! $s->{test}))
        {
          $s->{literal} = "f:$s->{literal}";
        }
    }

  for my $p (@{ $s->{predicates} || [] })
    {
      &walk ($p, $seen);
    }

}

sub walk_XML_XPath_Literal
{
}

sub walk_XML_XPath_Function
{
  (undef, my ($f, $seen)) = @_;

  for my $p (@{ $f->{params} || [] })
    {
      &walk ($p, $seen);
    }
}

sub walk
{
  my ($x, $seen) = @_;

  return unless (defined ($x));
  return unless (ref ($x));


  my $class = __PACKAGE__;

  $seen ||= {};

  return if ($seen->{$x}++);

  (my $method = 'walk_' . ref ($x)) =~ s/::/_/go;

  if ($class->can ($method))
    {
      $class->$method ($x, $seen);
    }
  else
    {
      die "Missing $method";
    }
}

my %P;

sub preprocess
{
  my $p = 'XML::XPath::Parser'->new ();
  unless ($P{$_[0]})
    {
      my $x = $p->parse ($_[0]);
      &walk ($x);
      $P{$_[0]} = $x->as_string;
    }
  return $P{$_[0]};
}

1;
