#!/bin/bash

set -e
set -u
set -x
set -o pipefail

ts=$(date +%s%N)

sample=$1
echo "--START-- $sample"
date

module load Python
module load R

#export KRAKEN=/data/kraken2
#export PATH=$PATH:$KRAKEN/bin
#export KRAKENDB=$KRAKEN/db

PROJECT=/lfs01/workdirs/sadat002u1/argonaute/metaBGC

cpus=`grep -c ^processor /proc/cpuinfo`
used_cpus=$((cpus / 2))
#cpus=20
echo "CPUs: $cpus"
echo "50% of CPUs will be used: $used_cpus"

original1=$sample"_1.fastq.gz"
original2=$sample"_2.fastq.gz"
filtered1=$sample"_1.filtered.fastq.gz"
filtered2=$sample"_2.filtered.fastq.gz"
reads1=$sample"_1.final.fastq.gz"
reads2=$sample"_2.final.fastq.gz"

echo
echo "-- STEP 1 -- Downloading the fastq if not already there"
cd $PROJECT/samples/
# mkdir -p $PROJECT/samples/$sample

#check for the presence of SRA file; if not present, proceed to download from SRA
if [ ! -f $sample/$sample.sra ]; then
    prefetch $sample
#fastq-dump --split-files --split-spot --skip-technical --gzip $sample.sra
    parallel-fastq-dump --split-files --skip-technical --threads $used_cpus --gzip --sra-id $sample/$sample.sra --outdir $sample/
fi

cd $PROJECT/samples/$sample
zcat $original1 | wc -l | awk -v sample=$sample '{print sample"\t"$0/4;}' > $sample.original.size.txt

echo
echo "-- STEP 2 -- QC"
time fastp --verbose --thread $used_cpus --in1 $original1 --in2 $original2 --out1 $filtered1 --out2 $filtered2 --json $sample.fastp.jason --html $sample.fastp.html --report_title $sample
zcat $filtered1 | wc -l | awk -v sample=$sample '{print sample"\t"$0/4;}' > $sample.filtered.size.txt

mv $filtered1 $reads1
mv $filtered2 $reads2
#echo
#echo "-- STEP 2 -- Subsample"
#maxreads=10000000
#seqtk sample -s123 $filtered1 $maxreads | gzip -c > $reads1
#seqtk sample -s123 $filtered2 $maxreads	| gzip -c > $reads2
zcat $reads1 | wc -l | awk -v sample=$sample '{print sample"\t"$0/4;}' > $sample.final.size.txt

