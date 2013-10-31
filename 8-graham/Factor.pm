package Factor;

use strict;

# use Math::GMP qw(:constant);

require Exporter;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT = (qw(get_factors get_squaring_factors), 
    qw(get_squaring_factors_from_factors get_squaring_value), 
    qw(multiply_squaring_factors int_square_root is_perfect_square),
    qw(are_squaring_factors_a_subset get_squaring_value_from_factors),
    );

# This function get the factors (prime number+exponent) of $i.
sub get_factors
{
    my $n = shift;

    my ($p, @factors, $e);
    for($p=2;$n > 1;$p++)
    {
        if ($n % $p == 0)
        {
            $e = 0;
            while ($n % $p == 0)
            {
                $e++;
                $n /= $p;
            }
            push @factors, { 'p' => $p, 'e' => $e };
        }
    }

    return \@factors;
}


sub get_squaring_factors_from_factors
{
    my $factors = shift;
    return [ (map { $_->{'p'} } grep {$_->{'e'} % 2 } @$factors) ];
}

# This function gets the squaring factors of $n.
# The squaring factors are those prime numbers that need to be multiplied
# by $n to reach a perfect square. They are the minimal such number.
sub get_squaring_factors
{
    my $n = shift;
    return get_squaring_factors_from_factors(get_factors($n));
}

sub get_squaring_value
{
    my $n = shift;
    return get_squaring_value_from_factors(get_squaring_factors($n));
}

sub get_squaring_value_from_factors
{
    my $factors = shift;

    my $product = 1;
    
    foreach my $i (@$factors)
    {
        $product *= $i;
    }

    return $product;
}

sub multiply_squaring_factors
{
    my $n_ref = shift;
    my $m_ref = shift;

    my @n = @$n_ref;
    my @m = @$m_ref;

    my @ret = ();

    while (scalar(@n) && scalar(@m))
    {
        if ($n[0] == $m[0])
        {
            shift(@n);
            shift(@m);
        }
        elsif ($n[0] < $m[0])
        {
            push @ret, shift(@n);
        }
        else
        {
            push @ret, shift(@m);
        }
    }
    push @ret, @n, @m;
    return \@ret;
}

sub are_squaring_factors_a_subset
{
    my $subset_ref = shift;
    my $set_ref = shift;

    my @subset = @$subset_ref;
    my @set = @$set_ref;

    while (scalar(@subset) && scalar(@set))
    {
        if ($set[0] == $subset[0])
        {
            shift(@set);
            shift(@subset);
        }
        elsif ($subset[0] < $set[0])
        {
            return 0;
        }
        else
        {
            shift(@set);
        }
    }

    return (scalar(@subset) == 0);
}

sub int_square_root
{
    my $n = shift;

    my $left = 1;
    my $right = $n;

    my $mid;

    my $is_above;
    my $is_below;

    my $calc_all = sub {
        $mid = int(($left+$right)/2);

        $is_below = (($mid*$mid) <= $n);
        $is_above = ((($mid+1)*($mid+1)) > $n);
    };

    $calc_all->();

    while (! ($is_above && $is_below))
    {
        if ($is_below)
        {
            $left = $mid;
        }
        else
        {
            $right = $mid;
        }
        $calc_all->();
    }
    return $mid;
}

sub is_perfect_square
{
    my $n = shift;

    my $root = int_square_root($n);

    return ($n == ($root*$root));
}

1;

