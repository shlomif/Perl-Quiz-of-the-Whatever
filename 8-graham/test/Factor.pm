package Factor;

use strict;

# use Math::GMP qw(:constant);

require Exporter;

use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT = (qw(get_factors get_squaring_factors), 
    qw(get_squaring_factors_from_factors multiply_squaring_factors)
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

# This function multiplies the squaring factors of $n and $m to receive
# the squaring factors of ($n*$m)
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

1;
