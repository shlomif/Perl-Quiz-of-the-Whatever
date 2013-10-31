#!/usr/bin/perl -w

use strict;

use Test::More 'tests' => 31;

use_ok("SailArea"); # TEST

# TEST
ok (
    calc_triangle_area(
        {x => 0, y => 450}, 
        {x => 0, y => 50}, 
        {x => 200, y => 50}
    ) == 40_000, 
    "calc_triangle_area - mainsail example"
);
# TEST
ok (
    calc_triangle_area(
        {x => 0, y => 400}, 
        {x => 150, y => 0}, 
        {x => 0, y => 0}
    ) == 30_000, 
    "calc_triangle_area - jib example"
);
# TEST
ok (
    calc_triangle_area(
        {x => 0, y => 0}, 
        {x => 100, y => 0}, 
        {x => 20, y => 80}
    ) == (100*80/2), 
    "calc_triangle_area - my own test"
);

{    
    my ($n, $a);
    my @lines = (
        "mainsail.a: 0, 450", 
        "mainsail.b: 0, 50", 
        "mainsail.c: 200, 50",
        "jib.a: 0,400",
        "jib.b: 150,0", 
        "jib.c: 0,0",
    );

    my @lines_copy;
    
    @lines_copy = @lines;

    ($n, $a) = process_next_sailboat(\@lines_copy);
    # TEST    
    ok ($a == 40_000);
    # TEST
    ok ($n eq "mainsail");
    # TEST
    ok ($lines_copy[0] eq "jib.a: 0,400");
    # TEST
    ok ($lines_copy[1] eq "jib.b: 150,0");
    # TEST
    ok ($lines_copy[2] eq "jib.c: 0,0");
    # TEST
    ok (scalar(@lines_copy) == 3);


    ($n, $a) = process_next_sailboat(\@lines_copy);
    # TEST
    ok ($a == 30_000);
    # TEST
    ok ($n eq "jib");

    # TEST
    ok (scalar(@lines_copy) == 0);
}

{    
    my @lines = (
        "                    ",
        "        #  helloa thasd ",
        "mainsail.a: 0, 450", 
        "# mainsail.b: 80000, 100000",
        "mainsail.b: 0, 50", 
        "                 ",
        "mainsail.c: 200, 50",
        "jib.a: 0,400",
        "jib.b: 150,0", 
        "jib.c: 0,0",
    );

    my @lines_copy;
    
    @lines_copy = @lines;

    my ($n, $a);
    ($n, $a) = process_next_sailboat(\@lines_copy);
    # TEST
    ok ($a == 40_000);
    # TEST
    ok ($n eq "mainsail");
    # TEST
    ok ($lines_copy[0] eq "jib.a: 0,400");
    # TEST
    ok ($lines_copy[1] eq "jib.b: 150,0");
    # TEST
    ok ($lines_copy[2] eq "jib.c: 0,0");
    # TEST
    ok (scalar(@lines_copy) == 3);
}

# TEST
ok (
    calc_quadrangle_area(
        {x => 0, y => 0,}, 
        {x => 100, y => 0, }, 
        {x => 100, y => 100, },
        {x => 0, y => 100 },
    ) == 10_000, 
    "calc_quadrangle_area - square"
);

# TEST
ok (
    calc_quadrangle_area(
        {x => 0, y => 0,}, 
        {x => 200, y => 0, }, 
        {x => 200, y => 100, },
        {x => 0, y => 100 },
    ) == 20_000, 
    "calc_quadrangle_area - rhomboid"
);

{
    my @points = 
        (
            {x => 0, y => 0}, 
            {x => 50, y => 20}, 
            {x => 100, y => 0},
            {x => 50, y => 100},
        );
    # TEST
    # TEST
    # TEST
    # TEST
    foreach my $i (0 .. 3)
    {
        ok (
            calc_quadrangle_area (
                @points[map { ($_+$i)%4 } (0..3)]
            ) == 4_000,
            "calc_quadrange_area - non-convex permutation $i"
        )
    }
}

{    
    my @lines = (
        "mainsail.a: 0, 450", 
        "mainsail.b: 0, 50", 
        "mainsail.c: 200, 50",
        "rhom.a: 0, 0",
        "rhom.b: 200, 0",
        "rhom.c: 200, 100",
        "rhom.d: 0, 100",
    );

    my @lines_copy;
    my ($n, $a);
    
    @lines_copy = @lines;

    
    ($n, $a) = process_next_sailboat(\@lines_copy);
    # TEST
    ok ($a == 40_000);
    # TEST
    ok ($n eq "mainsail");
    # TEST
    ok (scalar(@lines_copy) == 4);

    ($n, $a) = process_next_sailboat(\@lines_copy);
    # TEST
    ok ($a == 20_000);
    # TEST
    ok ($n eq "rhom");

    # TEST
    ok (scalar(@lines_copy) == 0);
}

