#!/usr/bin/env python3

#usage: <./script> <checkm_folder/storage/bin_stats_ext.tsv>

import sys
import ast

d = {} 

with open(sys.argv[1]) as f:
    for line in f:
        line = line.rstrip()
        line = line.split('\t')
        d[line[0]] = ast.literal_eval(line[1])

print('#bin\tmarker lineage\t# genomes\t# markers\tCompleteness\tContamination\tGC\tGC std\tGenome size\t# ambiguous bases\t# scaffolds\t# contigs\tLongest scaffold\tLongest contig\tN50 (scaffolds)\tN50 (contigs)\tMean scaffold length\tMean contig length\tCoding density\tTranslation table\t# predicted genes')

for k, v in d.items():
    print(k, end='\t')
    for x in ['marker lineage','# genomes','# markers','Completeness','Contamination','GC','GC std','Genome size','# ambiguous bases','# scaffolds','# contigs','Longest scaffold','Longest contig','N50 (scaffolds)','N50 (contigs)','Mean scaffold length','Mean contig length','Coding density','Translation table','# predicted genes']:
        print(v[x], end ='\t')
    print()

