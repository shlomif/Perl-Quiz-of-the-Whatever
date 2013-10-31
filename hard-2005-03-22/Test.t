#!/usr/bin/perl -w

use strict;
use warnings;

use DivideFsm;

sub run_number
{
    my $start_state = shift;
    my $fsm = shift;
    my $number = shift;

    my $state;

    $state = $start_state;
    while ($number)
    {
        my $bit = ($number & 0x1);
        $number = ($number >> 1);
        $state = $fsm->[$state]->{'next_states'}->[$bit];
    }
    return $fsm->[$state]->{'ret'};
}

sub check_range
{
    my $number = shift;
    my $start_check_num = shift;
    my $end_check_num = shift;
    my ($start_state, $fsm) = gen_is_divisible_fsm($number);
    foreach my $i ($start_check_num .. $end_check_num)
    {
        my $fsm_ret = run_number($start_state, $fsm, $i);
        my $mod_ret = ($i % $number);
        my $ok = (($fsm_ret == 0) eq ($mod_ret == 0));
        if ($ok)
        {
            print "$i % $number OK.\n";
        }
        else
        {
            die "$i % $number Not OK."
        }
    }
}

check_range(3, 0, 50);
check_range(5, 0, 50);
check_range(7, 0, 50);
check_range(9, 0, 50);
check_range(15, 0, 70);
check_range(45, 0, 450);
check_range(3*5*7, 0, 3*5*7*3);

