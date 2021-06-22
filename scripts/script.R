library(tidyverse)
library(tidylog)
library(printr)

samples = read_tsv("../tables/samples.tsv")
glimpse(samples)

reads = read_tsv("../tables/filtered.reads.tsv")
glimpse(reads)

samples = samples %>% inner_join(reads)
glimpse(samples)

ggplot(samples) +
  geom_bar(aes(x = project))

t1 = read_tsv("../tables/reads.taxonomy.tsv") %>% filter(taxonomy_lvl == "G")
glimpse(t1)

t2 = samples %>% inner_join(t1) %>% mutate (abundance = as.double(fraction_total_reads))
head(t2)

glimpse(t2)

max = t2 %>% group_by(taxonomy_id, name) %>% summarise(max = max(abundance)) %>% arrange(desc(max))
head(max)

major = max %>% filter(max > 0.01)
head(major)
nrow(major)

t3 = t2 %>%
  mutate(name = ifelse(name %in% major$name, name, "_other_")) %>%
  group_by(project, sample, name) %>%
  summarise(abundance = sum(abundance))
head(t3)

medians = t3 %>% group_by(project, name) %>% summarise(abundance = median(abundance))
head(medians)

ggplot(medians) +
  geom_bar(aes(x = project, y = abundance, fill = name), color = "white", stat = "identity", alpha = 0.8)

t4 = read_tsv("../tables/contigs.taxonomy.tsv") %>% filter(taxonomy_lvl == "G")
glimpse(t4)

t5 = read_tsv("../tables/deepbgc.tsv")
glimpse(t5)

t6 = t5 %>% left_join(t4) %>% inner_join(samples)
head(t6)

t7 = t6 %>% select(project, sample, contig, product_activity, name, fraction_total_reads)
head(t7)

t8 = t7 %>% na.omit()
head(t8)

t9 = t8 %>% group_by(project, name, product_activity) %>% summarise(abundane = median(as.double(fraction_total_reads)))
head(t9)

ggplot(t9) +
  geom_tile(aes(x = project, product_activity, fill = abundane)) +
  scale_fill_distiller(palette = "RdBu")



t5 = read_tsv("../tables/antismash.tsv") %>% select(-name, -taxid)
glimpse(t5)

t6 = t5 %>% left_join(t4) %>% inner_join(samples)
head(t6)

t7 = t6 %>% select(project, sample, contig, antismash_region, name, fraction_total_reads)
head(t7)

t8 = t7 %>% na.omit()
head(t8)

t9 = t8 %>% group_by(sample, name, antismash_region) %>% summarise(abundane = median(as.double(fraction_total_reads)))
head(t9)

ggplot(t9) +
  geom_tile(aes(x = sample, antismash_region, fill = abundane)) +
  scale_fill_distiller(palette = "RdBu")

t9 = t8 %>% group_by(project, name, antismash_region) %>% summarise(abundane = median(as.double(fraction_total_reads)))
head(t9)

ggplot(t9) +
  geom_tile(aes(x = project, antismash_region, fill = abundane)) +
  scale_fill_distiller(palette = "RdBu")
