#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

library(tidyverse)

t1 = read_tsv(args[1])

t2 = t1 %>% group_by(sample, read) %>% filter (row_number() == 1)

write_tsv(t2, args[2])
