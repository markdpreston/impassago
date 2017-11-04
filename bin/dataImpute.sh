#!/bin/bash

#  Run IMPUTE2 over one 5Mb section at a time.
chr=$1
start=$2
end=$((start+5000000))
printf -v name "%09d" $start  #  Ordered output for ls'ing
if [ $chr eq "23" ]; then chrX="-chrX"; else chrX=""; fi
if [ ! -s data/$chr.impute2.${name}_warnings ]
then
  bin/impute2 -sample_g data/$chr.sample -known_haps_g data/$chr.haps \
              -use_prephased_g -m 1000G/1000GP_Phase3/genetic_map_chr${chr}_combined_b37.txt \
              -h 1000G/1000GP_Phase3/1000GP_Phase3_chr$chr.hap.gz -l 1000G/1000GP_Phase3/1000GP_Phase3_chr$chr.legend.gz \
              -allow_large_regions -int $start $end -Ne 20000 -o data/$chr.impute2.$name $chrX
fi
