#!/usr/bin/perl -w

use strict;

use Factor;

# use Math::GMP qw(:constant);

my $n = shift;
my $factors = get_factors($n);
my $sq_factors = get_squaring_factors_from_factors($factors);
print "Factoring = ";
print join(" * ", map { $_->{'p'} . "^" . $_->{'e'} } @$factors), "\n";
print "Non-square Part = " ;
print join(" * ", @$sq_factors), "\n";

