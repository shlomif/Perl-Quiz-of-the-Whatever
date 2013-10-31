#!/usr/bin/perl -w

use strict;

use Assign;

my $in_file = shift || "in.txt";
my $t = Assign->new();
$t->read($in_file);

my $ret = $t->solve();

my $i;
for $i (0 .. $#$ret)
{
    print "Class " . ($i+1) . ": Teacher #" . ($ret->[$i]+1) . "\n";
}

