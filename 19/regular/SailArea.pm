
use strict;

# Calculate a triangle based on the coordinates of its three points

# Use the formula given in:
# http://mathworld.wolfram.com/TriangleArea.html
sub calc_triangle_area
{
    # Sanity checks.
    my @p = (@_);
    if (@p != 3)
    {
        die "Incorrect number of points given!";
    }
    for(my $i=0;$i<3;$i++)
    {
        if ((!exists($p[$i]->{x})) || (!exists($p[$i]->{y})))
        {
            die "Point $i has no required values!";
        }
    }
    # Make some useful shortcuts.
    my ($x1,$y1,$x2,$y2,$x3,$y3) = (map {@$_{'x','y'}} @p);
    # We need to abs it because it may be negative if the 
    # rotation direction of the points is reversed.
    return abs(0.5 * (($x3-$x2)*$y1+($x1-$x3)*$y2+($x2-$x1)*$y3));
}

# The quadrangle may be non-convex so I calculate the area in two
# different permutations of the points and take the minimum. 
# If the quadrangle is illegal (for example if there are intersecting edges),
# then this function won't detect it.
sub calc_quadrangle_area
{
    my @p = (@_);
    if (scalar(@p) != 4)
    {
        die "Incorrect number of points given!";
    }
    my $calc_area = sub {
        # The indexes
        my @i = (@_);
        return 
            calc_triangle_area(@p[@i[0,1,2]]) + 
            calc_triangle_area(@p[@i[2,3,0]]);
    };
    my $area1 = $calc_area->(0,1,2,3);
    my $area2 = $calc_area->(1,2,3,0);
    return (($area1 < $area2) ? $area1 : $area2);
}

sub process_next_sailboat
{
    my $lines = shift;

    my $l;
    my $sail_boat_name;
    my @points = ();
    while (scalar(@$lines))
    {
        $l = shift(@$lines);
        # Skip blank lines and comments
        if ($l =~ /^\s*($|#)/)
        {
            next;
        }
        if ($l =~ /^\s*(\w+)\.(\w):\s*(\d+)\s*,\s*(\d+)\s*$/)
        {
            # A valid line - process it.
            my ($new_name, $p_id, $x, $y) = ($1,$2,$3,$4);
            # TODO : At the moment, we're not doing anything with $p_id
            # Should we do something with it ?
            if (!defined($sail_boat_name))
            {
                $sail_boat_name = $new_name;
            }
            if ($new_name eq $sail_boat_name)
            {
                push @points, +{'x' => $x, 'y' => $y };
            }
            else
            {
                # Return the line to the line list
                unshift @$lines, $l;
                # Break the loop so the boat can be processed.
                last;
            }
        }
        else
        {
            die "Invalid line \"$l\"!";
        }
    }
    
    # Process the boat.
    if (@points == 0)
    {
        return ();
    }
    elsif (@points == 3)
    {
        return ($sail_boat_name, calc_triangle_area(@points));
    }
    elsif (@points == 4)
    {
        return ($sail_boat_name, calc_quadrangle_area(@points));
    }
    else
    {
        die "Incorrect number of points for sail boat \"$sail_boat_name\"";
    }
}


1;

