#!/usr/bin/env bash

#
#  Requires wget, tar, gunzip, R
#
#  Calls 1000G.genes.r
#
#  To do: options for software only/check large download md5sums.
#
set -o errexit
set -o nounset
#set -o xtrace

#  ----------------------------------------------------------------------------
#
#  Make the basic project directory structure.
#
makeDirectories() {
  mkdir -p 1000G bin input log data/imputeParts phenotypes/emmax pathways/genedata pathways/permutations pathways/pvalues pathways/results
}

#  ----------------------------------------------------------------------------
#
#  Download hardcoded software versions.
#
#  plink
#  impute2
#  shapeit2
#  emmax
#  gengen
#
#
getSoftware() {
  cd bin

  wget https://www.cog-genomics.org/static/bin/plink161010/plink_linux_x86_64.zip
  unzip plink_linux_x86_64.zip
  rm -f LICENSE toy.ped toy.map

  #  Impute2
  wget https://mathgen.stats.ox.ac.uk/impute/impute_v2.3.2_x86_64_static.tgz
  tar zxvf impute_v2.3.2_x86_64_static.tgz
  mv impute_v2.3.2_x86_64_static/impute2 .
  rm -rf impute_v2.3.2_x86_64_static

  #  Shapeit2
  wget http://www.shapeit.fr/script/get.php?id=20 -O shapeit2.tar.gz
  tar zxvf shapeit2.tar.gz
  mv shapeit.v2.r727.linux.x64 shapeit2
  rm -rf example

  #  Emmax
  wget http://genetics.cs.ucla.edu/emmax/emmax-beta-07Mar2010.tar.gz
  tar zxvf emmax-beta-07Mar2010.tar.gz
  mv emmax-beta-07Mar2010/emmax emmax-beta-07Mar2010/emmax-kin .
  rm -rf emmax-beta-07Mar2010

  #  Gengen
  wget https://github.com/WGLab/GenGen/archive/v1.0.1.tar.gz
  tar zxvf v1.0.1.tar.gz
  ln -s GenGen-1.0.1/calculate_gsea.pl
  ln -s GenGen-1.0.1/scan_region.pl
  ln -s GenGen-1.0.1/combine_gsea.pl

  cd ..
}

#   ----------------------------------------------------------------------------
#
#  Download 1000 genomes data
#
#  Instructions at:
#    https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3.html
#
#  Prepare gene table from UCSC too.
#
get1000G() {
  cd 1000G

  #  Download phased 1000G data.
  wget https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3.tgz
  wget https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3_chrX.tgz
  tar zxvf 1000GP_Phase3.tgz
  tar zxvf 1000GP_Phase3_chrX.tgz

  #  Download gene annotation table.
  wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refFlat.txt.gz
  gunzip refFlat.txt.gz
  mv refFlat.txt b37hg19refFlat.tsv
  ../bin/1000G.genes.r     # check relative directories!

  cd ..
}
