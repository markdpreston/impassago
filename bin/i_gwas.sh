#!/usr/bin/env bash

set -o errexit
set -o nounset
#set -o xtrace

reportGwas() {
  echo "Report"
}

impute() {
  count=${1:1000}
  checkGwas "EXIT"
  phenotypes=`head -n1 input/data.phenotypes.tsv | cut -f7-`
  for p in $phenotypes
  do
    bin/phenotypesMake.r $p $count
    for chr in {1..23}
    do
      for i in {0..$count}
      do
        bin/phenotypesEmmax.sh $p $chr $i
      done
    done
  done
  reportGwas
}
