#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

library(tidyverse)
library(tidylog)

t1 = read_tsv(args[1])
glimpse(t1)

t2 = read_tsv(args[2])
glimpse(t2)

t3 = t1 %>% left_join(t2)
glimpse(t3)
head(t3)

write_tsv(t3, args[3])
