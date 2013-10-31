#!/usr/bin/perl -w

use strict;
use warnings;

my $string = shift(@ARGV);

print rem_periods($string), "\n";

sub rem_periods
{
    my $string = shift;

    my $recurse;

    my @chars = split(//, $string);

    $recurse = sub {
        my ($arg) = (@_);
        my ($rest_of_chars) = [ @$arg];
        if (@$rest_of_chars == 0)
        {
            return ("", 0);
        }
        my $head = shift(@$rest_of_chars);
        my $tail = $rest_of_chars;
        my ($processed_string, $was_period_found) = $recurse->($tail);
        if ($was_period_found)
        {
            return ((($head eq "." ? "" : $head) . $processed_string), 1);
        }
        else
        {
            return ($head . $processed_string, ($head eq "."));
        }
    };

    return +($recurse->([@chars]))[0];
}
