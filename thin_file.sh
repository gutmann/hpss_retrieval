#!/bin/sh

if [[ -e $1 ]]; then
    ncks  -4 -L 2 -v time,lat,lon,crain $1 short_$1

    if [[ -e short_$1 ]]; then
        mkdir -p subset
        rm $1
        /bin/mv short_$1 subset/$1
    fi
fi
