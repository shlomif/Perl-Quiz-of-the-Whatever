#!/usr/bin/perl -w

use strict;

use Factor;

use Math::GMP;

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

    my $indicators;
    my $indicators_top = (1 << scalar(@$left_factors));
    for($indicators=0;$indicators<$indicators_top;$indicators++)
    {
        my $filtered_sq_factors = [(map { $left_factors->[$_] } (grep { $indicators & (1 << $_) } (0 .. $#$left_factors))) ];
        my $filtered_number = get_squaring_value_from_factors($filtered_sq_factors);
        if (int_square_root($n/$filtered_number) != int_square_root($upper_bound/$filtered_number))
        {
            print "Can Form $filtered_number (" . join(" * ", @$filtered_sq_factors) . ")\n";
        }
    }

    last;
}

