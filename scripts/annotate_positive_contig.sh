#!/bin/bash

HMM_TBL=$1
sample=`echo $HMM_TBL | cut -d'.' -f1`


awk '!/^#/ {print $1}' $HMM_TBL | rev | cut -d '_' -f2- | rev | sort | uniq > $sample.positive.contigs.txt

if [ -s $sample.positive.contigs.txt ] ; then 

    mkdir $sample.positive.contigs.genes

    parallel -a $sample.positive.contigs.txt "awk  "/{}/" $sample.contigs_genes.faa | cut -d' ' -f1 | cut -d'>' -f2 > $sample.positive.contigs.genes/{}_genes.txt"
    ls $sample.positive.contigs.genes/*_genes.txt | parallel "seqtk subseq $sample.contigs_genes.faa {} > {.}.faa"

    ls $sample.positive.contigs.genes/*_genes.faa | parallel "svr_assign_using_figfams < {} &> {.}_annotations.txt"
else
    echo "No contigs annotated because no argonaute were detected"

fi
