#!/usr/bin/Rscript

g <- read.delim("genderReport.2")
f <- read.delim("process.9.fam",sep=" ", header=F)
for (i in 1:nrow(g)) {
  b <- grepl(g[i,1],f[,2])
  f[b,5] <- 3 - f[b,5]
}
write.table(file="a",f,quote=F,sep=" ",row.name=F,col.name=F)
