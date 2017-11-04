#!/bin/bash

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
bin/dataInfo.r $chr

