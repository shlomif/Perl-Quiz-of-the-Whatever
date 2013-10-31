#!/usr/bin/perl -w

use strict;

use Test::More tests => 13;
BEGIN { use_ok('Assign') }; # TEST

sub verify_assignment
{
    my $classes_num = shift;
    my $time_slots_num = shift;
    my $schedule = shift;
    my $assignment = shift;

    foreach my $ts (0 .. ($time_slots_num-1))
    {
        foreach my $c1 (0 .. ($classes_num-1))
        {
            next if (!$schedule->[$c1]->[$ts]);
            foreach my $c2 (($c1+1) .. ($classes_num-1))
            {
                next if (!$schedule->[$c2]->[$ts]);
                if ($assignment->[$c1] == $assignment->[$c2])
                {
                    return "Class $c1 and $c2 were assigned the " .
                        "same teacher while they both study time slot $ts";
                }
            }
        }
    }

    return undef;
}

sub mytest
{
    my $test_id = shift;
    my $classes_num = shift;
    my $time_slots_num = shift;
    my $schedule_string = shift;
    my $minimal_rooms = shift;
    
    my $schedule = [ map { [ split(//, $_) ] } split(/\n/, $schedule_string)];

    my $assignment = 
        allocate_minimal_rooms($classes_num, $time_slots_num, $schedule);

    my $num_assigned = (sort { $b <=> $a } @$assignment)[0]+1;
    ok($minimal_rooms == $num_assigned, "Minimality of $test_id");

    my $verify = 
        verify_assignment(
            $classes_num, $time_slots_num, 
            $schedule, $assignment);

    ok((!defined($verify)), "Verification of $test_id");

    if (defined($verify))
    {
        diag("Test $test_id : $verify");
    }
}

my ($schedule);
$schedule = <<"EOF";
11000
01101
10010
EOF

# TEST
# TEST
mytest("Foo", 3, 5, $schedule, 2);

$schedule = <<"EOF";
11000
01101
10011
EOF

# TEST
# TEST
mytest("Three Courses with three teachers", 3, 5, $schedule, 3);

$schedule = <<"EOF";
101000
011000
000100
000110
000001
EOF

# TEST
# TEST
mytest("Split", 5, 6, $schedule, 2);

$schedule = <<"EOF";
101000
011000
000101
000110
000001
EOF

# TEST
# TEST
mytest("SplitExtra", 5, 6, $schedule, 2);

$schedule = <<"EOF";
101000
011000
000101
000110
000011
EOF

# TEST
# TEST
mytest("SplitThree", 5, 6, $schedule, 3);

$schedule = <<"EOF";
110000
001100
000011
EOF

# TEST
# TEST
mytest("OneIsOK", 3, 6, $schedule, 1);


