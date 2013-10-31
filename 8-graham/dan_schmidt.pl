use Memoize;
use strict;

# Options:
#  - Set $verbose to 1 to see everything it's thinking.  This was really handy
#    in debugging it and speeding it up, but it's also just fun to turn it on
#    and see it in action.
#  - Set $fast to 0 if you want it to actually generate a sequence for primes
#    rather than just using the fact that G(p) = 2p for p prime > 3.
#  - Set $print_sequence to 1 if you want to see the sequence it finds.

my $verbose = 0;                # print out all throught processes
my $fast = 1;                   # cheat when n is prime
my $print_sequence = 0;         # print out sequence when done

sub max {
  my $max = shift;
  foreach my $elt (@_) { $max = $elt if $max < $elt; }
  return $max;
}

sub numerically { $a <=> $b; }

# This code will be doing a lot of dealing with what I decided to call
# 'parity factorizations'.  A parity factorization is just the prime
# factorization you get after dividing out all the squares you can
# from the original number; all the remaining factors will occur exactly
# once.  The parity factorization has no elements iff the number is a square.
#
# The handy thing about them is that multiplying two numbers just adds
# their parity factorizations, which is also the same thing as
# subtracting their partiy factorizations.  So if I have a number with
# a parity factorization of {3}, I just have to find another one with
# a parity factorization of {3} in order for their product to be a
# square; no matter that the other number might actually be 2^4 * 3 *
# 19^2 or what have you.

# Parity factorizations are represented by hashes with the factors
# as the keys.

# add_factor( \%factors, $n ) adds a new factor $n to %factors.  Of course,
# if %factors already had $n as a key, it is deleted instead.

sub add_factor {
  my ($factors, $n) = @_;
  if (exists $factors->{$n}) {
    delete $factors->{$n};
  } else  {
    $factors->{$n} = 1;
  }
}

# add_factor_set( \%lhs, \%rhs ) basically does %lhs += %rhs.
# We occasionally use the fact that adding parity factorizations
# is equivalent to subtracting them.

sub add_factor_set {
  my ($lhs, $rhs) = @_;
  for my $f (keys %$rhs) {
    add_factor( $lhs, $f );
  }
}

# factorization( $n ) returns two values: the parity factorization of
# $n, and whether $n is prime.

sub factorization {
  my %factors;
  my $i = 2;
  my $n = shift;
  my $prime = 1;
  while ($i * $i <= $n) {
    if ($n % $i == 0) {
      add_factor( \%factors, $i );
      $n /= $i;
      $prime = 0;
    } else {
      ++$i;
    }
  }
  add_factor( \%factors, $n );
  return (\%factors, $prime);
}
memoize( 'factorization' );

# My own hash of &factorization results, so that I call &factorization
# exactly once for each number during a given call to &Graham.  The
# memoization above is just to speed up calls on subsequent calls to
# &Graham within a single run.
my %factorization;

# See the description down in &match.
my %bad_number_sets;

sub Graham {
  my $n = shift;
  return 1 if $n == 1;          # special case

  # The proof that the following shortcut is valid is left as an exercise
  # for the reader.  (Yes, I proved it myself.)
  my ($factors, $prime) = factorization( $n );
  return $n * 2 if $fast && $prime && $n > 3;

  # We just start at the lowest possible guess and work our way up
  # until we find one that's okay.  We can at least skip over some
  # obviously bad guesses, using the following method: some number
  # between $n and the $guess must 'pair off' each of $n's 'parity
  # factors', so we choose the largest parity factor and set $guess
  # equal to the lowest number that can pair it off.
  my $guess = $n + max( keys %$factors );

  # Populate %factorization
  for my $i ($n..$guess-1) {
    my ($f, $prime) = factorization( $i );
    $factorization{$i} = $f;
  }

  return $n if scalar keys %{$factorization{$n}} == 0; # square

  $guess++ while !guess_ok( $n, $guess );
  return $guess;
}

