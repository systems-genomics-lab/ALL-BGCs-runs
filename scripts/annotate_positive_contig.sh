#!/bin/bash

PROJECT=/lfs01/workdirs/sadat002u1/argonaute/metaBGC
cpus=`grep -c ^processor /proc/cpuinfo`
used_cpus=$((cpus/2))

HMM_TBL=$1
sample=`echo $HMM_TBL | cut -d'.' -f1`
reads1=$sample"_1.final.fastq.gz"
reads2=$sample"_2.final.fastq.gz"


#extract gene names and sequences
awk '!/^#/ {print $1}' $HMM_TBL > $sample.positive.genes.txt

if ! [ -s $sample.positive.genes.txt ] ; then
    echo "No argonaute proteins detected"
    exit 0
else
#FIRST: extract protein sequences
    seqtk subseq $sample.contigs_genes.faa $sample.positive.genes.txt > $sample.positive.genes.faa
#SECOND: extract dna sequences
    seqtk subseq $sample.contigs_genes.fna $sample.positive.genes.txt > $sample.positive.genes.fna
#map reads against potentia pAGOs to detect their abundance
    module load SAMtools
    bbmap.sh ref=$sample.positive.genes.fna in=$reads1 in2=$reads2 threads=$used_cpus nodisk out=$sample.reads.vs.positive.genes.bam covstats=$sample.reads.vs.positive.genes.covstats.txt scafstats=$sample.reads.vs.positive.genes.scafstats.txt bs=bs.sh ; sh bs.sh

#extract the %unambiguous reads column (%abundance)
    awk '!/^#/ {print $1 "\t" $10}' $sample.reads.vs.positive.genes.scafstats.txt | sort -nr -k2,2 | sed '1igene\tabundance' > $sample.reads.vs.positive.genes.abundance.txt
#plot %abundance
    $PROJECT/scripts/plot_pAGOs_abundances.R $sample.reads.vs.positive.genes.abundance.txt

#build a stats file containing gene name length and partia status
    awk -F '[ ;]' '/^>/ {if (seqlen){print seqlen}; printf substr($1,2) "\t" $10 "\t" ;seqlen=0; next; } { seqlen += length($0)}END{print seqlen}' $sample.positive.genes.faa | sed '1igene\tpartial\tlength' > $sample.positive.genes.stats.txt

#extract contig names
    awk '!/^#/ {print $1}' $HMM_TBL | rev | cut -d '_' -f2- | rev | sort | uniq > $sample.positive.contigs.txt

    mkdir $sample.positive.contigs.genes
#for each contig extract its called protein sequences and annotate
    parallel -a $sample.positive.contigs.txt "awk  "/{}/" $sample.contigs_genes.faa | cut -d' ' -f1 | cut -d'>' -f2 > $sample.positive.contigs.genes/{}_genes.txt"
    ls $sample.positive.contigs.genes/*_genes.txt | parallel "seqtk subseq $sample.contigs_genes.faa {} > {.}.faa"

    ls $sample.positive.contigs.genes/*_genes.faa | parallel "svr_assign_using_figfams < {} &> {.}_annotations.txt"
    

fi
