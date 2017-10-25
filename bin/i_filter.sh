#!/usr/bin/env bash

set -o errexit
set -o nounset
#set -o xtrace

checkFile() {
  file=$1
  msg=$2
  if [ ! -e $file ]; then echo $msg; error=1; fi
}

checkFiles() {
  error=0
  checkFile("data.bim","PLINK input file: input/data.bim")
  checkFile("data.fam","PLINK input file: input/data.fam")
  checkFile("data.bed","PLINK input file: input/data.bed")
  checkFile("../bin/plink",    "Executable: bin/plink")
  checkFile("../bin/shapeit",  "Executable: bin/shapeit")
  checkFile("../bin/emmax-kin","Executable: bin/emmax-kin")
  checkFile("../bin/filterDuplicates.pl","Perl Script: bin/filterDuplicates.pl")
  checkFile("../bin/filterData.pl",      "Perl Script: bin/filterData.pl")
  checkFile("../bin/filterShapeit.pl",   "Perl Script: bin/filterShapeit.pl")
  checkFile("../bin/filterPhenotypes.r.","R Script: bin/filterPhenotypes.r")
  if [ $error -eq 1 ]; then echo "Exiting Prepare"; exit(1); fi
}

filterStep1() {
  #  Anonymise/remove family relations from the input data - familial relations determined by genotype.
  rm -f tmp.*
  count=`wc -l $data.fam | cut -d' ' -f1`
  echo $l
  cut -d' ' -f1,2 $data.fam > tmp.fam.id
  cut -d' ' -f2   $data.fam > tmp.id
  cut -d' ' -f5,6 $data.fam > tmp.sex.pheno
  for i in $(seq 1 $l); do echo $i >> tmp.fam; echo "0 0" >> tmp.pid.mid; done
  paste -d' ' tmp.fam tmp.id tmp.pid.mid tmp.sec.pheno > process.0.fam
  paste -d' ' tmp.fam tmp.id tmp.fam.id > ids.restoreFamilies.csv
  rm -f tmp.*
}

filterStep2() {
  #  Tidy up X-chromosome for PLINK - we use HG19/b37 to match the downloaded data
  ../bin/plink --bfile process.0 --merge-x      --make-bed --out process.1
  ../bin/plink --bfile process.1 --split-x hg19 --make-bed --out process.2
}

filterStep3() {
  #  Remove duplicates and update the BIM with RS names with data found in "snps.exm2rs"
  ../bin/filterDuplicates.pl process.2 process.3
  #  Phase, remove indels, remove mitochondria  ### future: merge with above?
  ../bin/filterData.pl process.3 process.4 process.5 > log
  #  Run SHAPEIT to filter the SNPs  ### future: merge with above?
  ../bin/filterShapeit.pl process.5 process.6 shapeit
  #  Filter out SNPs that have a Hardy-Weinberg exact test below 5e-8
  ../bin/plink --bfile process.6 --hwe 5e-8 --make-bed --out process.7
}

filterStep4() {
  #  Re-add families to the FAM file.
  ../bin/plink --bfile process.7 --update-ids ids.restoreFamilies.csv --make-bed --out process.8
  #  Process phenotypes
  ../bin/filterPhenotypes.r process.8
  ../bin/plink --bfile process.8 --keep samples.keep --recode 12 transpose --out process.9
}

filterStep5() {
  #  Determine genotypic kinship using EMMAX
  ../bin/emmax-kin -v -s -d 10 process.9 process.10
  ../bin/emmax-kin -v -d 10 process.9 process.10
}

reportFilter() {
}

#  ----------------------------------------------------------------------------
#
#
#
filter() {
  #  Prepare for filtering input including removing previously processed data
  data="data"
  cd input
  rm -f process.?.*
  rm -f tmp.*

  checkInputs()  # Check data bfiles
  filterStep1()  # FAM related files
  filterStep2()  # X chromosome
  filterStep3()  # Remove SNPs
  filterStep4()  # Remove/fix samples
  filterStep5()  # Kinship
  reportFilter() # Write filter report
}






