#!/usr/bin/env python3

import sys
from Bio import SeqIO

infilename = sys.argv[1] # Input fasta file name
outfilename = sys.argv[2] # Output fasta file name
cutoff = int(sys.argv[3])

sequences = []
i = 0
j = 0
k = 0

for record in SeqIO.parse(infilename, "fasta"):
    i += 1
    if (len(record.seq) > cutoff):
        sequences.append(record)
        j += 1
    else:
        k += 1
        
SeqIO.write(sequences, outfilename, "fasta")

print ("Read ", i, " sequences")
print ("Wrote ", j, " sequences")
print ("Skipped ", k, "sequences")
