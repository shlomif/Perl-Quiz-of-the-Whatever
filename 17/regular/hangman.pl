#!/usr/bin/perl

use warnings;
use strict;

my $dict_filename = shift;
my $max_num_guesses = shift;

# Read the dictionary file
open my $file, "<$dict_filename";
my @word_list = <$file>;
foreach(@word_list)
{
    chomp;
}
close($file);

# Seed the random number generator if specified
if (exists($ENV{SEED}))
{
    srand($ENV{SEED});
}
# Choose a word at random
my $word_idx = int(rand(scalar(@word_list)));
my $word = $word_list[$word_idx];

$word = lc($word);

my @letters = split(//, $word);
my @guessed_bits = (0) x @letters;
my $num_guesses = 0;
my %guessed_letters = ();
my $num_guessed_letters = 0;

sub has_won
{
    return ($num_guessed_letters == @letters);
}

sub has_lost
{
    return ($num_guesses == $max_num_guesses);
}

sub message
{
    my $msg = shift;
    print "    ". $msg . "\n";
}

MAIN_LOOP: 
while(!(has_won() || has_lost()))
{
    # Display the word
    message( 
        join("", map 
            { $guessed_bits[$_] ? $letters[$_] : "_" } 
            (0 .. $#letters))
        );

    my $choice = <STDIN>;
    chomp($choice);
    $choice = lc(substr($choice, 0, 1));
    if ($choice !~ /^[a-z]$/)
    {
        print STDERR "\"$choice\" is not a letter.\n";
        redo MAIN_LOOP;
    }
    if (exists($guessed_letters{$choice}))
    {
        print STDERR "You've already selected this letter.\n";
        redo MAIN_LOOP;
    }
    $guessed_letters{$choice} = 1;
    my $orig_num_guessed_letters = $num_guessed_letters;
    foreach my $index (0 .. $#letters)
    {
        if ($letters[$index] eq $choice)
        {
            $guessed_bits[$index] = 1;
            $num_guessed_letters++;
        }
    }
    if ($num_guessed_letters == $orig_num_guessed_letters)
    {
        $num_guesses++;
    }
}

if (has_won())
{
    message("LIFE!");
}
elsif (has_lost())
{
    message("DEATH!");
}
message("The word is \"$word\".");

