use strict;
use warnings;

use List::Util (qw(reduce));
use List::MoreUtils (qw(any part));

# TODO : Remove later.
use Data::Dumper;

package Graph::Connected::Edge;

use base 'Class::Accessor';

# s and e are start and end.
__PACKAGE__->mk_accessors(qw(idx s e));

package main;

sub join_array
{
    return reduce { [@$a,@$b] } [], @_;
}

sub do_connected
{
    my $list = shift;

    if (! @$list)
    {
        return [];
    }

    my ($edge, @rest) = @$list;

    my ($i, $j) = ($edge->s(), $edge->e());

    my $connected_recurse = do_connected(\@rest);

    my $is_connected = sub {
        my $x = shift;
        return any { 
            my ($i1, $j1) = ($_->s(), $_->e());
            ($i==$i1) || ($i==$j1) || ($j==$i1) || ($j==$j1)
        } @$x;
    };

    my ($conn_to_edge, $not_conn_to_edge) = 
        part { $is_connected->($_) ? 0 : 1 } @$connected_recurse;

    $conn_to_edge ||= [];
    $not_conn_to_edge ||= [];

    my $component = join_array([$edge], @$conn_to_edge);

    return [$component,@$not_conn_to_edge];
}

sub connected
{
    my $list = shift;

    my @objects_list = 
        map { 
            my $e = $list->[$_]; 
            Graph::Connected::Edge->new(
                {
                    's' => $e->[0],
                    'e' => $e->[1],
                    'idx' => $_,
                }
            );
        } (0 .. $#$list);
    
    my $ret_unsorted = do_connected(\@objects_list);

    my @ret_inside_sorted = (map { [ sort { $a->idx() <=> $b->idx() } @$_ ] } @$ret_unsorted);

    my @ret_outside_sorted = (sort { $a->[0]->idx() <=> $b->[0]->idx() } @ret_inside_sorted);

    my @ret_wo_indexes = (map { [ map { [ $_->s(), $_->e() ] } @$_ ] } @ret_outside_sorted);

    return \@ret_wo_indexes;
}

1;
