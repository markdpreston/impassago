#!/bin/bash

dir=$1
chr=$2
threads=$3

cd $dir

#cat data/${chr}_impute2_[012]??000000 > data/${chr}.gen

#echo "snp_id rs_id position a0 a1 exp_freq_a1 info certainty type info_type0 concord_type0 r2_type0" > data/$chr.info
#grep -v certainty data/${chr}_impute2_*_info >> data/$chr.info;
#cut -f2,3,7 data/$chr.info -d' ' | sed 's/ /\t/g' | awk -F "\t" '{ if ($3 >= 0.3) { print $1; } }' > data/${chr}_filter.keepSnps

#bin/plink --data data/${chr} --oxford-single-chr ${chr} --extract data/${chr}_filter.keepSnps --make-bed --out data/${chr}_filter --hard-call-threshold 0.05

###bin/plink -bfile data/${chr}_filter --keep input/samples.keep --hwe 5e-8 --maf 0.01 --geno 0.5 --recode 12 transpose --output-missing-genotype 0 --freq --out data/${chr}_final
bin/plink -bfile data/${chr}_filter --hwe 5e-8 --maf 0.01 --geno 0.5 --recode 12 transpose --output-missing-genotype 0 --freq --out data/${chr}_final
sed -i 's/ \+/\t/g' data/${chr}_final.frq
cut -f1-4 -d' ' data/${chr}_final.tped > data/${chr}_final.tbim

bin/data.info.r $dir $chr

#pigz -p $threads data/${chr}.gen

#
#  NOTES:
#

#bin/plink --data data/${chr} --oxford-single-chr ${chr} ke-bed --out data/${chr}_impute2 --hard-call-threshold 0.05
#pigz -p $threads data/${chr}.gen
#mv data/${chr}_impute2.log data/${chr}_impute2.bedify.log

#bin/plink -bfile data/${chr}_impute2 --keep phenotypes/samples.keep --hwe 5e-8 --maf 0.01 --recode 12 transpose --output-missing-genotype 0 --freq --out data/${chr}_final
#sed -i 's/ \+/\t/g' data/${chr}_impute2.frq
#pigz -p $threads data/${chr}_impute2.tped

### tmp line \/ \/ \/
###bin/plink --gen data/${chr}.gen.gz --sample data/${chr}.sample --oxford-single-chr ${chr} --make-bed --out data/${chr}_impute2 --hard-call-threshold 0.05

