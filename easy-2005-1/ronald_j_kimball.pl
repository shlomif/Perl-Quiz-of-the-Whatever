#!/usr/bin/perl -w

if (@ARGV > 2) {
  die "usage: $0 [<input file> [<output file>]]\n";
}

if (@ARGV == 2) {
  my $out = pop @ARGV;
  open STDOUT, ">$out"
    or die "Cannot open $out for writing.\n";
}

my $last_prefix = '';
my $printed_m = 1;

while (<>) {
  chomp;
  my($prefix, $suffix) = split /\./;
  if ($prefix ne $last_prefix) {
    if (not $printed_m) {
      print "$last_prefix.M\n";
    }
    $last_prefix = $prefix;
    $printed_m = 0;
  }
  if ($suffix eq 'M') {
    $printed_m = 1;
  }
  if ($suffix gt 'M' and not $printed_m) {
    print "$last_prefix.M\n";
    $printed_m = 1;
  }
  print "$_\n";
}

if (not $printed_m) {
  print "$last_prefix.M\n";
}
