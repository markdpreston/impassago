#!/bin/bash

#cd input

#######grep -f branwen.samples ids.change.csv | cut -f3,4 > ids.keep.csv

#rm -f process.?.*

rm -f a b c
cut -d' ' -f1,2 final_3129_with_relatedness.fam > a
cut -d' ' -f5,6 final_3129_with_relatedness.fam > b
l=`wc -l final_3129_with_relatedness.fam | cut -d' ' -f1`
echo $l
for i in $(seq 1 $l); do echo "0 0" >> c; done
paste -d' ' a c b > process.0.fam
rm -f a b c
ln -s final_3129_with_relatedness.bed process.0.bed
ln -s final_3129_with_relatedness.bim process.0.bim

../bin/filterChangeIds.r
../bin/plink --bfile process.0 --update-ids ids.removeFamilies.csv --make-bed --out process.1
../bin/plink --bfile process.1 --merge-x      --make-bed --out process.2
../bin/plink --bfile process.2 --split-x hg19 --make-bed --out process.3
../bin/filterDuplicates.pl process.3 process.4
../bin/filterData.pl process.4 process.5 process.6 > log
../bin/filterShapeit.pl process.6 process.7 shapeit
../bin/plink --bfile process.7 --hwe 5e-8 --make-bed --out process.8

#  Re-add families
../bin/plink --bfile process.8 --update-ids ids.restoreFamilies.csv --make-bed --out process.9

#  Correct genders:
for i in `ls process.9.*`
do
   j=`echo $i | sed 's/9/10/'`
   cp $i $j
done
../bin/replaceGender.r
cp a process.10.fam
cp a process.10.tfam
rm -f a

#  Process phenotypes
../bin/filter.phenotypes.r

#  Kinship...
../bin/plink --bfile process.10 --recode 12 transpose --out process.10
../bin/emmax-kin -v -s -d 10 process.10
../bin/emmax-kin -v -d 10 process.10

../bin/plink --bfile process.10 --keep samples.keep --recode 12 transpose --out process.11
../bin/emmax-kin -v -s -d 10 process.11
../bin/emmax-kin -v -d 10 process.11
