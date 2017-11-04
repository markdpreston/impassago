#!/usr/bin/Rscript

library("data.table")

args <- commandArgs(trailingOnly=TRUE)
if (length(args) == 0) {
  cat("Usage: data.info.r <dir> <chr>\n")
  quit();
}
dir <- args[1]
chr <- args[2]
setwd(dir)

cat("Args:",dir,chr,"\n")
cat("Start final\n")
tbim <- fread(sprintf("data/%s.final.tbim",chr))
frq <- unique(fread(sprintf("data/%s.final.frq",chr)))

print(dim(frq))
print(dim(tbim))

#tmp1 <- merge(tbim,bim,by.x="V2",by.y="V2",sort=F)
tmp2 <- merge(tbim,frq,by.x="V2",by.y="SNP",sort=F)
print(head(tmp2))
tmp3 <- tmp2[,c("CHR","V4","V2","A1","A2","MAF","NCHROBS"),with=F]
colnames(tmp3)[2:3] <- c("POS","SNP")
tmp3$RS <- sapply(tmp3$SNP,function(x) { unlist(strsplit(x,":",fixed=T))[1] })
tmp3$RS[!grepl("rs",tmp3$RS)] <- "."
tmp4 <- unique(tmp3)
cat("End final\n")

cat("Start reference\n")
ref <- fread("1000G/b37hg19.genes.tsv")
ref <- ref[Chr==chr]
ref$name <- sprintf("chr%02d:%s",as.numeric(ref$Chr),ref$Gene)
#ref <- fread("1000G/b37hg19refFlat.tsv")
#ref <- ref[,c(1,3,5,6),with=F]
#ref$V3 <- gsub("chr","",ref$V3)
#ref <- ref[ref$V3 %in% 1:22]
#ref$name <- sprintf("chr%02d:%s",as.numeric(ref$V3),ref$V1)
#ref[,min:=min(V5),by=name]
#ref[,max:=max(V6),by=name]
#ref <- ref[,c(1:2,5:7),with=F]
#ref <- ref[V3==chr]
#ref <- unique(ref)

tmp4$GENES <- sapply(tmp4$POS, function(x) {
  b <- ref$Start <= x & x <= ref$End
  if(sum(b) > 0) {
    r <- paste0(ref$name[b],collapse=";")
  } else {
    r <- "."
  }
  r
})
cat("End reference\n")

write.table(tmp4,sprintf("data/%s.final.snpinfo",chr),row.names=F,col.names=F,quote=F,sep="\t")
