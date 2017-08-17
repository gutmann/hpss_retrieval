#!/usr/bin/env python

"""
SYNOPSIS

    remove_files_from_hpss_list.py [-h] [--verbose] [-v, --version] [filename]

DESCRIPTION

    Searches the present directory and an "subset/" directory for existing files.
    Then iterates over lines in a given HPSS input file, and if the file specified
    on that line is not present in either the current or subset directories, then
    the file is written to an output HPSS input file (=filename+"_subset")

EXAMPLES

    remove_files_from_hpss_list.py sorted_tape_list

EXIT STATUS

    TODO: List exit codes

AUTHOR

    Ethan Gutmann - gutmann@ucar.edu

LICENSE

    This script is in the public domain.

VERSION
    1.0

"""
from __future__ import absolute_import, print_function, division

import sys
import os
import traceback
import argparse
import glob

global verbose
verbose=False

def main (filename):
    # files=glob.glob("*.tar")
    files=[]
    files.extend(glob.glob("subset/*.tar"))
    for i in range(len(files)):
        files[i]=files[i].split("/")[-1]
        if verbose: print(files[i])

    found_files=[]
    n=0
    with open(filename) as f:
        with open(filename+"_subset","w") as o:
            for l in f:
                if not (l.split('/')[-1][:-1] in files):
                    if verbose: print(l)
                    if verbose: print(l.split('/')[-1][:-1])
                    o.write(l)
                    n=n+1
                else:
                    found_files.append(l)

    print("Wrote:"+str(n)+" files")
    print("Skipped:"+str(len(found_files))+" files")


if __name__ == '__main__':
    try:
        parser= argparse.ArgumentParser(description='Remove existing files from a HPSS input file if already present. ',
                                        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
        parser.add_argument('filename',nargs="?", action='store', default="sorted_tape_list", help="existing HPSS input file")
        parser.add_argument('-v', '--version',action='version',
                version='remove_files_from_hpss_list 1.0')
        parser.add_argument ('--verbose', action='store_true',
                default=False, help='verbose output', dest='verbose')
        args = parser.parse_args()

        verbose = args.verbose

        exit_code = main(args.filename)
        if exit_code is None:
            exit_code = 0
        sys.exit(exit_code)
    except KeyboardInterrupt as e: # Ctrl-C
        raise e
    except SystemExit as e: # sys.exit()
        raise e
    except Exception as e:
        print('ERROR, UNEXPECTED EXCEPTION')
        print(str(e))
        traceback.print_exc()
        os._exit(1)
