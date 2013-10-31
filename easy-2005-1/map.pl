#!/usr/bin/perl

use strict;
use warnings;

sub uniq
{
    my $before = undef;
    my @ret;
    foreach my $item (@_)
    {
        if (defined($before) && ($item eq $before))
        {
            # Do Nothing
        }
        else
        {
            push @ret, $item;
            $before = $item;
        }
    }
    return @ret;
}

sub get_lines
{
    my $filename = shift;
    open I, "<", $filename;
    my @lines = (<I>);
    close(I);
    chomp(@lines);
    return @lines;
}

my $in_file = shift(@ARGV);
my $out_file = shift(@ARGV);

my @result = 
    uniq(
        sort { $a cmp $b } 
        map { my $s = $_; $s=~s{[A-Z]$}{M}; ($_, $s) } 
        get_lines($in_file)
    );

open O, ">", $out_file;
print O (map { "$_\n" } @result);
close(O);


