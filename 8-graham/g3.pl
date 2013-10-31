#!/usr/bin/perl -w

use strict;

use Factor;

use Math::GMP qw(:constant);

my $n = new Math::GMP(shift);
my $n_sq_factors = get_squaring_factors($n);
print "Non-square Part = " ;
print join(" * ", @$n_sq_factors), "\n";

if (! scalar(@$n_sq_factors))
{
    die "$n is already squared!";
}

my $largest_factor = $n_sq_factors->[$#$n_sq_factors];
my $t;
for($t=1;;$t++)
{
    my $bound = $n + $largest_factor * $t;
    my $bound_factors = get_squaring_factors($bound);
    if ($bound_factors->[$#$bound_factors] != $largest_factor)
    {
        next;
    }
    print "Evaluating the bound $bound\n";
    print join(" * ", @$bound_factors), "\n";
    my $left_factors = multiply_squaring_factors($n_sq_factors, $bound_factors);
    print "Multiply = ", join(" * ", @$left_factors), "\n";

    my $upper_bound = $bound + $largest_factor - 1;

    for my $i (($n+1) .. $upper_bound)
    {
        if ($i == $bound)
        {
            next;
        }
        my $i_sq_factors = get_squaring_factors($i);
        print "$i (" . join(" * ", @$i_sq_factors) . ")\n";
        if (scalar(@$i_sq_factors) == 0)
        {
            next;
        }
        if (are_squaring_factors_a_subset($i_sq_factors, $left_factors))
        {
            print "Multiplying by $i\n";
            print join(" * ", @$i_sq_factors), "\n";
            $left_factors = multiply_squaring_factors($left_factors, $i_sq_factors);
            print "Multiply = ", join(" * ", @$left_factors), "\n";
            if (scalar(@$left_factors) == 0)
            {
                last;
            }
        }
    }
    
    last;
}

