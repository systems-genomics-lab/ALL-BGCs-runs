#!/bin/bash

set -e
set -u
set -x
set -o pipefail

PROJECT=/projects/metaBGC/
cd $PROJECT

rm -fr tables
mkdir -p tables
cp samples.tsv tables

cd $PROJECT/samples

ls -1 *.SUCCESS | sed 's/.SUCCESS//g' | sort -u | while read sample ; do cat $sample/$sample.filtered.size.txt ; done | sed '1isample\tfiltered' > ../tables/filtered.reads.tsv

ls -1 *.SUCCESS | sed 's/.SUCCESS//g' | sort -u | while read sample ; do cat $sample/$sample.original.size.txt ; done | sed '1isample\original' > ../tables/original.reads.tsv

ls -1 *.SUCCESS | sed 's/.SUCCESS//g' | sort -u | while read sample ; do cat $sample/$sample.reads.bracken.*.tsv | grep -v sample ; done | sed 's/\bNA\b//g' | sed '1isample\tname\ttaxonomy_id\ttaxonomy_lvl\tkraken_assigned_reads\tadded_reads\tnew_est_reads\tfraction_total_reads' > ../tables/reads.taxonomy.tsv

ls -1 *.SUCCESS | sed 's/.SUCCESS//g' | sort -u | while read sample ; do cat $sample/$sample.contigs.kraken.classified.tsv | sed '1d' ; done | sed 's/\bNA\b//g' | sed '1isample\tcontig\ttaxid\tname' > ../tables/contigs.taxonomy.tsv

ls -1 *.SUCCESS | sed 's/.SUCCESS//g' | sort -u | while read sample ; do cat $sample/$sample.contigs.sizes.tsv | sed '1d' ; done | sed 's/\bNA\b//g' | sed '1isample\tcontig\tlength' | gzip -c > ../tables/contigs.sizes.tsv.gz

ls -1 *.SUCCESS | sed 's/.SUCCESS//g' | sort -u | while read sample ; do cat $sample/$sample.bgc.deepbgc.full.tsv | sed '1d' ; done | sed 's/\bNA\b//g' | awk -F $'\t' 'BEGIN {OFS = FS} {print $1"\t"$2"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"$20"\t"$21"\t"$22"\t"$23"\t"$24"\t"$25"\t"$26"\t"$30"\t"$31;}' | sed '1isample\tcontig\tbgc_candidate_id\tnucl_start\tnucl_end\tnucl_length\tnum_proteins\tdeepbgc_score\tproduct_activity\tantibacterial\tcytotoxic\tinhibitor\tantifungal\tproduct_class\tAlkaloid\tNRP\tOther\tPolyketide\tRiPP\tSaccharide\tTerpene\ttaxid\tname' > ../tables/deepbgc.tsv

ls -1 *.SUCCESS | sed 's/.SUCCESS//g' | sort -u | while read sample ; do cat $sample/$sample.bgc.antismash.tsv | sed '1d' ; done | sed 's/\bNA\b//g' | sed '1isample\tcontig\tantismash_region\tregion_start\tregion_end\ttaxid\tname' > ../tables/antismash.tsv


cd $PROJECT/tables/

cat contigs.taxonomy.tsv | cut -f 3 | sed '1d' | sort -nu > taxonomy.ids.txt

$PROJECT/scripts/get_taxonomy.R taxonomy.ids.txt taxonomy.tsv

$PROJECT/scripts/join.sh contigs.taxonomy.tsv taxonomy.tsv contigs.taxonomy.full.tsv

gzip contigs.taxonomy.full.tsv
