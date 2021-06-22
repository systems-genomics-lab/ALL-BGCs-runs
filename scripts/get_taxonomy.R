#!/usr/bin/env Rscript

library(tidyverse)
library(tidylog)
library(taxize)
library(reshape2)
library(tictoc)

args = commandArgs(trailingOnly=TRUE)
infile = args[1]
outfile = args[2]

t1 = read.table(infile, header = FALSE, col.names =c("taxid"))

ids = sort(unique(unlist(t1$taxid)))

length(ids)
head(ids)
tail(ids)

tic()
classification = classification(ids, db = "ncbi")
toc()

t2 = NULL

for (i in 1:length(ids)) {
    id = ids[i]
    df1 = classification[[i]]
    df2 = data.frame (taxid = id, df1)
    t2 = t2 %>% bind_rows(df2)
}

head(t2)

# t3 = t2 %>% filter (!(rank %in% c("no rank", "clade")) | id %in% c(1, 131567)) %>% dcast (taxid ~ rank, value.var = "name")
t3 = t2 %>% filter (rank %in% c("superkingdom", "phylum", "class", "order", "family", "genus", "species") | id %in% c(1, 131567)) %>% dcast (taxid ~ rank, value.var = "name")
head(t3)

t4 = t3 %>% select(taxid, species, genus, family, order, class, phylum, superkingdom)
head(t4)

t5 = t4 %>%
mutate (superkingdom = ifelse(is.na(superkingdom), "%", superkingdom)) %>%
mutate (phylum = ifelse(is.na(phylum), paste("%", superkingdom, sep = ""), phylum)) %>%
mutate (class = ifelse(is.na(class), paste("%", phylum, sep = ""), class)) %>%
mutate (order = ifelse(is.na(order), paste("%", class, sep = ""), order)) %>%
mutate (family = ifelse(is.na(family), paste("%", order,sep =  ""), family)) %>%
mutate (genus = ifelse(is.na(genus), paste("%", family, sep = ""), genus)) %>%
mutate (species = ifelse(is.na(species), paste("%", genus, sep = ""), species))
head(t5)


t6 = t5 %>%
mutate (superkingdom = str_trim(gsub("^%+", "Unclassified", superkingdom))) %>%
mutate (phylum = str_trim(gsub("^%+", "Unclassified ", phylum))) %>%
mutate (class = str_trim(gsub("^%+", "Unclassified ", class))) %>%
mutate (order = str_trim(gsub("^%+", "Unclassified ", order))) %>%
mutate (family = str_trim(gsub("^%+", "Unclassified ", family))) %>%
mutate (genus = str_trim(gsub("^%+", "Unclassified ", genus))) %>%
mutate (species = str_trim(gsub("^%+", "Unclassified ", species)))
head(t6)

t7 = t1 %>% left_join(t6)
head(t7)

nrow(t1)
nrow(t7)

write_tsv(t7, outfile)

