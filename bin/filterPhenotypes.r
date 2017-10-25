#!/usr/bin/Rscript

library(data.table)
library(bit64)

#
#  Assumes phenotype file conforms to FAM format.
#
p <- fread("phenotypes.tsv")
fam <- fread("data.fam")


