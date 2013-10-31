#!/bin/bash
IN_FILE="$1"
shift
OUT_FILE="$1"
shift
(
( cat < "$IN_FILE" |
    sed 's!\..*$!!' |
    uniq | # [1]
    (while read T ; do
        echo "$T.M" ;
     done)
) ;
( cat < "$IN_FILE" )
) |
    sort |
    uniq > "$OUT_FILE"

# [1] - This "uniq" command isn't absolutely necessary, but it helps in the
# running time.
