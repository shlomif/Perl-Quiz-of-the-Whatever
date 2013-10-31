#!/usr/bin/perl -w

use strict;

my $N = shift;

sub recurse
{
    my ($string, $num_opened, $num_closed) = (@_);
    if (($num_opened == $N) && ($num_closed == $N))
    {
        print "$string\n";
        return;
    }
    elsif ($num_opened < $N)
    {
        recurse("$string(", $num_opened+1, $num_closed);
    }
    if ($num_opened > $num_closed)
    {
        recurse("$string)", $num_opened, $num_closed+1);
    }
}

recurse("", 0, 0);