# Magic global variables that hold our current state.
# I used to make modified copies of these and pass them into
# recursive calls; now, for speed, I just keep a single copy
# and undo the updates when we pop out of a recursive call.
# See descriptions where they are populated in &guess_ok.
my @numbers;
my %factors_needing_pairing;
my %factor_occurrences;

sub guess_ok {
  my ($n, $guess) = @_;
  print "Trying $n -> $guess\n" if $verbose;

  # How many times each prime factor occurs in $n..$guess
  my %num_factor_occurrences;   

  # What numbers between $n and $guess could get added to our list?
  my @possible_numbers;

  # Update %factorization; it already contains factorizations for
  # $n through $guess-1.
  my $f = (factorization( $guess ))[0];
  $factorization{$guess} = $f;
  return 0 if scalar keys %$f == 0;   # square

  # Clear out the global hash
  %bad_number_sets = ();

  # Populate %num_factor_occurrences
  for my $i ($n..$guess) {
    for my $factor (keys %{$factorization{$i}}) {
      $num_factor_occurrences{$factor}++;
    }
  }

  # Populate @possible_numbers.  Any number that has a factor that
  # can't be paired off should not even be considered.
  for my $i ($n+1..$guess-1) {
    my $f = $factorization{$i};
    my $ok = 1;
    for my $factor (keys %$f) {
      if ($num_factor_occurrences{$factor} == 1) {
        $ok = 0; last;
      }
    }
    push @possible_numbers, $i if $ok;
  }

  # And if $n or $guess has unpaired factors, we're doomed from the start.
  for my $i ($n, $guess) {
    my $f = $factorization{$i};
    for my $factor (keys %$f) {
      if ($num_factor_occurrences{$factor} == 1) {
        print "$i has a unique factor of $factor, giving up\n" if $verbose;
        return 0;
      }
    }
  }

  # Populate %factor_occurrences.  It is a hash of references to
  # hashes; %{$factor_occurrences->{$f}} is a hash whose keys are the
  # numbers in @possible_numbers that have $f as a parity factor.
  undef %factor_occurrences;
  print "$n: ", join( ' ', sort numerically keys %{$factorization{$n}} ), "\n" if $verbose;
  for my $i (@possible_numbers) {
    my $f = $factorization{$i};
    print "$i: ", join( ' ', sort numerically keys %$f ), "\n" if $verbose;
    for my $factor (keys %$f) {
      if (exists $factor_occurrences{$factor}) {
        $factor_occurrences{$factor}{$i} = 1;
      } else {
        $factor_occurrences{$factor} = { $i => 1 };
      }
    }
  }
  print "$guess: ", join( ' ', sort numerically keys %{$factorization{$guess}} ), "\n" if $verbose;

  # OK, now to call our recursive function looking for matches.

  @numbers = ($n, $guess);   # numbers in the actual sequence

  undef %factors_needing_pairing;  # factors remaining to be paired off
  add_factor_set( \%factors_needing_pairing, $factorization{$n} );
  add_factor_set( \%factors_needing_pairing, $factorization{$guess} );

  return match();
}

# match() returns whether we can choose additional numbers to pair off
# all the factors in %factors_needing_pairing.

