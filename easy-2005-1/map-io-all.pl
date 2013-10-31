#!/usr/bin/perl

use strict;
use warnings;
use IO::All;
use Uniq;

io($ARGV[1])->print(uniq(
    sort { $a cmp $b }
    map { my $s = $_; $s=~s{[A-Z]$}{M}; ($_, $s) }
    io($ARGV[0])->getlines()
    ));

