#!/usr/bin/Rscript

fam <- read.delim("process.0.fam",sep=" ",header=F)

write.table(file="ids.removeFamilies.csv",cbind(fam[,1:2],1:nrow(fam),fam[,2]),quote=F,row.name=F,col.name=F,sep=" ")
write.table(file="ids.restoreFamilies.csv",cbind(1:nrow(fam),fam[,c(2,1,2)]),quote=F,row.name=F,col.name=F,sep=" ")
