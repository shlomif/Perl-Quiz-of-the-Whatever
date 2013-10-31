#!/usr/bin/perl -w

# This file implements various functions to remove all periods ("."'s) except
# the last from a string.

use strict;

use Test::More tests => 72;
use String::ShellQuote;

sub via_split
{
    my $s = shift;
    my @components = split(/\./, $s, -1);
    if (@components == 1)
    {
        return $s;
    }
    my $last = pop(@components);
    return join("", @components) . "." . $last;
}

sub sexeger
{
    my $s = shift;
    $s=reverse($s);
    my $c = 0;
    $s=~s!\.!($c++)?"":"."!ge;
    return reverse($s);
}

sub two_parts
{
    my $s = shift;
    if ($s =~ /^(.*)\.([^\.]*)$/)
    {
        my ($l, $r) = ($1, $2);
        $l =~ tr/.//d;
        return "$l.$r";
    }
    else
    {
        return $s;
    }
}

sub look_ahead
{
    my $s = shift;
    $s =~ s/\.(?=.*\.)//g;
    return $s;
}

sub count_and_replace
{
    my $s = shift;
    my $count = (my @a = ($s =~ /\./g));
    $s =~ s/\./(--$count)?"":"."/ge;
    return $s;
}

sub elim_last
{
    my $s = shift;
    my $non_occur = "\x{1}" . ("\0" x length($s)) . "\x{1}";
    $s =~ s/\.([^\.]*)$/$non_occur$1/;
    $s =~ tr/.//d;
    $s =~ s!$non_occur!.!;
    return $s;
}

sub rindex
{
    my $s = shift;
    substr($s, 0, rindex($s, ".")) =~ tr/.//d;
    return $s;
}

sub recursive_perl
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

my @funcs = (qw(via_split sexeger two_parts look_ahead count_and_replace),
    qw(elim_last rindex recursive_perl));

# TEST:$num_tests=9
# TEST:$num_funcs=8
# TEST*$num_tests*$num_funcs
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

