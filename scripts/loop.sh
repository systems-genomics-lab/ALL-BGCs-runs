#!/bin/bash

PROJECT=/projects/metaBGC/
cd $PROJECT/

while true
do
    git pull
    $PROJECT/scripts/go.sh
    sleep 3600
done
