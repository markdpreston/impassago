#!/bin/bash

phenotype=$1
chr=$2
count=$3

printf -v chr02d   "%02d" "$chr"
printf -v count05d "%05d" "$count"

echo $phenotype $chr02d $count05d
mkdir -p gwas/$phenotype/$count05d/
bin/emmax -v -d 10 -t "data/$chr.final" -p "gwas/$phenotype/$count05d/phenotypes" -k input/process.10.IBS.kinf -o "gwas/$phenotype/$count05d/$chr02d"
pigz -p 4 gwas/$phenotype/$count05d/$chr02d.ps
