#!/bin/bash

HMM_TBL=$1
sample=`echo $HMM_TBL | cut -d'.' -f1`


#extract gene names and sequences
awk '!/^#/ {print $1}' $HMM_TBL > $sample.positive.genes.txt

if ! [ -s $sample.positive.genes.txt ] ; then
    echo "No argonaute proteins detected"
    exit 0
else
    seqtk subseq $sample.contigs_genes.faa $sample.positive.genes.txt > $sample.positive.genes.faa
    awk -F '[ ;]' '/^>/ {if (seqlen){print seqlen}; printf substr($1,2) "\t" $10 "\t" ;seqlen=0; next; } { seqlen += length($0)}END{print seqlen}' $sample.positive.genes.faa | sed '1igene\tpartial\tlength' > $sample.positive.genes.stats.txt


    awk '!/^#/ {print $1}' $HMM_TBL | rev | cut -d '_' -f2- | rev | sort | uniq > $sample.positive.contigs.txt

    mkdir $sample.positive.contigs.genes

    parallel -a $sample.positive.contigs.txt "awk  "/{}/" $sample.contigs_genes.faa | cut -d' ' -f1 | cut -d'>' -f2 > $sample.positive.contigs.genes/{}_genes.txt"
    ls $sample.positive.contigs.genes/*_genes.txt | parallel "seqtk subseq $sample.contigs_genes.faa {} > {.}.faa"

    ls $sample.positive.contigs.genes/*_genes.faa | parallel "svr_assign_using_figfams < {} &> {.}_annotations.txt"
    

fi
