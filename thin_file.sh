#!/bin/sh

if [[ ! `which ncks 2>/dev/null` ]]; then module load nco; fi

if [[ -e $1 ]]; then
    ncks -v time,lat,lon,crain,u10m,v10m $1 short_$1

    if [[ -e short_$1 ]]; then
        mkdir -p subset
        rm $1
        /bin/mv short_$1 subset/$1
    fi
fi
