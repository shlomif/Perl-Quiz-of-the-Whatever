package Sudoko;

use strict;
use warnings;

sub verify
{
    my $board = shift;

    my @flattened_board = (map { @$_ } @$board);

    my $verify_set = sub {
        my $coords = shift;
        my @numbers = @flattened_board[map { $_->[0] + $_->[1] * 9 } @$coords];
        my @sorted = sort { $a <=> $b } @numbers;
        for(my $i=1;$i<=9;$i++)
        {
            if (shift(@sorted) ne $i)
            {
                return 1;
            }
        }
        return 0;
    };

    my $i;
    my @errors;
    for($i=0;$i<9;$i++)
    {
        if ($verify_set->([ map { [$_, $i] } (0 .. 8) ]))
        {
            push @errors, "Row $i";
        }
        if ($verify_set->([ map { [$i, $_] } (0 .. 8) ]))
        {
            push @errors, "Column $i";
        }
        my ($x,$y) = (int($i/3),$i%3);
        if ($verify_set->([
            map { 
                my $xx = $_; 
                map { [ $xx, $_] } (($y*3) .. ($y*3+2)) 
            } (($x*3) .. ($x*3+2))
        ]))
        {
            push @errors, "Sub-square ($x,$y)";
        }
    }
    return ((@errors > 0), \@errors);
}

sub input
{
    my $filename = shift;
    open my $file, "<", $filename;
    my @lines = (<$file>);
    close($file);
    chomp(@lines);
    return [ map { [ split(/,/, $_) ] } @lines[0 .. 8] ];
}

1;

