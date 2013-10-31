#!/usr/bin/perl

use Factor;

use Math::GMP qw(:constant);


sub Graham
{
    my $n = shift;

    my $v = get_squaring_value($n);

    my %values = ($v => [0,$n]);

    MAIN_LOOP: for(my $i=($n+1);;$i++)
    {
        print "\$i=$i\n";
        $v = get_squaring_value($i);
        foreach my $k (keys(%values))
        {
            my $new_v = get_squaring_value($k*$v);
            if (!exists($values{$new_v}))
            {
                # print "\$new_v=$new_v\n";
                $values{$new_v} = [$k,$i];
                if ($new_v == 1)
                {
                    last MAIN_LOOP;
                }
            }
        }
        # if (!exists($values{$v}))
        # {
        #    $values{$v} = [$v,$i];
        # }
    }

    return $values{1}->[1];
}

my $n = new Math::GMP(shift);
#foreach my $i ($n .. (2*$n))
#{
#    print "$i = " ;
#    print join(" * ", @{&get_squaring_factors($i)}), "\n";
#}
print "G($n) = " . Graham($n) . "\n";

