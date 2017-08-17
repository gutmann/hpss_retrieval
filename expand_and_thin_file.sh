#!/bin/sh

if [[ $1 ]]; then

    TEMP_DIR=`mktemp -d`
    mkdir -p $TEMP_DIR
    cd $TEMP_DIR

    mv ../$1 ./
    tar -xf $1

    find . -iname '*.nc' -exec mv {} ./ \;

    ls -1 *.nc 2>/dev/null | xargs -n 1 ../../thin_file.sh

    mkdir -p ../nc_output
    mv subset/*.nc ../nc_output

    cd ../
    rm -r $TEMP_DIR

    mkdir -p subset

# incase the job was killed mid-stream
# the main work process could be killed
# but this script could to continue just a second longer
    sleep 10
    touch subset/$1
fi
