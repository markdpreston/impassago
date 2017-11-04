#!/usr/bin/Rscript

library(data.table)
library(bit64)

args <- commandLine(trailing=F)
phenotype <- args[1]
count <- args[2]
root <- "gwas"
data <- fread("input/data.phenotypes.tsv")

calculateResiduals <- function (name,number,permute=F) {
  number <- sprintf("%05d",number)
  cat(number,"")
  phenotype <- data[[name]]
  b <- !is.na(phenotype) & !is.na(data$gender) & !is.na(data$age)
  phenotype <- phenotype[b]
  if (permute) {
    phenotype <- phenotype[sample(length(phenotype))]
  }
  model <- lm(phenotype ~ data$gender[b] + data$age[b] + data$gender[b]*data$age[b])
  r <- rep(NA,nrow(p))
  r[b] <- residuals(model)
  residuals <- cbind(data[,c("FID","IID"),with=F],r)
  cat(name,number,permute,"\n")
  system(sprintf("mkdir -p %s/%s/%s",root,name,number))
  write.table(residuals,file=sprintf("%s/%s/%s/phenotypes",root,name,number),quote=F,row.names=F,col.names=F,sep="\t")
  r
}


cat(p,"\n")
calculateResiduals(phenotype,0)
for (i in 1:count) {
  calculateResiduals(phenotype,i,T)
}
cat(Sys.time(),"\n")

