package WithMatchSet;

use base 'Exporter';

our @EXPORT = (qw(prepare_ranges_handle lookup_ranges));

sub new
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->initialize(@_);
    return $self;
}

sub initialize
{
    my $self = shift;
    my $ranges = shift;

    $self->{'ranges'} = $ranges;
    
    $self->{'ranges_sorted_by_low'} =
        [ sort 
            { $ranges->[$a]->[0] <=> $ranges->[$b]->[0] } 
            (0 .. $#$ranges) 
        ];
    $self->{'ranges_sorted_by_high'} =
        [ sort 
            { $ranges->[$a]->[1] <=> $ranges->[$b]->[1] } 
            (0 .. $#$ranges) 
        ];
    
    return 0;
}

sub bsearch
{
    my ($key, $compare_cb, $high) = (@_);
    my $low = 0;
    my $mid;
    my $result;
    while ($low <= $high)
    {
        $mid = (($low+$high)>>1);

        $result = $compare_cb->($mid);

        if ($result < 0)
        {
            $high = $mid-1;
        }
        elsif ($result > 0)
        {
            $low = $mid+1;
        }
        else
        {
            return (1, $mid);
        }
    }
    return (0, $high+1);
}

sub get_h
{
    my $self = shift;
    my $idx = shift;
    my $h_order = $self->{'ranges_sorted_by_high'};
    my $ranges = $self->{'ranges'};

    return $ranges->[$h_order->[$idx]]->[1];
}

sub get_l
{
    my $self = shift;
    my $idx = shift;
    my $l_order = $self->{'ranges_sorted_by_low'};
    my $ranges = $self->{'ranges'};

    return $ranges->[$l_order->[$idx]]->[0];
}

sub lookup
{
    my $self = shift;
    my $x = shift;
    my $h_order = $self->{'ranges_sorted_by_high'};
    my $l_order = $self->{'ranges_sorted_by_low'};
    my $ranges = $self->{'ranges'};
    my $max_idx = $#$ranges;

    my (undef, $h_place) =
        (bsearch($x, 
            sub { $x <=> $self->get_h(shift); },
            $max_idx
        ));
    my (undef, $l_place) =
        (bsearch($x, 
            sub { $x <=> $self->get_l(shift) },
            $max_idx
        ));

    my $done_loop = 0;
    while (($self->get_h($h_place) >= $x) && ($h_place >= 0))
    {
        $done_loop = 1;
        $h_place--;
    }
    if ($done_loop)
    {
        $h_place++;
    }
    
    if ($l_place == 0)
    {
        if ($self->get_l($l_place) > $x)
        {
            $l_place = -1;
        }
    }
    elsif ($l_place > $max_idx)
    {
        $l_place = $max_idx;
    }
    elsif ($self->get_l($l_place) <= $x)
    {
        $done_loop = 0;
        while (($self->get_l($l_place) <= $x) && ($l_place <= $max_idx))
        {
            $done_loop = 1;
            $l_place++;
        }
        if ($done_loop)
        {
            $l_place--;
        }
    }
    else # ($self->get_l($l_place) > $x)
    {
        while (($self->get_l($l_place) > $x) && ($l_place >= -1))
        {
            $l_place--;
        }
    }
    
    my @h_set = @{$h_order}[$h_place .. $max_idx];
    my @l_set = @{$l_order}[0 .. $l_place];
    my @both = (sort { $a <=> $b } (@h_set,@l_set));
    my @matches = 
        (map 
        { $both[$_] } 
        (grep 
        { $both[$_] == $both[$_+1] } 
        (0 .. $#both-1)
        ));
    return 
    { 
        'verdict' => (@matches > 0), 
        'match_set' => { map { $_ => 1 } @matches}, 
    };
}

sub prepare_ranges_handle
{
    my $ranges = shift;
    return __PACKAGE__->new($ranges);
}

sub lookup_ranges
{
    my ($handle, $x) = (@_);
    return $handle->lookup($x);
}
1;

