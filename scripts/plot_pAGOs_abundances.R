#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)


infile = args[1]
outfile = gsub(".txt", ".pdf", infile) # Assuming the infile has .tsv extension
title = gsub(".txt", "", infile)

t1 = read.table(infile, header=TRUE, sep="\t")
head(t1)

pdf(file = outfile,   # The directory you want to save the file in
    width = 6, # The width of the plot in inches
    height = 8) # The height of the plot in inches
par(mar=c(10,4,4,1)+.1)
plot(t1$abundance, type="o", ylim=(c(0,max(t1$abundance))), xaxt="n", lwd=2, col="red", pch=1, cex=1.5, ylab="% Abundance", main=title, xlab="")
axis(1, at=1:length(t1$gene), labels=t1$gene, las=2)
mtext("pAGOs", side=1, line=8)
dev.off()


