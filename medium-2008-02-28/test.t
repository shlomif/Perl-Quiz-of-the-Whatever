use strict;
use warnings;

use Test::More tests => 5;

my $max_digit = 9;
my $min_digit = 1;

sub _digits_sum_from
{
    my ($start, $sum, $num_places) = @_;

    if ($num_places == 1)
    {
        if (($sum >= $start) && ($sum <= $max_digit))
        {
            return [[$sum]];
        }
        else
        {
            return [];
        }
    }

    my @results;
    FIRST_LOOP:
    foreach my $first ($start .. $max_digit)
    {
        if ($sum-$first <= 0)
        {
            last FIRST_LOOP;
        }
        push @results, 
            (map 
                { [$first,@$_] }
                @{_digits_sum_from($first+1, $sum-$first, $num_places-1)}
            );
    }
    return \@results;
}

sub get_digits_sum
{
    my ($sum, $num_places) = @_;

    return _digits_sum_from($min_digit, $sum, $num_places);
}

# TEST
is_deeply(get_digits_sum(3,2), [[1,2]], "3 over 2");

# TEST
is_deeply(get_digits_sum(7,3), [[1,2,4]], "7 over 3");

# TEST
is_deeply(get_digits_sum(15,5), [[1,2,3,4,5]], "15 over 5");

# TEST
is_deeply(get_digits_sum(25,5),
    [
        [1,2,5,8,9],
        [1,2,6,7,9],
        [1,3,4,8,9],
        [1,3,5,7,9],
        [1,3,6,7,8],
        [1,4,5,6,9],
        [1,4,5,7,8],
        [2,3,4,7,9],
        [2,3,5,6,9],
        [2,3,5,7,8],
        [2,4,5,6,8],
        [3,4,5,6,7],
    ],
    "25 over 5",
);

# TEST
is_deeply(get_digits_sum(14,2), [[5,9],[6,8],], "14 over 2",);

