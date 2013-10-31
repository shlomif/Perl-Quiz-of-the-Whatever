use strict;
use warnings;

sub connected
{
   my $edges = shift;
   # Step 1: initialize the UF forest for every vertex in the graph.
   my $uf = { map { map { $_ => $_ } @$_ } @$edges };
   # Step 2: make the union of the vertices of every edge.
   $uf->{root($uf, $_->[1])} = $_->[0] for @$edges;
   # Step 3: build the list of components. @components is the list itself,
   # %components is the mapping between the root of an UF-tree and the index
   # of the edge list in @components.
   my @components = ();
   my %components = ();
   for (@$edges) {
     my $root = root($uf, $_->[0]);
     $components{$root} = @components if !exists $components{$root};
     push @{$components[$components{$root}]}, $_;
   }
   return \@components;
}

# Find the root of an UF tree for a given node. We use a simple path
# compression technique which also brings up nodes that we look-up closer to
# the root.
sub root
{
   my ($uf, $u) = @_;
   while ($uf->{$u} != $u) {
     my $next = $uf->{$u};
     $uf->{$u} = $uf->{$next};
     $u = $next;
   }
   return $u;
}

1;

