#!/bin/bash

set -e
set -u
set -x
set -o pipefail

ts=$(date +%s%N)

sample=$1
echo "--START-- $sample"
date

export KRAKEN=/data/kraken2
export PATH=$PATH:$KRAKEN/bin
export KRAKENDB=$KRAKEN/db

PROJECT=/projects/metaBGC/

cpus=`grep -c ^processor /proc/cpuinfo`
#cpus=20
echo "CPUs: $cpus"

original1=$sample"_1.fastq.gz"
original2=$sample"_2.fastq.gz"
filtered1=$sample"_1.filtered.fastq.gz"
filtered2=$sample"_2.filtered.fastq.gz"
reads1=$sample"_1.final.fastq.gz"
reads2=$sample"_1.final.fastq.gz"

cd $PROJECT/samples/$sample

echo
echo "-- STEP 7 -- antiSmash"
echo -e "sample\tcontig\tantismash_region\tregion_start\tregion_end" >  $sample.bgc.antismash.tmp
$PROJECT/scripts/parse_genbank.py $sample.bgc.antismash.gbk | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.bgc.antismash.tmp
$PROJECT/scripts/join.sh $sample.bgc.antismash.tmp $sample.contigs.kraken.classified.tsv $sample.bgc.antismash.tsv

echo
echo "-- STEP 8 -- Cleaning"
rm -fr $sample.fastq.gz
rm -fr $sample.sra
rm -fr $sample.fastp.html
rm -fr $original1
rm -fr $original2
rm -fr $filtered1
rm -fr $filtered2
rm -fr $reads1
rm -fr $reads2
rm -fr $sample.filtered.fastq.gz
rm -fr $sample.reads.kraken.classified.fq
rm -fr $sample.reads.kraken.unclassified.fq
rm -fr $sample.reads.kraken.classified.tsv
rm -fr $sample.reads.kraken.classified_1.fq
rm -fr $sample.reads.kraken.classified_2.fq
rm -fr $sample.reads.kraken.unclassified_1.fq
rm -fr $sample.reads.kraken.unclassified_2.fq
rm -fr *.kraken
rm -fr *.tmp
rm -fr *.log
rm -fr assembly
rm -fr $sample
rm -fr $sample.fastp.html
rm -fr antismash
gzip *.fa

touch $PROJECT/samples/$sample.SUCCESS

echo "--END-- $sample"
date

tt=$((($(date +%s%N) - $ts)/1000000))
echo "Time: $tt milliseconds"
