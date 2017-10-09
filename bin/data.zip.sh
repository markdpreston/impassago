#!/bin/bash

dir=$1
chr=$2

cd $dir
#mkdir -p data/imputeParts/
#pigz -v -p16 data/${chr}_*0000
#mv data/${chr}_*0000.gz data/imputeParts/
#tar zcvf data/imputeParts/${chr}_bits.tar.gz data/${chr}_*_info data/${chr}_*_info_by_sample data/${chr}_*_summary data/${chr}_*_summary data/${chr}_*_warnings

#pigz -v -p32 data/${chr}.gen
#mv data/${chr}.gen.gz data/imputeParts/
#pigz -v -p32 data/${chr}.haps
#mv data/${chr}.haps.gz data/imputeParts/
pigz -v -p32 data/${chr}.info
mv data/${chr}.info.gz data/imputeParts/
pigz -v -p32 data/${chr}_filter.bed
mv data/${chr}_filter.bed.gz data/imputeParts/


#
#
#rm -f data/${chr}_*0000 data/${chr}_*_info data/${chr}_*_info_by_sample data/${chr}_*_summary data/${chr}_*_summary data/${chr}_*_warnings

