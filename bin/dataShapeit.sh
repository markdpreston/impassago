#!/bin/bash

chr=$1

#  Extract the filtered data by chromosome, for parallelising.
plink --bfile input/process.10 --chr $chr --make-bed --out data/$chr

#  Phase the input data by chromosome.
if [ $chr eq "23" ]; then chrX="--chrX"; else chrX==""; fi
bin/shapeit2 --input-bed data/$chr               \
             --input-map 1000G/1000GP_Phase3/genetic_map_chr${chr}_combined_b37.txt   \
             --output-max data/$chr              \
             --output-log data/$chr.shapeit.log  \
             --thread $threads $chrX
