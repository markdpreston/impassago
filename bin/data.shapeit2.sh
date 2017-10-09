#!/bin/bash

dir=$1
chr=$2
threads=$3

if [ $chr eq "23" ]; then chrX="--chrX"; else chrX==""; fi

cd $dir
bin/shapeit2 --input-bed data/${chr}       \
             --input-map 1000G/1000GP_Phase3/genetic_map_chr${chr}_combined_b37.txt   \
             --output-max data/${chr}      \
             --output-log data/${chr}.shapeit.log  \
             --thread $threads $chrX
