#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

library(tidyverse)
library(tidylog)

infile = args[1]
outfile = gsub(".tsv", ".pdf", infile) # Assuming the infile has .tsv extension
title = gsub(".tsv", "", infile)

t1 = read_tsv(args[1])
head(t1)

p = ggplot(t1) + geom_density (aes(x = length), fill = "gray", alpha = 0.8) + theme_light() + labs (x = "Contigs Sizes", y = "Frequency") + scale_x_continuous (label = scales::comma) + ggtitle (title)
# p = ggplot(t1) + geom_histogram (aes(x = length), fill = "gray", alpha = 0.8) + theme_light() + labs (x = "Contig Sizes", y = "Frequency") + ggtitle (title)

ggsave(filename = outfile, plot = p)
