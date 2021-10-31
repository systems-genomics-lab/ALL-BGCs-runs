#!/bin/bash

FASTA=$1

awk '/^>/ {if (seqlen){print seqlen}; printf substr($1,2) "\t" ;seqlen=0; next; } { seqlen += length($0)}END{print seqlen}' $FASTA