sub match {
  my $indent = " " x (2 * @numbers) if $verbose;

  # %bad_number_sets lets us avoid a lot of wasted computation.  If
  # we've tried A B C, done lots of subsequent work, and eventually
  # found that it was all a dead end, then if we later try A C B, we
  # want to avoid heading down the same dead end.  So every time that
  # &match fails, it marks the set of numbers it was given as being a
  # dead end by entering it into %bad_number_sets.  To generate a key
  # that depends on the numbers and not their permutation, we just
  # sort and pack them.

  # You'd think it would be faster to keep the numbers in sorted order
  # all the time and avoid this sort.  We'd then have to insert $try
  # into the right spot, and search for it to take it out.  When I
  # tried it, it slowed things down, though.  I think the
  # disaadvantage of doing the sort all the time is countered by the
  # fact that it's a C-coded sort rather than a Perl-coded binary
  # insert.

  # I used to sort numerically until I thought, "Hey, who cares about
  # the sort order as long as there is one?"  Changing to the default
  # sort sped up the program by over 10%.
  my $key = pack( "L*", sort @numbers);
  if (defined $bad_number_sets{$key}) {
    print $indent, "Short-circuiting out\n" if $verbose;
    return 0;
  }

  # If there's nothing left to pair, we win!
  if (scalar keys %factors_needing_pairing == 0) {
    print "Found answer: ", join( ' ', sort numerically @numbers ), "\n"
      if $verbose || $print_sequence;
    return 1;
  }

  print $indent, "Need to pair ",
    join( ' ', sort numerically keys %factors_needing_pairing), "\n" if $verbose;

  # We're going to have to pair all of the elements of
  # %factors_needing_pairing eventually, so let's start by pairing
  # the one that occurs the least in our possible numbers, because that
  # way we'll have the fewest choices to try before succeeding or failing.

  # Which factor occurs the least, so far?
  my $least_occurring_needed_factor = 0;

  # And how many times does it occur?
  my $num_lonf_occurrences = 1000000; # ugh

  # Ugly code to determine $least_occurring_needed_factor
  for my $f (keys %factors_needing_pairing) {
    if (exists $factor_occurrences{$f}) {
      my $f_occurrences = scalar keys %{$factor_occurrences{$f}};
      print $indent, "$f occurs $f_occurrences times\n" if $verbose;
      if ($f_occurrences < $num_lonf_occurrences) {
        if ($f_occurrences == 0) {
          # See the 'else' clause below.  We could get here since when we
          # delete the last number from the occurrence table we don't bother
          # to delete the entire entry.
          $bad_number_sets{$key} = 1;
          return 0;
        }
        $least_occurring_needed_factor = $f;
        $num_lonf_occurrences = $f_occurrences;
      }
    } else {
      # Forget the least occurring factor, here's one that we need
      # that doesn't exist at all!  We're screwed. 
      print $indent, "$f doesn't occur at all\n" if $verbose;
      $bad_number_sets{$key} = 1;
      return 0;
    }
  }
  print $indent, "Chose to pair off $least_occurring_needed_factor\n" if $verbose;

  # @$lonf_occurrences is an array of all the numbers that could pair
  # off $least_occurring_needed_factor.  We try them all in turn,
  # starting with the ones with the fewest factors (if all we need to
  # match is a 2, we don't want to start by pairing it with 2*3*5*7
  # and introducing three more factors we'll have to pair off later).

  # What we probably really want to do is start with the ones that will
  # leave us with the fewest factors to match, but I'm afraid that testing
  # that will take too long.
  my $lonf_occurrences = $factor_occurrences{$least_occurring_needed_factor};
  my @tries = sort {
    scalar keys %{$factorization{$a}} <=> scalar keys %{$factorization{$b}}
  } keys %$lonf_occurrences;

  print $indent, "It occurs in ", join( ' ', @tries), "\n" if $verbose;
  print $indent, "number of factors: ",
    join( ' ', map { "$_:" . scalar keys %{$factorization{$_}} }
          @tries), "\n" if $verbose;
  
  for my $try (@tries) {
    # And here's the key: we just update our data structures and call
    # &match recursively.

    print $indent, "Trying $try\n" if $verbose;

    # Update the three elements of our state
    push @numbers, $try;
    add_factor_set( \%factors_needing_pairing, $factorization{$try} );
    for my $f (keys %{$factorization{$try}}) {
      delete $factor_occurrences{$f}->{$try};
    }

    # Call match recursively
    my $matched = match();

    # If 1, we win!
    return 1 if $matched;

    # Otherwise, undo the update and try the next one
    pop @numbers;
    add_factor_set( \%factors_needing_pairing, $factorization{$try} );
    for my $f (keys %{$factorization{$try}}) {
      $factor_occurrences{$f}->{$try} = 1;
    }
  }

  # None of the tries worked, so backtrack one level and let our parent call
  # keep trying.

  $bad_number_sets{$key} = 1;
  return 0;
}

my $start = shift;
my $end = shift || $start;
foreach my $n ($start .. $end)
{
    print "G($n) = " . Graham($n) . "\n";
}

