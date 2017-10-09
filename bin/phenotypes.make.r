#!/usr/bin/Rscript

library(data.table)
library(bit64)

root <- "emmax"

calculateResiduals <- function (name,number,permute=F) {
  number <- sprintf("%04d",number)
  cat(number,"")
  phenotype <- p[[name]]
  b <- !is.na(phenotype) & !is.na(p$Sex.x) & !is.na(p$ageinyears)
  phenotype <- phenotype[b]
  if (permute) {
    phenotype <- phenotype[sample(length(phenotype))]
  }
  model <- lm(phenotype ~ p$Sex.x[b] + p$ageinyears[b] + p$Sex.x[b]*p$ageinyears[b])
  r <- rep(NA,nrow(p))
  r[b] <- residuals(model)
  residuals <- cbind(p[,c("FID","cWKNO"),with=F],r)
  cat(name,number,permute,"\n")
  system(sprintf("mkdir -p %s/%s/%s",root,name,number))
  write.table(residuals,file=sprintf("%s/%s/%s/phenotypes",root,name,number),quote=F,row.names=F,col.names=F,sep="\t")
  r
}

p <- fread("../input/phenotypes.tsv")
analysisPhenotypes <- read.delim("../analysisPhenotypes",stringsAsFactors=F,header=F)[,1]
analysisPhenotypes <- analysisPhenotypes[!grepl("#",analysisPhenotypes)]

for (n in analysisPhenotypes) {
  cat(n,"\n")
#  calculateResiduals(n,0)
#  for (i in 1:1000) {
#    calculateResiduals(n,i,T)
#  }
  for (i in 1001:10000) {
    calculateResiduals(n,i,T)
  }
  cat(Sys.time(),"\n")
}

