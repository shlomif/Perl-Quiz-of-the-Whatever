use strict;
use warnings;

sub gen_is_divisible_fsm
{
    my $N = shift;

    my @states;

    foreach my $i (0 .. ($N-1))
    {
        my $next_states = [];
        for my $bit (0 .. 1)
        {
            if (($i & 0x1) == $bit)
            {
                push @$next_states, ($i >> 1);
            }
            else
            {
                push @$next_states, (($i+$N)>>1);
            }
        }
        push @states, +{ 'ret' => $i, 'next_states' => $next_states };
    }

    return (0, \@states);
}

1;

