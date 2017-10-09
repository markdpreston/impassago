#!/bin/bash

date

if [ -z ${1+x} ]; then echo "No chromosome selected"; exit; fi

date

cd ~/cluster/branwen/

mkdir -p data
chr=$1
echo $chr
threads=16
echo $threads
input="input/process.10"  ### pedigree data?

#if [ ! -s data/${chr}.tped ]
#then
  #  Extract this chromosome from the input data.
  if [ ! -s data/${chr}.bed ]
  then
    echo "threeRing: Extract chromosome"
    #  Use plink to separate a chromosome
    plink --bfile $input --chr $chr --make-bed --out data/${chr}
  fi

  #  Pre-phase input data.
  if [ ! -s data/${chr}.haps ]
  then
    echo "threeRing: Prephase"
    if [ $chr eq "23" ]; then chrX="--chrX"; else chrX==""; fi
    #  Prephase haplotypes with shape it: data/chr.phased.{haps|sample}
    bin/shapeit --input-bed data/${chr}       \
                --input-map 1000G/1000GP_Phase3/genetic_map_chr${chr}_combined_b37.txt   \
                --output-max data/${chr}      \
                --output-log data/${chr}.shapeit.log  \
                --thread $threads $chrX
#                --thread $threads --duohmm
    #  Get list of marker strand info
    #  grep '^10' strandfile.txt > data/${chr}_strand.strand
  fi
#fi

exit

asdasd

#if [ -e "/home/mark/asdfsf" ]
#then
  #  Run imputation in parallel.
  if [ ! -e data/${chr}_impute2_245000000_warnings ]
  then
    echo "threeRing: impute"
    seq 0 5000000 245000000 | xargs -n 1 -P $threads bin/impute.sh $chr
  fi

  #  Amalgamate raw data and delete raw data.
  if [ ! -s data/${chr}.gen ]
  then
    echo "threeRing: make gen and clean"
    cat data/${chr}_impute2_[012]??000000 > data/${chr}.gen
    echo "Removed intermediary impute2 files" > data/${chr}_impute2_245000000_warnings
  fi

  #  Convert impute files to plink bed for storage, re-adding the old families
  if [ ! -s data/${chr}_impute2.bed ]
  then
    echo "threeRing: bedify"
    bin/plink --data data/${chr} --oxford-single-chr ${chr} --update-ids input/ids.old.restoreFamilies.csv --make-bed --maf 0.0000001 --out data/${chr}_impute2 --hard-call-threshold 0.05
    pigz -p $threads data/${chr}.gen
    mv data/${chr}_impute2.log data/${chr}_impute2.bedify.log
  fi

  #  Convert to tped for emmax processing
  if [ ! -e data/${chr}_impute2.tped.gz ]
  then
    echo "threeRing: tpedify"
    bin/plink -bfile data/${chr}_impute2 --recode 12 transpose --output-missing-genotype 0 --out data/${chr}_impute2
    pigz -p $threads data/${chr}_impute2.tped
  fi

#fi

date

exit

#  --------------------------------------------------------------------------------------------------------

#  Get phenotype file
#awk '{print $1,$2,$6}' data/${chr}_impute2.tfam > data/${chr}_impute2.tphenotype

#  Run emmax
# emmax -v -d 10 -t data/${chr}_impute2 -p data/${chr}_impute2.tphenotype -k ../130205emmax.hIBS.kinf -o data/${chr}_emmax
# rm data/${chr}_impute2.tfam
# rm data/${chr}_impute2.tped

date
