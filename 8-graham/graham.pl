#!/usr/bin/perl -w

use strict;

use Factor;

use Math::GMP qw(:constant);


sub find_graham_series
{
    my $n = shift;
    my $final = shift;

    my $product = $n*$final;
    if (&is_perfect_square($product))
    {
        return 1;
    }
    my @bits = (-1) x ($final-$n);
    my @products = ($product);

    my $depth = 1;
    
    while ($depth)
    {
        # print "\$depth=$depth\n";
        # print join(",", @bits), "\n";
        # print join(",", @products), "\n";
        if ($depth == $final-$n)
        {
            if (&is_perfect_square($products[$depth-1]))
            {
                print "factors=" . join(",", $n, (map { $n + $_ } grep { $bits[$_] == 1} (1 .. $depth-1)), $final), "\n";
                return 1;
            }
            $depth--;
        }
        else
        {
            $bits[$depth]++;
            if ($bits[$depth] == 2)
            {
                $bits[$depth] = -1;
                $depth--;
            }
            else
            {
                if ($bits[$depth])
                {
                    $products[$depth] = $products[$depth-1] * ($n+$depth);
                }
                else
                {
                    $products[$depth] = $products[$depth-1];
                }
                $depth++;
            }
        }
    }
    return 0;
}

sub Graham
{
    my $n = shift;

    my $G_n;

    if (&is_perfect_square($n))
    {
        return $n;
    }

    for($G_n = $n+1; ; $G_n++)
    {
        print "Checking $G_n\n";
        if (&find_graham_series($n, $G_n))
        {
            return $G_n;
        }
    }

    return -1;
}

my $n = shift;

print "G($n) = " . Graham($n) . "\n";


