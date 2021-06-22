#!/usr/bin/env Rscript

# Bar chart of the top 10 taxonomic classification
top = 10

args = commandArgs(trailingOnly=TRUE)

library(tidyverse)
library(tidylog)

cutoff = 0.001

infile = args[1]
outfile = gsub(".tsv", ".pdf", infile) # Assuming the infile has .tsv extension
title = gsub(".tsv", "", infile)

t1 = read_tsv(args[1])
head(t1)

t2 = t1 %>% mutate (name = ifelse (fraction_total_reads < cutoff, "_other_", name))
head(t2)

t3 = t2 %>% group_by (name) %>% summarize (fraction_total_reads = sum(fraction_total_reads))
head(t3)

t4 = t3 %>% arrange(desc(fraction_total_reads))
head(t4)

t5 = t4[1 : min(top, nrow(t4)), ] # Assuming there is at least one row
head(t5)

t6 = t5 %>% arrange(fraction_total_reads)
head(t6)

t7 = t6 %>% mutate (name = factor(name, levels = t6$name))
head(t7)

# p = ggplot(t5) + geom_bar(aes(x = name, y = fraction_total_reads), stat = "identity") + theme_light() + theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 8)) + ggtitle (title)

p = ggplot(t7) + geom_bar(aes(x = name, y = fraction_total_reads), stat = "identity") + theme_light() + labs (x = "", y = "Relative Abundance") + coord_flip() + ggtitle (title)

ggsave(filename = outfile, plot = p)
