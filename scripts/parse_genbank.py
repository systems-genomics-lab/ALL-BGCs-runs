#!/usr/bin/env python3

import sys
from Bio import SeqIO

filename = sys.argv[1] # input genbank file name

for seq_record in SeqIO.parse(filename, "genbank"):
    for feature in seq_record.features:
        if feature.type == "region":
            print (seq_record.id + "\t" + feature.qualifiers['product'][0] + "\t" + str(feature.location.start + 1) + "\t" + str(feature.location.end))
            
