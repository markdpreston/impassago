#!/bin/bash

echo "impute2 $1 $2"

dir=$1
chr=$2
start=$3
end=$((start+5000000))
printf -v name "%09d" $start
echo $chr
echo $start

cd $dir

if [ $chr eq "23" ]; then chrX="-chrX"; else chrX=""; fi

if [ ! -s data/${chr}_impute2_$name_warnings ]
then
  bin/impute2 -sample_g data/$chr.sample -known_haps_g data/${chr}.haps \
              -use_prephased_g -m 1000G/1000GP_Phase3/genetic_map_chr${chr}_combined_b37.txt \
              -h 1000G/1000GP_Phase3/1000GP_Phase3_chr${chr}.hap.gz -l 1000G/1000GP_Phase3/1000GP_Phase3_chr${chr}.legend.gz \
              -allow_large_regions -int $start $end -Ne 20000 -o data/${chr}_impute2_$name $chrX
fi
