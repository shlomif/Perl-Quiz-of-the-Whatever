#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 8;

use Connected_Functional;
# use Julien_Quint;

# TEST
is_deeply(connected([]), [],
    "Empty graph",
);
# TEST
is_deeply(connected([[1,2]]), [[[1,2]]],
    "One edge",
);
# TEST
is_deeply(connected([[1,3],[1,2]]), [[[1,3],[1,2]]],
    "Two connected edges",
);

# TEST
is_deeply(connected([[1,2],[3,4]]), [[[1,2]],[[3,4]]],
    "Two disconnected edges",
);


# TEST
is_deeply(
    connected(
        [[1,2],[3,4],[7,8],[1,3],[5,6],[8,6]]
    ),
    [
        [ [1,2], [3,4], [1,3] ],
        [ [7,8], [5,6], [8,6] ],
    ],
    "Two interleaving components",
);

# TEST
is_deeply(
    connected(
        [[1,2],[3,4],[90,90],[7,8],[1,3],[5,6],[8,6]]
    ),
    [
        [ [1,2], [3,4], [1,3] ],
        [ [90, 90] ],
        [ [7,8], [5,6], [8,6] ],
    ],
    "A self-link",
);

# TEST
is_deeply(
    connected(
        [[2,5],[5,6],[2,4],[8,12],[5,7],[4,9]]
    ),
    [
       [ [2,5], [5,6], [2,4], [5,7],[4,9] ],
       [ [8,12] ],
    ],
    "Funky ordering",
);
# TEST
is_deeply(
    connected(
        [[6,9],[100,102],[1,2],[3,4],[7,8],[1,3],[5,6],[8,6],[102,101]]
    ),
    [
        [ [6,9], [7,8], [5,6], [8,6] ],
        [ [100,102], [102,101], ],
        [ [1,2], [3,4], [1,3] ],

    ],
    "Grand finale",
);


