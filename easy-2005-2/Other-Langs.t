#!/usr/bin/perl -w

# This file implements various function to remove all periods ("."'s) except
# the last from a string.

use strict;

use Test::More tests => 18;
use String::ShellQuote;

sub via_haskell
{
    my $s = shift;
    my $quoted_s = shell_quote($s);
    my $ret = `runhugs rem-periods.hs $quoted_s`;
    chomp($ret);
    return $ret;
}

sub haskell_pipeline
{
    my $s = shift;
    my $quoted_s = shell_quote($s);
    my $ret = `runhugs pipeline.hs $quoted_s`;
    chomp($ret);
    return $ret;
}

my @funcs = (qw(via_haskell haskell_pipeline));

# This should be TEST * $NUM_TESTS * $NUM_FUNCS
# $NUM_TESTS == 9
# TEST*9*2
foreach my $f (@funcs)
{
    my $ref = eval ("\\&$f");
    is($ref->("hello.world.txt"), "helloworld.txt", "$f - simple"); # 1
    is($ref->("hello-there"), "hello-there", "$f - zero periods"); # 2
    is($ref->("hello..too.pl"), "hellotoo.pl", "$f - double"); # 3
    is($ref->("magna..carta"), "magna.carta", "$f - double at end"); # 4
    is($ref->("the-more-the-merrier.jpg"), 
       "the-more-the-merrier.jpg", "$f - one period"); # 5
    is($ref->("hello."), "hello.", "$f - one period at end"); # 6
    is($ref->("perl.txt."), "perltxt.", "$f - period at end"); # 7
    is($ref->(".yes"), ".yes", "$f - one period at start"); # 8
    is($ref->(".yes.txt"), "yes.txt", "$f - period at start"); # 9
}

