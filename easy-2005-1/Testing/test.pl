#!/usr/bin/perl

use strict;
use warnings;

my $program_path = shift;

opendir D, "./result";
my @files = (grep { ($_ ne ".") && ($_ ne "..") } readdir(D));
closedir(D);

foreach (@files) { unlink($_); }

opendir D, "./in";
my @in_files = (grep { ($_ ne ".") && ($_ ne "..") } readdir(D));
closedir(D);

foreach my $in_file (@in_files)
{
    system($program_path, "./in/$in_file", "./result/$in_file");
}

exit(system("diff", "-u", "-r", "./expected", "./result"));

