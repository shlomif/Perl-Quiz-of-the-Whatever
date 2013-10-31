#!/usr/bin/perl -w

use strict;

use Factor;

my $set = [2,3,7];
my $subset = [2,7];

my $verdict = are_squaring_factors_a_subset($subset, $set);

print "\$verdict = " . ($verdict ? "True" : "False") . "\n";