echo
#echo "-- STEP 3 -- Taxonomic classification of reads"
#time kraken2 --db $KRAKENDB --threads $cpus --classified-out $sample.reads.kraken.classified#.fq --unclassified-out $sample.reads.kraken.unclassified#.fq --report $sample.reads.kraken --use-names --pair $reads1 $reads2 > $sample.reads.kraken.log 2>&1
#
## cat $sample.reads.kraken.classified.fq | grep '^@' | sed 's/^@//g' | sed 's/ kraken:taxid|/\t/g' | awk -v sample=$sample '{print sample"\t"$0;}' | sed '1isample\tread\ttaxid' > $sample.reads.kraken.classified.tmp
## time $PROJECT/scripts/join.sh $sample.reads.kraken.classified.tmp /data/taxonomy/names.tsv $sample.reads.kraken.classified.tsv
## rm $sample.reads.kraken.classified.tmp
#
#set +e
#set +o pipefail
#
#bracken -d $KRAKENDB -i $sample.reads.kraken -o $sample.reads.bracken.species.tmp -l S -t 1
#bracken -d $KRAKENDB -i $sample.reads.kraken -o $sample.reads.bracken.genus.tmp -l G -t 1
#bracken -d $KRAKENDB -i $sample.reads.kraken -o $sample.reads.bracken.order.tmp -l O -t 1
#bracken -d $KRAKENDB -i $sample.reads.kraken -o $sample.reads.bracken.family.tmp -l F -t 1
#bracken -d $KRAKENDB -i $sample.reads.kraken -o $sample.reads.bracken.class.tmp -l C -t 1
#bracken -d $KRAKENDB -i $sample.reads.kraken -o $sample.reads.bracken.phylum.tmp -l P -t 1
#bracken -d $KRAKENDB -i $sample.reads.kraken -o $sample.reads.bracken.domain.tmp -l D -t 1
#
#cat $sample.reads.bracken.species.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.reads.bracken.species.tsv
#cat $sample.reads.bracken.species.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.reads.bracken.species.tsv
#$PROJECT/scripts/plot_abundances.sh $sample.reads.bracken.species.tsv
#
#cat $sample.reads.bracken.genus.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.reads.bracken.genus.tsv
#cat $sample.reads.bracken.genus.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.reads.bracken.genus.tsv
#$PROJECT/scripts/plot_abundances.sh $sample.reads.bracken.genus.tsv
#
#cat $sample.reads.bracken.order.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.reads.bracken.order.tsv
#cat $sample.reads.bracken.order.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.reads.bracken.order.tsv
#$PROJECT/scripts/plot_abundances.sh $sample.reads.bracken.order.tsv
#
#cat $sample.reads.bracken.family.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.reads.bracken.family.tsv
#cat $sample.reads.bracken.family.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.reads.bracken.family.tsv
#$PROJECT/scripts/plot_abundances.sh $sample.reads.bracken.family.tsv
#
#cat $sample.reads.bracken.class.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.reads.bracken.class.tsv
#cat $sample.reads.bracken.class.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.reads.bracken.class.tsv
#$PROJECT/scripts/plot_abundances.sh $sample.reads.bracken.class.tsv
#
#cat $sample.reads.bracken.phylum.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.reads.bracken.phylum.tsv
#cat $sample.reads.bracken.phylum.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.reads.bracken.phylum.tsv
#$PROJECT/scripts/plot_abundances.sh $sample.reads.bracken.phylum.tsv
#
#cat $sample.reads.bracken.domain.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.reads.bracken.domain.tsv
#cat $sample.reads.bracken.domain.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.reads.bracken.domain.tsv
#$PROJECT/scripts/plot_abundances.sh $sample.reads.bracken.domain.tsv
#
#set -e
#set -o pipefail
#
echo
echo "-- STEP 4 -- Assembly"
#rm -fr assembly/
# time megahit -1 $sample.reads.kraken.classified_1.fq -2 $sample.reads.kraken.classified_2.fq --out-dir assembly --out-prefix $sample --cleaning-rounds 10 --num-cpu-threads $cpus > $sample.megahit.log 2>&1
time megahit -1 $reads1 -2 $reads2 --out-dir assembly --out-prefix $sample --cleaning-rounds 10 --num-cpu-threads $used_cpus > $sample.megahit.log 2>&1
tail -2 $sample.megahit.log | awk -v sample=$sample '{print sample"\t"$0;}' | grep N50 | grep -v ALL  | sed 's/ \+/\t/g' | cut -f 1,5,8,11,14,17,20 > $sample.contigs.stats.tsv

$PROJECT/scripts/get_sizes.py assembly/$sample.contigs.fa | awk -v sample=$sample '{print sample"\t"$0;}' | sed '1isample\tcontig\tlength' > $sample.contigs.sizes.tsv
$PROJECT/scripts/plot_sizes.R $sample.contigs.sizes.tsv
$PROJECT/scripts/filter_sizes.py assembly/$sample.contigs.fa $sample.contigs.fa 1000


echo
echo "-- STEP 5 -- Mapping reads to contigs"

bbmap.sh ref=$sample.contigs.fa in=$reads1 in2=$reads2 threads=$used_cpus nodisk out=$sample.reads.vs.contigs.bam covstats=$sample.reads.vs.contigs.covstats.txt scafstats=$sample.reads.vs.contigs.scafstats.txt bs=bs.sh ; sh bs.sh


echo "-- STEP 6 -- Genome binning"

runMetaBat.sh $sample.contigs.fa $sample.reads.vs.contigs_sorted.bam

echo "-- STEP 7 -- Check binned genomes using CheckM"

module load Python

checkm lineage_wf -t $used_cpus -x fa $sample.contigs.fa.metabat-bins/ $sample.contigs.fa.metabat-bins.checkm/

#checkm extended statistics in a tabular tsv format

$PROJECT/scripts/checkm_stats_table.py "$sample.contigs.fa.metabat-bins.checkm/storage/bin_stats_ext.tsv" > "$sample.contigs.fa.metabat-bins.checkm/bin_stats_ext.tsv"

#Checkm plots
checkm nx_plot -x fa $sample.contigs.fa.metabat-bins/ $sample.contigs.fa.metabat-bins.checkm/plots/
checkm len_hist -x fa $sample.contigs.fa.metabat-bins/ $sample.contigs.fa.metabat-bins.checkm/plots/
checkm marker_plot -x fa $sample.contigs.fa.metabat-bins.checkm/ $sample.contigs.fa.metabat-bins/ $sample.contigs.fa.metabat-bins.checkm/plots/



