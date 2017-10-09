#!/usr/bin/Rscript

phenotypes <- fread("analysisPhenotypes",header=F)

#for (chr in 22) {
for (chr in 1:22) {
  cat(chr,"\n")
  snpinfo <- fread(sprintf("data/%d_final.snpinfo",chr))
  colnames(snpinfo) <- c("CHR","BP","CODE","Ref","Alt","MAF","NCHROBS","SNP","Genes")
  for (p in phenotypes$V1) {
#  for (p in "nRBC") {
    cat(p,"\n")
    ps <- read.delim(sprintf("phenotypes/emmax/%s/0000/%02d.ps.gz",p,chr),header=F)
    colnames(ps) <- c("Code2","T","P")
    write.table(x=cbind(snpinfo,ps),file=sprintf("phenotypes/data/%s.tsv",p),row.names=F,quote=F,sep="\t",col.names=(chr==1),append=(chr!=1))
  }
}
