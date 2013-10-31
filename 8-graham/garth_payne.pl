#! /usr/bin/perl -w

# Use auto-flush
$|=1;

sub factor_single;
sub factor;
sub exponent;
sub product;
sub odd_power_primes;
sub odd_occurrences;
sub multiply_lists;
sub divisors;
sub min;
sub max;
sub ss1;
sub ss2;
sub first_try;
sub proof;
sub candidate;
sub update_stats;
sub check_descendants;
sub square_sequence;
sub square_sequence_min_card;
sub Graham;
sub print_results;

#Set defaults for flags;
my $Use_first_try=1; 
my $Proof_wanted=0;
my $Sequence_wanted=0;
my $Minimal_sequences_wanted=0;

my @Primes=
    (2,3,5,7,9,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,73,79,83,89,97);
sub factor_single {
#for primes <=10000 use trial division. for larger primes use system's factor
    my $N = shift;
    my $n=$N;
    my %h;
    if ($N <= 10000) {
    #  Eric Roode
        for my $prime (@Primes) {
            while ($n % $prime == 0) {
                $n /= $prime;
                $h{$prime}++;
            }
            last if $n == 1;
        }
        if ( $n > 1 ) {
            $h{$n} = 1; 
        }
    }
    else {
        local $_;
        $_=qx{factor $n};
        s/^$n:* \s+ ([\d \s ]+?) \s*  $/$1/x or die 
            "Your system's factor function is not what I expected";
        for my $prime (split) {
            $h{$prime}++;
        }
    }
    return {%h};
}

my %Prime_exponent = ();

sub factor {
# factors single argument or the product of multiple
# arguments, taking advantage of the partial
# factorization represented by the arguments
# eg. %{factor 3*3*7*7, 7*7*11*11*11} == (7 => 4, 3 => 2, 11 => 3)
# caches
    local $_;
    my $n= product @_;
    die if  grep { $_ < 1 or not /^\d+$/ } @_;
    if ( $n == 1 ) {
        return $Prime_exponent{$n} = {};
    }
    $Prime_exponent{$n} ||= do 
    {
        @_=grep {$_ > 1} @_;
        if ( @_ == 1 ) {
            my %h=%{factor_single $n};
            for my $prime (keys %h) {
                $Prime_exponent{$n}->{$prime}+=$h{$prime};
            }
        }
        else {
            for my $i (@_) {
                for my $prime (keys %{factor $i}) {
                    $Prime_exponent{$n}->{$prime}+=
                        exponent $i,$prime;
                }
            }
        }
        $Prime_exponent{$n};
    }
}

sub exponent {
# exponent(7*7*7*5*3*2*2*2*2, 7) == 3
    my $n=shift;
    my $prime=shift;
    if ($Prime_exponent{$n}) {
        return $Prime_exponent{$n}->{$prime} || 0
    }
    else {
        my $i=0;
        while ( $n % $prime == 0 ) { $n/=$prime; $i++}
        return $i;
    }
}
sub product {
# fun use of eval
    die if  grep { not /^\d+$/ } @_;
    eval join '*', @_;
}

my $_Odd_power_primes;

sub odd_power_primes {
#returns the primes that have odd exponent in the product of the arguments,
#taking advantage of the partial factorization represented by the arguments.
#eg. "@{odd_power_primes  3*3*3*5,5*7}" == ( 7, 3 )
    my $n=product @_;
    return [] if not $n or $n == 1;
    factor @_;
    $_Odd_power_primes->{$n} ||= 
        [ grep { exponent($n,$_) % 2 }    ( keys %{factor $n} ) ];
}
sub odd_occurrences {
# return arguments that occur an odd number of times
#    eg. @{odd_occurrences 2,2,2,3,3,4,5,4,5,5}=(2, 5)
# when the arguments are all prime, it is a special case of 
# odd_power_primes, but it avoids multiplication of terms whose product
# exceeds maxint.
    my %h;
    for my $i ( @_ ) { $h{$i}++ and delete $h{$i} }
    return  [sort { $a <=> $b } (keys %h) ];
}

my ($j, $i, %h);

sub multiply_lists {
# eg. multiply_lists [a,b],[c,d,e],[f]==[acf,adf,aef,bcf,bdf,bef]
    my @prod=(1);
    my $aref;
    while ( @prod and $aref=shift) {
        my @a=@$aref;
        my @newprod=();
        for $j (@a) {
            for $i (@prod) {
                my $p = $i * $j;
                push @newprod,  $p;
            }
        }
        @prod=@newprod;
    }
    return [sort {$a <=> $b} @prod];
}
sub divisors {
    my $n=shift;
    %h=%{factor $n};
    my @divisors=(1);
    my @args;
    for my $prime (keys %h) {
        my @powers= map { $prime**$_ } ( 0 .. exponent($n, $prime) );
        push @args,[ @powers ];
    }
    multiply_lists @args;
}
sub min {
# faster than using sort
    my $min;
    for my $i (@_) {
        $min=$i if $i < $min or not defined $min;
    }
    return $min;
}
sub max {
# faster than using sort
    my $max;
    for my $i (@_) {
        $max=$i if not defined $max or $i > $max;
    }
    return $max;
}

