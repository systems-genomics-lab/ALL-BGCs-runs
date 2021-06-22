#!/usr/bin/env python3

# A little parser to extract protein ids from deepBGC output files

import sys;

f = open(sys.argv[1], 'r');

for line in f:
    x = line.strip();
    y = x.split("\t")

    sample = y[0];
    id =  y[1];
    cluster = y[5];
    score = y[12];
    product = y[13];
    
    proteins = y[26].split(";");

    for protein in proteins:
        print (sample + "\t" + id + "\t" + cluster + "\t" + score + "\t" + product + "\t" + protein);

f.close()
