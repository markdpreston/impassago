#!/usr/bin/Rscript

library(data.table)
library(bit64)

makePhenotypes <- function() {
  p1 <- fread("phenotypesMain.csv")
  p2 <- fread("phenotypesIron.csv")
  f <- fread(".process.10.fam",header=F)
  colnames(f) <- c("FID","cWKNO","PID","MID","Sex","Phenotype")
  p <- merge(f,p1,by="cWKNO",sort=F)
  p <- merge(p,p2,by="cWKNO",sort=F)

  ### Corrections - not needed now
  p <- p[!is.na(ageinyears)]
#  p$dob3 <- as.Date(p$dob2,"%d%b%Y")
#  p$dvisdate3 <- as.Date(p$dvisdate2,"%d%b%Y")
#  p$ageinyears <- as.numeric((p$dvisdate3 - p$dob3) / 365.25)
#  p$ageinyears[p$ageinyears < 0] <- 100 + p$ageinyears[p$ageinyears < 0]

  write.table(p[,c("FID","cWKNO"),with=F],"samples.keep",quote=F,row.names=F,col.names=F,sep=" ")
  write.table(p,"phenotypes.tsv",quote=F,row.names=F,sep="\t")
}

makePhenotypes()

quit()

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
  system(sprintf("mkdir -p %s/%s/%s",root,name,number))
  write.table(residuals,file=sprintf("%s/%s/%s/phenotypes",root,name,number),quote=F,row.names=F,col.names=F,sep="\t")
  r
}

p <- fread("../input/phenotypes.tsv")
analysisPhenotypes <- read.delim("analysisPhenotypes",stringsAsFactors=F,header=F)[,1]
analysisPhenotypes <- analysisPhenotypes[!grepl("#",analysisPhenotypes)]

for (n in analysisPhenotypes) {
  cat(n,"\n")
  calculateResiduals(n,0)
  for (i in 1:1000) {
    calculateResiduals(n,i,T)
  }
  cat(Sys.time(),"\n")
}

