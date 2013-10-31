#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

package Graph;

# This is a very simplified class representing a graph just for this purpose.

sub new {
    my $g = bless({}, shift);

    $g->vertices(0);
    $g->alists([]);

    return $g;
} # sub Graph::new
#------------------------------------------------------------------------------
sub _property {
    my $self   = shift;    # Object
    my $attr   = shift;    # attribute to get or set
    my $setter = @_ == 1;  # Is the method a setter?
    my $value  = shift;    # value (if setter)

    # If we would use "if (defined $value)" here, we couldn't set a attribute
    # to undef, so this form is used:
    if ($setter) {
        my $old_value = $self->{$attr};
        $self->{$attr} = $value;
        return $old_value;
    }
    else {
        return $self->{$attr};
    }
} # sub Graph::_property
#------------------------------------------------------------------------------
sub vertices { return shift->_property('vertices', @_) }
sub alists   { return shift->_property('alists',   @_) }
#------------------------------------------------------------------------------
sub color {
    my $self      = shift;
    my $algorithm = shift;
    my @colors    = ();

    return @colors unless $self->vertices();

    for (0..$self->vertices()-1) {
        push @colors, -1;
    }

    if ($algorithm eq 'backtracking') {
        # calculate upper limit with greedy:
        my @colgreedy = $self->color('greedy');
        my $maxcolor  = 0;
        for (@colgreedy) {
            $maxcolor = $_ if $_ > $maxcolor;
        }
        # stepping down until no better solution can be found:
        my $success = 1;
        my $colref_old = \@colgreedy;
        while ($success) {
            --$maxcolor;
            my @bcolors;
            push @bcolors, -1 for (0..$self->vertices()-1);
            $success = $self->_kBacktracking($maxcolor, \@bcolors);
            if ($success) {
                $colref_old = [ @bcolors ];
            }
        }
        $colors[$_] = $colref_old->[$_] for (0..$self->vertices()-1);
    }
    elsif ($algorithm eq 'simple') {
        $colors[0] = 0;
        for my $v (1..$self->vertices()-1) {
            $colors[$v] = 0;
            while ($self->_has_neighbour_with_color($v, $colors[$v], \@colors)) {
                ++$colors[$v];
            }
        }
    }
    elsif ($algorithm eq 'greedy') {
        $_ = 0 for @colors;
        my $color   = 0;
        my $counter = 0;
        while ($counter < $self->vertices()) {
            ++$color;
            for my $v (0..$self->vertices()-1) {
                if ($colors[$v] < 1 and $colors[$v] != -$color) {
                    $colors[$v] = $color;
                    ++$counter;
                    for my $n ( @{ $self->alists()->[$v] } ) {
                        $colors[$n] = -$color if $colors[$n] < 1;
                    }
                }
            }
        }
        --$_ for @colors; # Fängt bei Null an!
    }
    else {
        die "unknown algorithm '$algorithm'";
    }

    return @colors;
} # sub Graph::color
#------------------------------------------------------------------------------
sub _has_neighbour_with_color {
    my $self   = shift; # object
    my $v      = shift; # vertex
    my $col    = shift; # color number
    my $colors = shift; # reference to color array

    for my $n ( @{ $self->alists()->[$v] } ) {
        return 1 if $$colors[$n] == $col;
    }

    return 0;
} # sub Graph::_has_neighbour_with_color
#------------------------------------------------------------------------------
sub _kBacktracking {
    my $self = shift; # object
    my $k    = shift; # color number
    my $c    = shift; # reference to color array

    die "_kBacktracking : Farbe $k zu klein." if $k < 0;

    return $self->_btcTry(0, $k, $c);
} # sub $self->_kBacktracking
#------------------------------------------------------------------------------
sub _btcTry {
    my $self  = shift; # object
    my $i     = shift; # vertex number
    my $k     = shift; # color number
    my $c     = shift; # reference to color array

    my $n     = $self->vertices();
    my $color = -1;
    my $q     = 0;


    die "_btcTry : vertex i = $i is not valid (valid is: [0, " . ($n-1) . "])"
        if $i >= $n;
    die "_btcTry : color k = $k is not valid (valid is: [0, " . ($n-1) . "])"
        if $k < 0 or $k >= $n;

    while (not $q and $color != $k) {
        ++$color;
        last if $i == 0 and $color > 0;
        if ($self->_btcPossible($i, $color, $c)) {
            $c->[$i] = $color;
            if ($i < $n-1) {
                $q = $self->_btcTry($i+1, $k, $c);
                $c->[$i] = -1 unless $q;
            }
            else {
                $q = 1;
            }
        }
    }

    return $q;
} # sub _btcTry
#------------------------------------------------------------------------------
sub _btcPossible {
    my $self  = shift; # object
    my $i     = shift; # vertex number
    my $color = shift; # color number
    my $c     = shift; # reference to color array

    for my $n (@{ $self->alists()->[$i] }) {
        return 0 if $c->[$n] == $color;
    }

    return 1;
} # sub _btcPossible


package main;

