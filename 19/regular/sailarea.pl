#!/usr/bin/perl -w

use strict;
use SailArea;

# Read the parameters
my $filename = shift(@ARGV);
my $scale = scalar(@ARGV) ? (shift(@ARGV)) : "100";

open I, "<$filename" or die "Could not open \"$filename\"";
my @lines;
@lines = (<I>);
close(I);
chomp(@lines);

my $total_area = 0;
while (my ($sailboat_name, $area) = process_next_sailboat(\@lines))
{
    my $scaled_area = ($area * $scale / 100);
    print "${sailboat_name}.area: $scaled_area cm^2\n";
    $total_area += $scaled_area;
}
print "total.area: $total_area cm^2\n";

