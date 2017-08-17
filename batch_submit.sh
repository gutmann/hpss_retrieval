#!/bin/bash
#
# LSF batch script to download from HPSS
#
#BSUB -P P48500028           # project code
#BSUB -W 12:00               # wall-clock time (hrs:mins)
#BSUB -n 1                   # number of tasks in job
#BSUB -R "span[ptile=16]"    # run 16 MPI tasks per node
#BSUB -J dl            # job name
#BSUB -o dl.%J.out     # job output file (%J is replaced by the job ID)
#BSUB -e dl.%J.err     # job error file (%J is replaced by the job ID)
#BSUB -q hpss             # queue

module load nco

rm -r tmp.*
rm -r *.tar

PREFIX=`basename $PWD`
BATCHFILE=batch_submit.sh

MASTER=master_tape_list
DOWNLOAD_LIST=current_list

# helper scripts
THIN_LIST=../remove_files_from_hpss_list.py
THIN_DATA=../thin_data.sh

# remove any existing files from list
cp $MASTER $DOWNLOAD_LIST
${THIN_LIST} $DOWNLOAD_LIST
mv ${DOWNLOAD_LIST}_subset $DOWNLOAD_LIST

mkdir -p subset

# check if more files exist to download
nfiles=`wc $DOWNLOAD_LIST -l| sed -e"s/ $DOWNLOAD_LIST//"`
if [[ $nfiles > 0 ]]; then
    # delete last file (in case the last download was cut-off)
    last_file=`ls -1 -t *.tar | tail -1`
    rm $last_file

    # repeat this step so we get the last file again too
    # remove any existing files from list
    cp $MASTER $DOWNLOAD_LIST
    ${THIN_LIST} $DOWNLOAD_LIST
    mv ${DOWNLOAD_LIST}_subset $DOWNLOAD_LIST

    # resubmit this job dependant on itself
    jobsub=`bsub -w "ended(${LSB_JOBID})" < $BATCHFILE` 2>job_file

    # keep a job running in the background removing variables we don't need
    (while true; do ${THIN_DATA}; sleep 600; done)&

    hsi in $DOWNLOAD_LIST
fi

# if we got here, we must have finished downloading all files, so subset the last files before exiting
ls -1 *.tar | xargs -n 1 ../expand_and_thin_file.sh


# find out how many files are left to download (should be none)
${THIN_LIST} $DOWNLOAD_LIST
nfiles=`wc ${DOWNLOAD_LIST}_subset -l| sed -e"s/ ${DOWNLOAD_LIST}_subset//"`
# if there really are no files left to download then kill the pending job
if [[ $nfiles == 0 ]]; then
    bkill ${jobsub:5:6}
fi
