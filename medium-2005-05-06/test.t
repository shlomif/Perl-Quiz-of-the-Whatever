#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 26;

use WithMatchSet;

sub get_set
{
    my $ret = shift;
    return [ sort { $a <=> $b } keys(%{$ret->{'match_set'}})];
}

sub ok_matches
{
    my ($ret, $matches, $msg) = @_;
    is_deeply(get_set($ret), $matches, $msg);
}

{
    my $handle = prepare_ranges_handle([[0,10]]);
    my $ret = lookup_ranges($handle, 3);
    # TEST
    ok($ret->{'verdict'}, "Verdict 1");
    # TEST
    ok_matches($ret, [0], "Matching Sets");
    $ret = lookup_ranges($handle, -5);
    # TEST
    ok(! $ret->{'verdict'}, "Verdict 2");
    $ret = lookup_ranges($handle, 72);
    # TEST
    ok(! $ret->{'verdict'}, "Verdict 3");
}

{
    my $handle = prepare_ranges_handle([[0,10], [5, 15]]);
    my $ret = lookup_ranges($handle, 6);
    # TEST
    ok($ret->{'verdict'}, "Verdict 1");
    # TEST
    ok_matches($ret, [0,1], "Matching Sets");
    $ret = lookup_ranges($handle, -5);
    # TEST
    ok(! $ret->{'verdict'}, "Verdict 2");
    $ret = lookup_ranges($handle, 72);
    # TEST
    ok(! $ret->{'verdict'}, "Verdict 3");
    $ret = lookup_ranges($handle, 3);
    # TEST
    ok_matches($ret, [0], "In 0 but not in 1");
    $ret = lookup_ranges($handle, 12);
    # TEST
    ok_matches($ret, [1], "In 1 but not in 0");
}

{
    my $handle = prepare_ranges_handle([[0,10], [20, 30]]);
    my $ret = lookup_ranges($handle, 3);
    # TEST
    ok($ret->{'verdict'}, "Verdict 1");
    # TEST
    ok_matches($ret, [0], "Matching Sets");
    $ret = lookup_ranges($handle, -5);
    # TEST
    ok(! $ret->{'verdict'}, "Verdict 2");
    $ret = lookup_ranges($handle, 72);
    # TEST
    ok(! $ret->{'verdict'}, "Verdict 3");
    $ret = lookup_ranges($handle, 23.4);
    # TEST
    ok($ret->{'verdict'}, "Verdict 4");
    # TEST
    ok_matches($ret, [1], "Matches set #1");
    # TEST
    ok(!lookup_ranges($handle, 17)->{'verdict'}, "In between");
}


{
    my $handle = prepare_ranges_handle([[0,10], [20, 30], [2, 8]]);
    my $ret = lookup_ranges($handle, 3);
    # TEST
    ok($ret->{'verdict'}, "Verdict 1");
    # TEST
    ok_matches($ret, [0, 2], "Matching Sets 3 in [0,10],[20,30],[2,8]");
    $ret = lookup_ranges($handle, -5);
    # TEST
    ok(! $ret->{'verdict'}, "Verdict 2");
    $ret = lookup_ranges($handle, 72);
    # TEST
    ok(! $ret->{'verdict'}, "Verdict 3");
    $ret = lookup_ranges($handle, 23.4);
    # TEST
    ok($ret->{'verdict'}, "Verdict 4");
    # TEST
    ok_matches($ret, [1], "Matches set #1");
    $ret = lookup_ranges($handle, 0.5);
    # TEST
    ok_matches($ret, [0], "Matching Sets 0.5 in [0,10],[20,30],[2,8]");
    # TEST
    ok_matches(lookup_ranges($handle, 9), [0], 
        "Matching Sets 9 in [0,10],[20,30],[2,8]");
    # TEST
    ok(!lookup_ranges($handle, 15)->{'verdict'}, 
        "Verdict 15 in [0,10],[20,30],[2,8]");    
}

