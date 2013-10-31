use Test::More 'no_plan';

my $prog = shift or die "Usage: $0 libfile.pl\n";
do $prog;
die "Couldn't find 'allocate_minimal_rooms()'\n"
  unless defined(&allocate_minimal_rooms);

$/ = "";

while (<DATA>) {
  chomp;
  my @rows = split /\n/, $_;
  my $x = pop @rows;
  $_ = [split /\s+/] for @rows;
  my ($n_courses, $n_slots) = (scalar(@rows), scalar(@{$rows[0]}));
  my $result = allocate_minimal_rooms($n_courses,
                                      $n_slots,
                                      \@rows,
                                     );
  is(scalar(@$result), $n_courses, "test $.: one room per course");

  my (%room_name, @allocation, $dbl_allocated);
  for my $course_n (0 .. $n_courses-1) {
    my $room = $result->[$course_n];
    $room_name{$room} = 1;
    for my $slot_n (0 .. $n_slots-1) {
      my $n_bookings = 
        $allocation[$room][$slot_n] += $rows[$course_n][$slot_n];
      if ($n_bookings > 1) {
        ok(0, "room $room was double-allocated during time slot $slot_n\n");
        $dbl_allocated = 1;
      }
    }
  }
  ok(1, "test $.: no double allocations") unless $dbl_allocated;

  my $n_rooms = keys %room_name;
  my $bad_room_name;
  is($n_rooms, $x, "test $.: correct number of rooms");
  for (0 .. $n_rooms-1) {
    unless (exists $room_name{$_}) {
      ok(0, "test $.: room '$_' is missing from result");
      $bad_room_name = 1;
    }
  }
  ok(1, "test $.: correct room names") unless $bad_room_name;
}

__DATA__
1 1 1 1 1
1

1 0 1
0 1 0
1

1 0 1
0 1 1
2

0 1 1
1 0 1
2

1 0 0 1 0
0 1 0 0 1
0 0 1 0 1
0 0 1 1 0
2

1 0 0 1 0
0 0 1 0 1
0 1 0 0 1
0 0 1 1 0
2

1 0 0 1 0
0 0 1 1 0
0 0 1 0 1
0 1 0 0 1
2

0 0 1 1 0
1 0 0 1 0
0 0 1 0 1
0 1 0 0 1
2

0 0 1 1 0
0 1 0 0 1
1 0 0 1 0
0 0 1 0 1
2

0 0 1 1 0
0 1 0 0 1
0 0 1 0 1
1 0 0 1 0
2

0 0 1 1 0
0 0 1 0 1
0 1 0 0 1
1 0 0 1 0
2

0 0 1 0 1
0 1 0 0 1
0 0 1 1 0
1 0 0 1 0
2

1 1 0 0 0
0 1 1 0 1
1 0 0 1 0
2


