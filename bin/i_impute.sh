#!/usr/bin/env bash

set -o errexit
set -o nounset
#set -o xtrace

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
    bin/dataShapeit.sh $chr
    for start in `seq 0 5000000 245000000`
    do
      bin/dataImpute.sh $chr $start
    done
    bin/dataPostImpute.sh $chr
  done
  cleanupImpute
  reportImpute
}
