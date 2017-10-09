#!/bin/bash

dir=$1
phenotype=$2
chr=$3
count=$4

printf -v chr02d "%02d" "$chr"

echo $phenotype $chr $count
cd $dir/phenotypes
echo ../bin/emmax -v -d 10 -t ../data/${chr}_final -p emmax/$phenotype/$count/phenotypes -k ../input/process.11.IBS.kinf -o emmax/$phenotype/$count/$chr02d
../bin/emmax -v -d 10 -t "../data/${chr}_final" -p "emmax/$phenotype/$count/phenotypes" -k ../input/process.11.IBS.kinf -o "emmax/$phenotype/$count/$chr02d"
pigz -p 4 emmax/$phenotype/$count/$chr02d.ps
