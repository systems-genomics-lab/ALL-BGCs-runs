#!/usr/bin/env python3

import sys
import pandas as pd
from Bio import SeqIO

filename = sys.argv[1] # FASTA file name

sequences = pd.DataFrame(columns=['id', 'length'])
i = 0

for record in SeqIO.parse(filename, "fasta"):
    sequences.loc[i] = [record.id, len(record.seq)]
    i += 1

sequences_sorted = sequences.sort_values(by = 'length', ascending = False)

for index, seq in sequences_sorted.iterrows():
    print (seq['id'], "\t", seq['length'])
    
