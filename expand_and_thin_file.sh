#!/bin/sh

if [[ $1 ]]; then

    # no longer assume that mktemp creates a directory in the current directory
    # so save the current directory for later use.
    base_dir=`pwd -P`

    MASTER_TEMP_DIR=`mktemp -d`
    TEMP_DIR=${MASTER_TEMP_DIR#/tmp/}
    mkdir -p $TEMP_DIR # it should already exist, but incase mktemp doesn't create it
    cd $TEMP_DIR

    mv ${base_dir}/$1 ./
    tar -xf $1

    find . -iname '*.nc' -exec mv {} ./ \;

    ls -1 *.nc 2>/dev/null | xargs -n 1 ${base_dir}/../thin_file.sh

    mkdir -p ${base_dir}/nc_output
    mv subset/*.nc ${base_dir}/nc_output

    cd ${base_dir}
    rm -r $TEMP_DIR
    rm -r $MASTER_TEMP_DIR

    mkdir -p subset

# incase the job was killed mid-stream
# the main work process could be killed
# but this script could to continue just a second longer
    sleep 10
    touch subset/$1
fi
