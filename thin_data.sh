#!/bin/bash

# process one file at a time from all but the last file (which may be downloading now)
ls  -tr -1 *.tar 2>/dev/null | head -n -1 | xargs -n 1 ../expand_and_thin_file.sh
