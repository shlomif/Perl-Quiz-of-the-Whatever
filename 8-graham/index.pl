use Carp;
sub sub2ind ($$;@) {
  my $dims = shift;
  $dims = [$dims->dims] if UNIVERSAL::isa($dims,'PDL');
  croak "need dims array ref" unless ref $dims eq 'ARRAY';
  my @args = @_;
  croak "number of dims must not be less than number of arguments"
    unless @args <= @$dims;
  my $coord = $args[0]->copy;
  for my $n (1..$#$dims) { $coord += $dims->[$n-1]*$args[$n] }
  return $coord;
}


$mymap = pdl[[100, 200, 300],[4, 5, 6], [70, 80, 90]];

$keys_x = pdl [[1, 2] , [3, 1]];
$keys_y = pdl [[3, 1],[ 2, 2]];

$keys_x--; $keys_y--; # PDL is zero-offset

$keyinds = sub2ind $mymap, $keys_x,$keys_y; 
$map = $mymap->flat->index($keyinds);

# NiceSlice in CVS allows you to say
#
# $map = $mymap($keyinds);