sub ss1 {
# returns a sequence with square product used in first_try
    my $m=shift;
    my $n=shift;
    my $q=1+ int ( $m*$n/( 4*$m*($m+1) )  );
    $m*$n, 4*$m*($m+1)*$q, (2*$m+1)**2 * $q, ($m+1)*$n;
}
sub ss2 {
# returns a sequence with square product used in first_try
    my $m=shift;
    my $n=shift;
    $m*$n,($m+1)*$n,$m*($n+1),($m+1)*($n+1);
}
sub first_try {
    my $N=shift;
    not @{odd_power_primes $N} and return [$N];
    my @divisors=@{divisors $N};
    my $m=$divisors[int($#divisors/2)]; #$m is divisor closest to sqrt $N
    my $n = $N/$m;
    my @best=ss2 $m,$n; #max ss2  is minimal for $m=sqrt $N
    my $best=max @best;
    for my $m (@divisors) {
        my $n = $N/$m;
        my @a=ss1 $m,$n;
        last if $best and (2*$m+1)**2 > $best;
        my $m=max @a;
        if ($m < $best or not $best) {
            $best=$m;
            @best=@a;
        }
    }
    return [@best];
}

my (@Square_sequences, @Proof_data, $Bound, %Is_mode);
my ($Cardinality);

sub proof {
# Creates human verifiable proof.

#Say the prime p is affected by the number t if the exponent of p in
#t is odd, i.e. the largest e for which p**e divides t is odd.  Say a
#sequence is lapo (largest affected prime ordered) if each term affects
#the largest prime affected by the product of all the previous terms,
#or the product of the previous terms is a square.
#Note that any sequence with square product can be reordered to be lapo.

#proof(N) is trivial for squares.  If N is not a square,  proof(N)
#produces a list of sequences that satisfies the following three conditions:
#     (1) The list contains the sequence consisting of the single term N.
#     (2) If s1, ..., sk is a sequence in the list, the list also 
#         contains all lapo sequences  s1, ... ,sk, t 
#         such that t is not equal to any si, and  N < t < G(N).  
#     (3) None of the sequences in the list have square product.
#

#It's easily seen that a list of sequences satisfying the first two
#conditions must contain all lapo sequence that start with N and
#are otherwise bounded by N and G(N) exclusively.  Since there are no
#sequences in the list having square product, and any square sequence
#can be reordered to be lapo, it follows that there are no sequences
#with square product starting with N  and otherwise bounded by N and G(N)
#exclusively.

# example N=50.
# 50                         p=2   t=54,56,58, or 62
# 50 54                      p=3   t=51,57, or 60
# 50 54 51                   p=17 
# 50 54 57                   p=19 
# 50 54 60                   p=5   t=55
# 50 54 60 55                p=11 
# 50 56                      p=7
# 50 58                      p=29
# 50 62                      p=31
# shows G(50)>=63 
# In conjunction with the sequence 50 56 63 which has square product  
# proves G(50)=63

    die 'proof: Must set flag $Proof_wanted=1 before Graham' 
        if not $Proof_wanted;
    local $_;
    my $seq= join " ", @{$Square_sequences[0]};
    my $N=$Min_include;
    my %h;
    my $proof='';
    for my $ref (@Proof_data) {
        my $max=${$ref}[2];
        next if $max >= $Bound;
        my $prime=${$ref}[1];
        my $include_sequence=join " ",@{${$ref}[0]};
        $proof="$proof$include_sequence    (p=$prime)\n";
    }
    my $verbose_proof="proof: $seq is a square sequence so G($N)<=$Bound.
The following list of sequences satisfies the three 
conditions (see comments in proof subroutine), so G($N)>=$Bound.
${proof}QED\n";
    $verbose_proof="proof; Trivial.\n" if @{$Square_sequences[0]}==1;
    return $verbose_proof;
}

sub candidate {
# produce candidate for inclusion in sequence
    my $bnd=$Bound;
    if ($Is_mode{adjust_cardinality}) {
        return undef if @Include >= $Cardinality;
    }
    if ($Is_mode{adjust_bound}) {
        $bnd=$Bound -1 if $Already_verified_initial_bound;
    }                                    
    my $root=int sqrt($Min_include/$Prime);
    while (1) {
        $root++;
        my $candidate= $root**2 * $Prime;
        $candidate > $bnd and last;
        $Include{$candidate} and next; 
        $Exclude{$candidate} and next; 
        factor $root, $root, $Prime; 
        return $candidate;
    }
    my $candidate=$Min_include - ( $Min_include % $Prime );
    while (1) {
        $candidate+=$Prime;
        $candidate > $bnd and last;
        $Include{$candidate} and next; 
        $Exclude{$candidate} and next; 
        ( exponent $candidate, $Prime ) % 2  or next;
        return $candidate;
    }
}

sub update_stats {
#after a square sequence  is found, lower bound accordingly, etc
    if ($Is_mode{adjust_bound}) {
        $Max_include < $Bound or 
            @{$Square_sequences[0]}==1 or 
            not $Already_verified_initial_bound or 
            die "$Max_include < $Bound";
        $Bound=$Max_include;
        @Square_sequences=([@Include]);
        $Cardinality=@Include;
        $Already_verified_initial_bound=1;
    }
    elsif ($Is_mode{adjust_cardinality}) {
        if (@Include < $Cardinality) {
            @Square_sequences=([@Include]);
            $Bound=$Max_include;
            $Cardinality=@Include;
        }
        elsif ($Cardinality==@Include) {
            push @Square_sequences,[@Include]
        }
    }
}

sub check_descendants {
# recursively check all sequences that 
# include keys %Include and exclude keys %Exclude
# and lie in current bounds;
# update_stats if keys %Include have square product
    local %Exclude=%Exclude;
    local %Include=%Include;
    local @Include=@Include;                       #natural order keys %Include
    local $Max_include=$Max_include;
    local $Min_include=$Min_include;
    local $New=$New;                         
    local $Is_new_include=$Is_new_include;
    local $Is_new_exclude=$Is_new_exclude;
    local @Odd_power_primes=@Odd_power_primes;#primes with odd power in @Include
    local $Prime=$Prime;

    return if $Max_include == $Bound and $Is_mode{adjust_bound} and 
        $Already_verified_initial_bound;

    if ($Is_new_include) {
        %Include=(%Include, $New => 1 );
        @Include= (@Include, $New);
        @Odd_power_primes = 
            @{odd_occurrences @Odd_power_primes,@{odd_power_primes $New} };
        $Max_include= $New > $Max_include ? $New : $Max_include;

        if (not $Prime=$Odd_power_primes[-1]) {
            # a square sequence
            update_stats;
            return;
        }

        push @Proof_data, [[@Include],$Prime,$Max_include] if $Proof_wanted;
    }
    elsif ($Is_new_exclude) {
        %Exclude=(%Exclude, $New => 1);
    }
    else {die}

    $New=candidate or return;

    $Is_new_include=1;
    $Is_new_exclude=0;
    check_descendants();

    $Is_new_include=0;
    $Is_new_exclude=1;
    check_descendants();

}

sub square_sequence {
    my $n=shift;
    $Cardinality=0;
    %Exclude=();
    %Include=();
    @Include=();
    @Proof_data=();
    %Is_mode=( adjust_bound => 1 );
    $Max_include=0,
    $Min_include=$n;
    $New=$n;
    $Is_new_include=1;
    $Is_new_exclude=0;
    $Prime='';
    if ($Use_first_try) {
        @Square_sequences=(first_try $n);
        $Cardinality=@{$Square_sequences[0]};
        $Already_verified_initial_bound=1;
        $Bound=max @{$Square_sequences[0]};
    }
    else {
        $Already_verified_initial_bound=0;
        $Bound= $n > 3 ? 2*$n : 4*$n;
    }
    check_descendants;
    return [ sort {$a <=> $b} @{$Square_sequences[0]} ];
}

sub square_sequence_min_card {
#run square_sequences first ( takes $Bound from environment )
    %Exclude=();
    %Include=();
    @Include=();
    %Is_mode=( adjust_cardinality => 1 );
    $Is_new_include=1;
    $Is_new_exclude=0;
    $Prime='';
    @Square_sequences=();
    check_descendants;
    return [@Square_sequences];
}

sub Graham {
    my $n=shift;
    ${square_sequence $n}[-1];
}

sub print_results {

    my $n=shift;
    my $G=Graham($n);
    my @sequence=@{$Square_sequences[0]} if $Sequence_wanted;
    my $proof=proof if $Proof_wanted;
    my $minimal_sequences;
    if ($Minimal_sequences_wanted) {
        my @minimal_sequences=@{square_sequence_min_card()};
        for my $aref (@minimal_sequences) {
               $minimal_sequences.="\t@$aref\n"
        }
    }
    print "G($n)=",$G,"\n";
    print "$proof\n" if $Proof_wanted;
    print "@sequence\n" if $Sequence_wanted and 
        not $Proof_wanted and 
        not $Minimal_sequences_wanted;
    print "Sequences of minimal cardinality:\n$minimal_sequences\n" 
        if $Minimal_sequences_wanted;
}

#fancy output and flags 
#set these flags to 0 (no) or 1 (yes):
#$Proof_wanted=1;                #default
#$Sequence_wanted=0;             #default
#$Minimal_sequences_wanted=0;    #default
#$Use_first_try=1;               #default
#print_results shift;



# no frills
my $n=shift;
print "G($n)=",Graham($n),"\n";

#for my $n ( 1 .. 1000 ) {
#    print Graham($n),"\n";
#}

__END__
