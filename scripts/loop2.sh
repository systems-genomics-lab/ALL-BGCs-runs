#!/bin/bash

# set -e
# set -u
# set -x
# set -o pipefail

PROJECT=/projects/metaBGC/
cd $PROJECT/

while true
do
    echo
    time $PROJECT/scripts/merge.sh > $PROJECT/merge.log 2>&1
    echo
    tail $PROJECT/merge.log
    echo
    ls -1 $PROJECT/samples/*.SUCCESS | wc -l
    echo
    date
    echo
    echo '-------------------------------------------'
    sleep 600
done
