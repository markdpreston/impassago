#!/usr/bin/Rscript
library("data.table")
library("IRanges")

r1 <- fread("b37hg19.refFlat.tsv",header=F)
r2 <- r1[,c(1,3,5,6)]
colnames(r2) <- c("Gene","Chr","Start","End")
r2 <- r2[!grepl("_",Chr) & ! grepl("chrY",Chr)]
r2 <- r2[,Chr:=gsub("chr","",Chr)]

genes <- c()
for (g1 in unique(r2$Gene)) {
  for (g2 in split(r2[Gene==g1],by="Chr")) {
    r3 <- reduce(IRanges(start=g2$Start,end=g2$End))
    genes <- rbind(genes,cbind(rep(g1,length(r3)),rep(g2$Chr[1],length(r3)),start(r3),end(r3)))
  }
}
genes <- data.table(genes)
colnames(genes) <- c("Gene","Chr","Start","End")
genes <- genes[,Start:=as.numeric(Start)]
genes <- genes[,End:=as.numeric(End)]
genes <- genes[order(Chr,Start,End)]
write.table(genes,file="b37hg19.genes2.tsv",row.names=F,quote=F,sep="\t")

