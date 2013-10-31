#!/usr/bin/perl -w

use strict;

use Test::More tests => 2;

use Sudoko;

{
    my $board = Sudoko::input("board1.txt");
    my @ret = Sudoko::verify($board);
    
    # TEST
    ok(!$ret[0]);
    # TEST
    ok(scalar(@{$ret[1]}) == 0);
}

1;