echo "-- STEP 8 -- Taxonomic classification of binned genomes (MAGs)"

gtdbtk classify_wf --cpus $used_cpus -x fa --genome_dir $sample.contigs.fa.metabat-bins/ --out_dir $sample.contigs.fa.metabat-bins.gtdbtk/ --prefix $sample


echo "-- STEP 9 -- Argonaute identification"

#1.gene calling from all contigs

prodigal -a $sample.contigs_genes.faa -d $sample.contigs_genes.fna -i $sample.contigs.fa -p meta

#2.hmmsearch against argonaute model built from SMART prokaryotic argonautes

hmmsearch -o $sample.contigs_genes.vs.prok.piwi.hmm.out.txt --tblout $sample.contigs_genes.vs.prok.piwi.hmm.tblout.txt --noali -E 0.001 $PROJECT/ref/prok.piwi.hmm $sample.contigs_genes.faa


echo "-- STEP 10 -- Annotation of contigs to which identified argonaute proteins belong, if any"

module load Perl

$PROJECT/scripts/annotate_positive_contig.sh $sample.contigs_genes.vs.prok.piwi.hmm.tblout.txt

#rm -fr assembly/
#
#echo
#echo "-- STEP 5 -- Taxonomic classification of contigs"
#time kraken2 --db $KRAKENDB --threads $cpus --classified-out $sample.contigs.kraken.classified.fa --unclassified-out $sample.contigs.kraken.unclassified.fa --report $sample.contigs.kraken --use-names $sample.contigs.fa > $sample.contigs.kraken.log 2>&1
#
#cat $sample.contigs.kraken.classified.fa | grep '>' | sed 's/>//g' | sed 's/ .*|/\t/g' | awk -v sample=$sample '{print sample"\t"$0;}' | sed '1isample\tcontig\ttaxid' > $sample.contigs.kraken.classified.tmp
#$PROJECT/scripts/join.sh $sample.contigs.kraken.classified.tmp /data/taxonomy/names.tsv $sample.contigs.kraken.classified.tsv
#
#set +e
#set +o pipefail
#
#bracken -d $KRAKENDB -i $sample.contigs.kraken -o $sample.contigs.bracken.species.tmp -l S -t 1
#bracken -d $KRAKENDB -i $sample.contigs.kraken -o $sample.contigs.bracken.genus.tmp -l G -t 1
#bracken -d $KRAKENDB -i $sample.contigs.kraken -o $sample.contigs.bracken.order.tmp -l O -t 1
#bracken -d $KRAKENDB -i $sample.contigs.kraken -o $sample.contigs.bracken.family.tmp -l F -t 1
#bracken -d $KRAKENDB -i $sample.contigs.kraken -o $sample.contigs.bracken.class.tmp -l C -t 1
#bracken -d $KRAKENDB -i $sample.contigs.kraken -o $sample.contigs.bracken.phylum.tmp -l P -t 1
#bracken -d $KRAKENDB -i $sample.contigs.kraken -o $sample.contigs.bracken.domain.tmp -l D -t 1
#
#cat $sample.contigs.bracken.species.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.contigs.bracken.species.tsv
#cat $sample.contigs.bracken.species.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.contigs.bracken.species.tsv
#
#cat $sample.contigs.bracken.genus.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.contigs.bracken.genus.tsv
#cat $sample.contigs.bracken.genus.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.contigs.bracken.genus.tsv
#
#cat $sample.contigs.bracken.order.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.contigs.bracken.order.tsv
#cat $sample.contigs.bracken.order.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.contigs.bracken.order.tsv
#
#cat $sample.contigs.bracken.family.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.contigs.bracken.family.tsv
#cat $sample.contigs.bracken.family.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.contigs.bracken.family.tsv
#
#cat $sample.contigs.bracken.class.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.contigs.bracken.class.tsv
#cat $sample.contigs.bracken.class.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.contigs.bracken.class.tsv
#
#cat $sample.contigs.bracken.phylum.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.contigs.bracken.phylum.tsv
#cat $sample.contigs.bracken.phylum.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.contigs.bracken.phylum.tsv
#
#cat $sample.contigs.bracken.domain.tmp | head -1 | awk '{print "sample\t"$0;}' > $sample.contigs.bracken.domain.tsv
#cat $sample.contigs.bracken.domain.tmp | sed '1d' | sort -k 7 -nr | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.contigs.bracken.domain.tsv
#
#set -e
#set -o pipefail
#
#echo
#echo "-- STEP 6 -- deepBGC"
#time deepbgc pipeline --prodigal-meta-mode --output $sample $sample.contigs.fa  > $sample.bgc.deepbgc.log 2>&1
#cat $sample/$sample.bgc.tsv | sed '1d' | awk -v sample=$sample '{print sample"\t"$0;}' | sed '1isample\tcontig\tdetector\tdetector_version\tdetector_label\tbgc_candidate_id\tnucl_start\tnucl_end\tnucl_length\tnum_proteins\tnum_domains\tnum_bio_domains\tdeepbgc_score\tproduct_activity\tantibacterial\tcytotoxic\tinhibitor\tantifungal\tproduct_class\tAlkaloid\tNRP\tOther\tPolyketide\tRiPP\tSaccharide\tTerpene\tprotein_ids\tbio_pfam_ids\tpfam_ids' > $sample.bgc.full.tmp
#cat $sample/$sample.pfam.tsv | sed '1d' | awk -v sample=$sample '{print sample"\t"$0;}' | sed '1isample\tcontig\tprotein_id\tgene_start\tgene_end\tgene_strand\tpfam_id\tprotein_id\tdeepbgc_score\tin_cluster' > $sample.bgc.pfam.tmp
#
#$PROJECT/scripts/join.sh $sample.bgc.pfam.tmp $sample.contigs.kraken.classified.tsv $sample.bgc.deepbgc.pfam.tsv
#$PROJECT/scripts/join.sh $sample.bgc.full.tmp $sample.contigs.kraken.classified.tsv $sample.bgc.deepbgc.full.tsv
#
#$PROJECT/scripts/extract_proteins.py $sample.bgc.deepbgc.full.tsv | sed '1d' | sed '1isample\tcontig\tbgc_candidate_id\tdeepbgc_score\tproduct_activity\tprotein_id' > $sample.bgc.deepbgc.proteins.tsv
#$PROJECT/scripts/extract_pfams.R $sample.bgc.deepbgc.proteins.tsv $sample.bgc.pfam.tmp $PROJECT/ref/pfam.tsv $sample.contigs.kraken.classified.tsv $sample.bgc.deepbgc.pfam.tsv
#
#mv $sample/$sample.bgc.gbk $sample.bgc.deepbgc.gbk
#
#echo
#echo "-- STEP 7 -- antiSmash"
#time antismash --cpus $cpus --genefinding-tool prodigal --output-dir antismash $sample.contigs.fa > $sample.bgc.antismash.log 2>&1
#mv antismash/$sample.contigs.gbk $sample.bgc.antismash.gbk
#echo -e "sample\tcontig\tantismash_region\tregion_start\tregion_end" >  $sample.bgc.antismash.tmp
#$PROJECT/scripts/parse_genbank.py $sample.bgc.antismash.gbk | awk -v sample=$sample '{print sample"\t"$0;}' >> $sample.bgc.antismash.tmp
#$PROJECT/scripts/join.sh $sample.bgc.antismash.tmp $sample.contigs.kraken.classified.tsv $sample.bgc.antismash.tsv
#
#echo
#echo "-- STEP 8 -- Cleaning"
#rm -fr $sample.fastq.gz
#rm -fr $sample.sra
#rm -fr $sample.fastp.html
#rm -fr $original1
#rm -fr $original2
#rm -fr $filtered1
#rm -fr $filtered2
#rm -fr $reads1
#rm -fr $reads2
#rm -fr $sample.filtered.fastq.gz
#rm -fr $sample.reads.kraken.classified.fq
#rm -fr $sample.reads.kraken.unclassified.fq
#rm -fr $sample.reads.kraken.classified.tsv
#rm -fr $sample.reads.kraken.classified_1.fq
#rm -fr $sample.reads.kraken.classified_2.fq
#rm -fr $sample.reads.kraken.unclassified_1.fq
#rm -fr $sample.reads.kraken.unclassified_2.fq
#rm -fr *.kraken
#rm -fr *.tmp
#rm -fr *.log
#rm -fr assembly
#rm -fr $sample
#rm -fr $sample.fastp.html
#rm -fr antismash
#gzip *.fa
#
#touch $PROJECT/samples/$sample.SUCCESS
#
#echo "--END-- $sample"
#date
#
#tt=$((($(date +%s%N) - $ts)/1000000))
#echo "Time: $tt milliseconds"
