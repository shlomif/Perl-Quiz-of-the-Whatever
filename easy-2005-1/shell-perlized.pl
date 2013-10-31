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

my @file_lines = get_lines($in_file);

my @added_Ms = 
    (map { "$_.M" } 
        (uniq(
            map { /^(\w+)\.[A-Z]$/; $1; } 
                @file_lines
            )
        )
    );

my @total_lines = (@added_Ms, @file_lines);

my @result = uniq(sort { $a cmp $b } @total_lines);

open O, ">", $out_file;
print O (map { "$_\n" } @result);
close(O);


