#!/usr/bin/perl -w

use strict;

# This function get the factors (prime number+exponent) of $i.
sub get_factors
{
    my $n = shift;

    my ($p, @factors, $e);
    for($p=2;$n > 1;$p++)
    {
        if ($n % $p == 0)
        {
            $e = 0;
            while ($n % $p == 0)
            {
                $e++;
                $n /= $p;
            }
            push @factors, { 'p' => $p, 'e' => $e };
        }
    }

    return \@factors;
}


sub get_squaring_factors_from_factors
{
    my $factors = shift;
    return [ (map { $_->{'p'} } grep {$_->{'e'} % 2 } @$factors) ];
}

# This function gets the squaring factors of $n.
# The squaring factors are those prime numbers that need to be multiplied
# by $n to reach a perfect square. They are the minimal such number.
sub get_squaring_factors
{
    my $n = shift;
    return get_squaring_factors_from_factors(get_factors($n));
}

# This function multiplies the squaring factors of $n and $m to receive
# the squaring factors of ($n*$m)
sub multiply_squaring_factors
{
    my $n_ref = shift;
    my $m_ref = shift;

    my @n = @$n_ref;
    my @m = @$m_ref;

    my @ret = ();

    while (scalar(@n) && scalar(@m))
    {
        if ($n[0] == $m[0])
        {
            shift(@n);
            shift(@m);
        }
        elsif ($n[0] < $m[0])
        {
            push @ret, shift(@n);
        }
        else
        {
            push @ret, shift(@m);
        }
    }
    push @ret, @n, @m;
    return \@ret;
}

sub Graham
{
    my $n = shift;

    my $n_sq_factors = get_squaring_factors($n);

    # The graham number of a perfect square is itself.
    if (scalar(@$n_sq_factors) == 0)
    {
        return $n;
    }

    # %primes_to_ids_map maps each prime number to its ID. IDs are consective.
    my (%primes_to_ids_map);
    my $next_id = 0;

    # @base is an array that for each ID of a prime number holds the 
    # controlling vector for this number.
    #
    # This is in fact a matrix that is kept stair-shaped and canonized.
    my (@base);

    # Register all the primes in the squaring factors of $n
    foreach my $p (@$n_sq_factors)
    {
        $primes_to_ids_map{$p} = ($next_id++);
    }

    # $n_vec is used to determine if $n can be composed out of the base's 
    # vectors.
    my $n_vec = $n_sq_factors;

    for(my $i=$n+1;;$i++)
    {
        my $i_sq_factors = get_squaring_factors($i);

        # $final_vec is the new vector to add after it was
        # stair-shaped by all the controlling vectors in the base.

        my $final_vec = $i_sq_factors;

        foreach my $p (@$i_sq_factors)
        {
            if (!exists($primes_to_ids_map{$p}))
            {
                # Register a new prime number
                $primes_to_ids_map{$p} = ($next_id++);
            }
            else
            {
                my $id = $primes_to_ids_map{$p};
                if (defined($base[$id]))
                {
                    $final_vec = multiply_squaring_factors($final_vec, $base[$id]);
                }
            }
        }

        # Get the minimal ID and its corresponding prime number
        # in $final_vec.
        my $min_id = -1;
        my $min_p = 0;

        foreach my $p (@$final_vec)
        {
            my $id = $primes_to_ids_map{$p};
            if (($min_id < 0) || ($min_id > $id))
            {
                $min_id = $id;
                $min_p = $p;
            }
        }

        if ($min_id >= 0)
        {
            # Assign $final_vec as the controlling vector for this prime
            # number
            $base[$min_id] = $final_vec;
            # Canonize the rest of the vectors with the new vector.
            for(my $j=0;$j<scalar(@base);$j++)
            {
                next if ($j == $min_id);
                next if (! defined($base[$j]));
                if (grep { $_ == $min_p } @{$base[$j]})
                {
                    $base[$j] = multiply_squaring_factors($base[$j], $final_vec);
                }
            }
        }

        # A closure to print the base. It is not used but can prove useful.
        my $print_base = sub {
            print "Base=\n\n";
            for(my $j=0;$j<scalar(@base);$j++)
            {
                next if (! defined($base[$j]));
                print "base[$j] (" . join(" * ", @{$base[$j]}) . ")\n";
            }
            print "\n\n";
        };

        # Check if we can form $n

        while (scalar(@$n_vec))
        {
            # Assing $id as the minimal ID of the squaring factors of $p
            my @ids_vec = (sort { $a <=> $b } @primes_to_ids_map{@$n_vec});
            my $id = $ids_vec[0];
            # Mulitply by the controlling vector of this ID if such one exists
            # or terminate if there isn't such.
            last if (!defined($base[$id]));
            $n_vec = multiply_squaring_factors($n_vec, $base[$id]);
        }
        if (scalar(@$n_vec) == 0)
        {
            return $i;
        }
    }
}

my $start = shift;
my $end = shift || $start;
foreach my $n ($start .. $end)
{
    print "G($n) = " . Graham($n) . "\n";
}