#Today's quiz and next Monday's solution come courtesy of Pr. Shlomi Fish.
#Thank you, Shlomi!
#
#
#        You will write a program that schedules the semester of courses at
#        Haifa University.  @courses is an array of course names, such as
#        "Advanced Basket Weaving".  @slots is an array of time slots at which
#        times can be scheduled, such as "Monday mornings" or "Tuesdays and
#        Thursdays from 1:00 to 2:30".  (Time slots are guaranteed not to
#        overlap.)
#
#        You are also given a schedule which says when each course meets.
#        $schedule[$n][$m] is true if course $n meets during time slot $m,
#        and false if not.
#
#        Your job is to write a function, 'allocate_minimal_rooms', to allocate
#        classrooms to courses.  Each course must occupy the same room during
#        every one of its time slots.  Two courses cannot occupy the same room
#        at the same time.  Your function should produce a schedule which
#        allocates as few rooms as possible.
#
#        The 'allocate_minimal_rooms' function will get three arguments:
#
#          1. The number of courses
#          2. The number of different time slots
#          3. A reference to the @schedule array
#
#        It should return a reference to an array, say $room, that
#        indicates the schedule.  $room->[$n] will be the number of the
#        room in which course $n will meet during all of its time
#        slots.  If courses $n and $m meet at the same time, then
#        $room->[$n] must be different from $room->[$m], because the
#        two courses cannot use the same room at the same time.
#
#        For example, suppose:
#
#            Time slots
#            0  1  2  3  4
#
#  Courses
#        0   X  X                (Advanced basket weaving)
#        1      X  X     X       (Applied hermeneutics of quantum gravity)
#        2   X        X          (Introduction to data structures)
#
#
#        The @schedule array for this example would contain
#
#        ([1, 1, 0, 0, 0],
#         [0, 1, 1, 0, 1],
#         [1, 0, 0, 1, 0],
#        )
#
#        'allocate_minimal_rooms' would be called with:
#
#                allocate_minimal_rooms(3, 5, \@schedule)
#
#        and might return
#
#        [0, 1, 1]
#
#        indicating that basket weaving gets room 0, and that applied
#        hermeneutics and data structures can share room 1, since they
#        never meet at the same time.
#
#        [1, 0, 0]
#
#        would also be an acceptable solution, of course.

sub main ();
sub allocate_minimal_rooms ($$$);


main();
exit;


sub main () {
    my @courses = (
                   'Advanced basket weaving',
                   'Applied hermeneutics of quantum gravity',
                   'Introduction to data structures'
                  );

    my @slots   = (
                   'Monday morning _very_ early :-D',
                   'Tuesday',
                   'We. 10:00 to 12:00',
                   'Th. 19:00 to 20:00',
                   'Friday evening',
                  );

    my @schedule = (
                    [1, 1, 0, 0, 0],
                    [0, 1, 1, 0, 1],
                    [1, 0, 0, 1, 0],
                   );

    my $rooms = allocate_minimal_rooms(scalar @courses,
                                       scalar @slots,
                                       \@schedule);

    for my $rind (0..$#$rooms) {
        print "course '$courses[$rind]' meets in room ", @{$rooms}[$rind], ".\n";
    }
} # sub main


sub allocate_minimal_rooms ($$$) {
    my $nrofcourses = shift;
    my $nrofslots   = shift;
    my $schedule    = shift;

    #
    # first caculating minimal overlap:
    # (only for a minimum value, jfyi)
    #
    if (0)
    {
        my @minlapslots;
        my $min = 1;
        for my $sind (0..$nrofslots-1) {
            $minlapslots[$sind] = 0;
            for my $cind (0..$nrofcourses-1) {
                $minlapslots[$sind] += $schedule->[$cind][$sind];
            }
            $min = $minlapslots[$sind] if $min < $minlapslots[$sind];
        }
        print "We need at least $min rooms.\n";

        print Dumper(\@minlapslots);
    }

    # This problem is NP complete. It's analog to the problem of coloring the
    # vertices of a graph with the minimum number of colors.
    #
    # And about this problem and solutions for it I wrote my degree
    # dissertation in graph theory.
    #
    # Thusfor I transform the problem to a graph, where each vertex stands for
    # one course and an edge stands for a slot, in which both of the adjacent
    # vertexes (=courses) will meet:

    my $graph = new Graph;
    $graph->vertices($nrofcourses);
    my $alists = $graph->alists();

    for my $cind (0..$nrofcourses-1) {
        $graph->alists()->[$cind] = [];
        for my $cind2 (0..$nrofcourses-1) {
            next if $cind == $cind2;
            for my $sind (0..$nrofslots-1) {
                if (
                    $schedule->[$cind ][$sind] and
                    $schedule->[$cind2][$sind]
                   )
                {
                    push @{$graph->alists()->[$cind]}, $cind2;
                }
            }
        }
    }
    print Dumper($graph);

    #
    # Now we could use any algorithm we want to color the graph, if we want
    # the exact minimal number of rooms, we have to use backtracking.
    # Else we could use any heuristic algorithm we want, as greedy for example.
    # The first one will be exact, the latter one much faster.
    #
    # In my degree dissertation I discussed many algorithms (but I used C++
    # and not Perl). If anyone here is interessted, I could post more
    # algorithms.
    #

    # Color the graph:
    my @rooms = $graph->color('backtracking');
    #my @rooms = $graph->color('greedy');
    #my @rooms = $graph->color('simple');


    return \@rooms;

    # This was a very mathematical way of solving the given problem:
    # transforming it in a problem I solved before and solve that ;-)
    # Thusfore a "direct" transformation of the backtracking algorithm to the
    # form of the given problem would perhaps be faster, but I wanted to show
    # the interrelation of the given problem to graph theory.

    # NP complete problems like this one won't be solved by an exact algorithm
    # with polynomial complexity. If you find such an algorithm, you will get
    # rich :-D Because if you solve any of the NP complete Problems, you have
    # solved _all_ of them, including Traveling Salesman Problem and much more.

} # allocate_minimal_rooms
