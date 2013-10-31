#! /usr/bin/perl -w

use strict;
use integer;

sub allocate_minimal_rooms {
  my ($courses,$slots,$schedule)=@_;

  # remove this and use Math::BigInt if you need to.
  if ($courses>9 || $slots>31) {
    die "need BigInt\n";
  }
  
  # allocate powers-of-two table to avoid excessive shifting later;
  my @pt=(1); # or (Math::BigInt->new(1));
  foreach my $n (1..31) { # (max $courses,$slots)
    push @pt,$pt[-1] << 1;
  }

  # build list of schedule-masks
  my @w;
  foreach my $course (0..$courses-1) {
    my $m=0; # or Math::BigInt->new(0);
    foreach my $slot (0..$slots-1) {
      if ($schedule->[$course][$slot]) {
        $m |= $pt[$slot];
      }
    }
    push @w,$m;
  }
  
  # exhaustively generate masks and test them
  my $rooms=1;
  my @masks;
  my $ok;
  GENERATE:
  while (1) {
    my $count=0;
    my $max=$rooms**$courses;
    foreach my $count (0..$max-1) {
      $ok=1;
      # build a list of masks (one per room)
      @masks=(0) x $rooms;  # or Math::BigInt->new(0);
      my $j=$count;
      foreach my $c (0..$courses-1) {
        $masks[$j % $rooms] |= $pt[$c];
        $j /= $rooms;
      }
      # could check for ordered @masks values here to avoid
      # redundant verifications, but putting in the test actually
      # slowed things down.
      # check for overlapping courses
      VERIFY:
      foreach my $r (0..$rooms-1) {
        my $t=0; # or Math::BigInt->new(0);
        foreach my $m (0..$courses-1) {
          if ($masks[$r] & $pt[$m]) {
            if (($t & $w[$m]) == 0) {
              $t |= $w[$m];
            } else {
              $ok=0;
              last VERIFY;
            }
          }
        }
      }
      if ($ok) {
        last GENERATE;
      }
    }
    $rooms++;
  };

  # convert room list to course list
  my @courseroom;
  foreach my $r (0..$#masks) {
    foreach my $m (0..$courses-1) {
      if ($masks[$r] & $pt[$m]) {
        $courseroom[$m]=$r;
      }
    }
  }
  return \@courseroom;
}


