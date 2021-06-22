#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

library(tidyverse)
library(tidylog)

a = read_tsv(args[1])
glimpse(a)

b = read_tsv(args[2]) %>% select(-in_cluster)
glimpse(b)

c = read_tsv(args[3]) %>% rename (pfam = name)
glimpse(c)

d = read_tsv(args[4]) %>% rename (taxonomy = name)
glimpse(d)

e = b %>% group_by (sample, contig, gene_start, gene_end, protein_id) %>% top_n(1, deepbgc_score) %>% select(-deepbgc_score)
glimpse(e)
head(e)

f = a %>% inner_join(e) %>% left_join(c) %>% left_join(d) %>% select(-deepbgc_score, -gene_strand)
glimpse(f)
head(f)

write_tsv(f, args[5])
