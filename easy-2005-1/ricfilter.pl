#!/usr/bin/perl -w

use strict;
use warnings;

my $in_file = shift;
my $out_file = shift;

open IN, "<", $in_file;
open OUT, ">", $out_file;

my $prev_prefix = undef;
my $prev_suffix = undef;
my ($prefix, $suffix);
my $line;

while ($line = <IN>)
{
    chomp($line);
    $line =~ /^(\w+)\.([A-Z])$/ or
        die "Invalid line - $line!";

    ($prefix, $suffix) = ($1, $2);

    if ((!defined($prev_prefix)) || 
        ($prev_prefix ne $prefix))
    {
        if (defined($prev_suffix) && ($prev_suffix lt "M"))
        {
            print OUT "$prev_prefix.M\n";
        }
        if ($suffix gt "M")
        {
            print OUT "$prefix.M\n";
        }
    }
    # The prefixes are the same.
    elsif (($suffix gt "M") && ($prev_suffix lt "M"))
    {
        print OUT "$prefix.M\n";
    }
}
continue
{
    print OUT "$line\n";
    $prev_prefix = $prefix;
    $prev_suffix = $suffix;
}

if (defined($prev_prefix) && ($prev_suffix lt "M"))
{
    print OUT "$prev_prefix.M\n";
}

close(IN);
close(OUT);

