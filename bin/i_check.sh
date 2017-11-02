#!/usr/bin/env bash

set -o errexit
#set -o nounset
#set -o xtrace

checkFile() {
  if [ ! -e $1 ]; then echo "- Missing $2"; error=1; fi
}

checkFilter() {
  error=0
  checkFile "input/data.bim" "PLINK input file: input/data.bim"
  checkFile "input/data.fam" "PLINK input file: input/data.fam"
  checkFile "input/data.bed" "PLINK input file: input/data.bed"
  checkFile "bin/plink"     "Executable: bin/plink"
  checkFile "bin/shapeit2"  "Executable: bin/shapeit2"
  checkFile "bin/emmax-kin" "Executable: bin/emmax-kin"
  checkFile "bin/filterDuplicates.pl" "Perl Script: bin/filterDuplicates.pl"
  checkFile "bin/filterData.pl"       "Perl Script: bin/filterData.pl"
  checkFile "bin/filterShapeit.pl"    "Perl Script: bin/filterShapeit.pl"
  checkFile "bin/filterPhenotypes.r" "R Script: bin/filterPhenotypes.r"
  if [ $error == 1 ] ; then echo "filter: check FAIL"; fi
  if [ $error == 1 ] && [ $1 == "EXIT" ] ; then exit 1; fi
}

checkImpute() {
  error=0
  checkFile "input/process.10.bim" "PLINK input file: input/process.10.bim"
  checkFile "input/process.10.fam" "PLINK input file: input/process.10.fam"
  checkFile "input/process.10.bed" "PLINK input file: input/process.10.bed"
  checkFile "bin/plink"     "Executable: bin/plink"
  checkFile "bin/shapeit2"  "Executable: bin/shapeit2"
  checkFile "bin/impute2"   "Executable: bin/impute2"
  checkFile "bin/data.info.r" "R Script: bin/data.info.r"
  if [ $error == 1 ] ; then echo "impute: check FAIL"; fi
  if [ $error == 1 ] && [ $1 == "EXIT" ] ; then exit 1; fi
}

checkAll() {
  checkFilter 0
  checkImpute 0
}
