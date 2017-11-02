#!/usr/bin/Rscript

f <- read.delim("1.fam",sep=" ",header=F)
s <- read.delim("subjects.tsv")
p1 <- read.delim("p1.tsv")
p2 <- read.delim("p2.tsv")

m1 <- merge(f,s,by.x=2,by.y="IID",all.x=T,all.y=F)
m2 <- merge(m1,p1,by="cWKNO",all.x=T,all.y=F)
m3 <- merge(m2,p2,by="cWKNO",all.x=T,all.y=F)
m4 <- m3[match(f[,2],m3[,2]),]
write.table(m4,file="phenotypes.all.tsv",row.names=F,col.names=T,quote=F,sep="\t")

#print(table(m4$sex))
#print(table(m4$Sex))
#print(table(m4[,6]))
#print(table(m4$Sex,m4[,6]))
#print(m4[m4$Sex != m4[,6] & !is.na(m4$Sex) & !is.na(m4[,6]),1:7])

p3 <- read.delim("phenotypes",stringsAsFactors=F,header=F)[,1]
p3 <- p3[!grepl("#",p3)]
####print(p3[! p3 %in% names(m4)])

#p4 <- m4[,c("V1","V2","cWKNO","Sex","ageinyears",p3)]
#write.table(m4,file="phenotypes.modified.tsv",row.names=F,col.names=T,quote=F,sep="\t")
p4 <- read.delim("phenotypes.modified.tsv")

sink("missingData.txt")
badSamples <- c()
#cat(sum(!is.na(p4$Sex)),sum(!is.na(p4$ageinyears),sum(!is.na(p4$Sex) & !is.na(p4$ageinyears))),nrow(p4),"\n",sep="\t")
cat("Pheno\tModel\tData\tMissing Samples\n")
for (n in p3) {
  model <- lm(p4[,n] ~ p4$Sex + p4$ageinyears + p4$Sex*p4$ageinyears)
  b <- as.numeric(rownames(model$model))
#  r <- rep(NA,nrow(p4))
#  r[b] <- residuals(model)
#  residuals <- cbind(p4[,1:2],r)
#  write.table(residuals,file=sprintf("phenotype.%s",n),quote=F,row.names=F,col.names=F)
  bCovariates <- (1:nrow(p4))[!is.na(p4[,n])]
  bs <- bCovariates[! bCovariates %in% b]
  cat(substr(n,1,6),length(b),length(bCovariates),bs,"\n",sep="\t")
  badSamples <- c(badSamples,bs)
}
badSamples <- sort(unique(badSamples))
cat("\nCombined Missing Samples:\n")
cat(badSamples,"\n",sep="\t")
cat("\nTable of samples with missing data\n")
print(p4[badSamples,c(8,1,22,93)])
sink()

