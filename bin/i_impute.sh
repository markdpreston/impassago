#!/usr/bin/env bash

set -o errexit
set -o nounset
#set -o xtrace

shapeit() {
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
}

imputeSection() {
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
}

postImpute() {
  chr=$1
  #  Create a .GEN file from the individual imputations.
  cat data/$chr.impute2.[012]??000000 > data/$chr.gen
  #  Get the imputed SNP info and make list of those with >= 0.3 INFO.
  echo "snp_id rs_id position a0 a1 exp_freq_a1 info certainty type info_type0 concord_type0 r2_type0" > data/$chr.info
  grep -v certainty data/$chr.impute2_*_info >> data/$chr.info
  cut -f2,3,7 data/$chr.info -d' ' | sed 's/ /\t/g' | awk -F "\t" '{ if ($3 >= 0.3) { print $1; } }' > data/$chr.filter.keepSnps
  #  Filter the data on the INFO >= 0.3 and a hard-call threshold of 0.05.
  bin/plink --data data/$chr --oxford-single-chr $chr --extract data/$chr.filter.keepSnps --make-bed --out data/${chr}.filter --hard-call-threshold 0.05
  #  Filter the data on an HWE of 5e-8, MAF of 0.01 and reformat into TPED formaet (for EMMAX).
  bin/plink -bfile data/$chr.filter --hwe 5e-8 --maf 0.01 --geno 0.5 --recode 12 transpose --output-missing-genotype 0 --freq --out data/$chr.final
  sed -i 's/ \+/\t/g' data/$chr.final.frq
  cut -f1-4 -d' ' data/$chr.final.tped > data/$chr.final.tbim
  #  Make the SNPINFO file.
  bin/data.info.r $chr
}

cleanupImpute() {
  mkdir -p data/imputeParts/
  #  Zip and move away intermediary files.
  pigz -v -p $threads data/*000000
  mv data/*0000.gz data/imputeParts/
  pigz -p $threads data/*.gen
  mv data/*.gen.gz data/imputeParts/
  pigz -p $threads data/*.haps
  mv data/*.haps.gz data/imputeParts/
  pigz -p $threads data/*.info
  mv data/*.info.gz data/imputeParts/
  pigz -p $threads data/*.filter.bed
  mv data/*.filter.bed.gz data/imputeParts/
  #  Combine the small files into one tar.gz and delete.
  tar zcvf data/imputeParts/bits.tar.gz data/*_info data/*_info_by_sample data/*_samples data/*_summary data/*_summary data/*_warnings
  rm -f data/*_info
  rm -f data/*_info_by_sample
  rm -f data/*_samples
  rm -f data/*_summary
#  rm -f data/*_warnings  #  keep warnings!
}

reportImpute() {
  echo "Report"
}

impute() {
  checkImpute "EXIT"
  for chr in {1..23}
  do
 echo $chr
    extractChromosome $chr
    shapeit $chr
    for start in `seq 0 5000000 245000000`
    do
      imputeSection $chr $start
    done
    postImpute $chr
  done
  cleanupImpute
  reportImpute
}
