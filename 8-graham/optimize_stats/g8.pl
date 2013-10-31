#!/usr/bin/perl -w

use strict;

# use Memoize;

# This function gets the squaring factors of $n.
# The squaring factors are those prime numbers that need to be multiplied
# by $n to reach a perfect square. They are the minimal such number.

my %gsf_cache = (1 => []);

sub get_squaring_factors
{
    my $n = shift;

    if (exists($gsf_cache{$n}))
    {
        return $gsf_cache{$n};
    }

    my $start_from = shift || 2;

    for(my $p=$start_from; ;$p++)
    {
        if ($n % $p == 0)
        {
            # This function is recursive to make better use of the Memoization
            # feature.
            my $division_factors = get_squaring_factors(($n / $p), $p);
            if (@$division_factors && ($division_factors->[0] == $p))
            {
                return ($gsf_cache{$n} = [ @{$division_factors}[1 .. $#$division_factors] ]);
            }
            else
            {
                return ($gsf_cache{$n} = [ $p, @$division_factors ]);
            }
        }
    }
}

# memoize('get_squaring_factors', 'NORMALIZER' => sub { return $_[0]; });

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

sub Graham
{
    my $n = shift;

    my $n_sq_factors = get_squaring_factors($n);

    # The graham number of a perfect square is itself.
    if (scalar(@$n_sq_factors) == 0)
    {
        return "optimized";
        # return ($n, [$n]);
    }

    # Cheating: 
    # Check if between n and n+largest_factor we can fit
    # a square of SqFact{n*(n+largest_factor)}. If so, return
    # n+largest_factor.
    #
    # So, for instance, if n = p than n+largest_factor = 2p
    # and so SqFact{p*(2p)} = 2 and it is possible to see if
    # there's a 2*i^2 between p and 2p. That way, p*2*i^2*2p is
    # a square number.

    {
        my $largest_factor = $n_sq_factors->[$#$n_sq_factors];

        my ($lower_bound, $lb_sq_factors);
        
        $lower_bound = $n + $largest_factor;
        while (1)
        {
            $lb_sq_factors = get_squaring_factors($lower_bound);
            if (grep { $_ == $largest_factor } @$lb_sq_factors)
            {
                last;
            }
            $lower_bound += $largest_factor;
        }

        my $n_times_lb = 
            multiply_squaring_factors($n_sq_factors, $lb_sq_factors);

        my $rest_of_factors_product = 1;

        foreach my $i (@$n_times_lb)
        {
            $rest_of_factors_product *= $i;
        }

        my $low_square_val = int(sqrt($n/$rest_of_factors_product));
        my $high_square_val = int(sqrt($lower_bound/$rest_of_factors_product));
        
        if ($low_square_val != $high_square_val)
        {
            return "optimized";
        }
    }

    return "unopt";
}

my $start = shift;
my $end = shift || $start;
foreach my $n ($start .. $end)
{
    my $val = Graham($n);
    print "$val\n";
    # print "G($n) = " . $g_val . " [" . join(",", @$composition) . "]\n";
}

