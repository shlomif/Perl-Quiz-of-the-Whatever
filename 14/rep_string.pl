#!/usr/bin/perl -w

use strict;

#sub repeated_substring
#{
#    my $string = shift;
#    my $longest_substr;
#    for my $start_char (0 .. (length($string)-2))
#    {
#        my $c = substr($string,$start_char,1);
#        my @occurences;
#        my $next_occur=$start_char;
#        while($next_occur=index($string, $c, $next_occur+1)) > 0)
#        {
#            push @occurences 
#        }
#    }
#}

sub repeated_substring
{
    my $string = shift;
    my $high = length($string)/2;
    my $mid;
    my $low = 1;
    my $last_match;
    while ($high >= $low)
    {
        $mid = (($high+$low)>>1);
        if ($string =~ /(.{$mid}).*\1/)
        {
            $low = $mid+1;
            $last_match = $1;
        }
        else
        {
            $high=$mid-1;
        }
    }
    return $last_match;
}

my $filename = shift;
open I, "<$filename" || die "Could not open $filename";
my $text = join("",<I>);
close(I);

my $ret = repeated_substring($text);
if (!defined($ret))
{
    print "None found\n";
}
else
{
    print "$ret\n";
}

