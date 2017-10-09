#!/bin/bash

dir=`pwd`
dir="/home/mark/cluster/lshtm/branwen"
mkdir -p bin 1000G input log data phenotypes pathways

#   ----------------------------------------------------------------------------
cd bin
#wget https://www.cog-genomics.org/static/bin/plink161010/plink_linux_x86_64.zip
#unzip plink_linux_x86_64.zip
#rm -f LICENSE toy.ped toy.map
#  --
#wget http://genetics.cs.ucla.edu/emmax/emmax-beta-07Mar2010.tar.gz
#tar zxvf emmax-beta-07Mar2010.tar.gz
#mv emmax-beta-07Mar2010/emmax emmax-beta-07Mar2010/emmax-kin .
#rm -rf emmax-beta-07Mar2010
#  --
#wget http://www.shapeit.fr/script/get.php?id=20 -O shapeit2.tar.gz
#tar zxvf shapeit2.tar.gz
#mv shapeit.v2.r727.linux.x64 shapeit2
#rm -rf example
#  --
#wget https://mathgen.stats.ox.ac.uk/impute/impute_v2.3.2_x86_64_static.tgz
#tar zxvf impute_v2.3.2_x86_64_static.tgz
#mv impute_v2.3.2_x86_64_static/impute2 .
#rm -rf impute_v2.3.2_x86_64_static
#  --
#wget https://github.com/WGLab/GenGen/archive/v1.0.1.tar.gz
#tar zxvf v1.0.1.tar.gz
#ln -s GenGen-1.0.1/calculate_gsea.pl
#ln -s GenGen-1.0.1/scan_region.pl
#ln -s GenGen-1.0.1/combine_gsea.pl
cd ..

#   ----------------------------------------------------------------------------
cd 1000G
#### -- https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3.html
#wget https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3.tgz
#wget https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3_chrX.tgz
#wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/refFlat.txt.gz
#gunzip refFlat.txt.gz
#mv refFlat.txt b37hg19refFlat.tsv
#../bin/1000G.genes.r
cd ..

#   ----------------------------------------------------------------------------
cd input
#../bin/filter.sh
cd ..

#   ----------------------------------------------------------------------------
#for chr in {1..22}
#do
#  plink --bfile input/process.10 --chr $chr --make-bed --out data/${chr}
#  qsub -pe parallel $threads -cwd -S /bin/bash -o $dir/log/qsub.shapeit.$chr -e $dir/log/qsub.shapeit.$chr $dir/bin/data.shapeit2.sh $dir $chr $threads
#  threads=5
#  for j in `seq 0 5000000 245000000`
#  do
#    echo qsub -pe parallel $threads -cwd -S /bin/bash -o $dir/log/qsub.log.impute.$chr.$j -e $dir/log/qsub.err.impute.$chr.$j $dir/bin/data.impute.sh $dir $chr $j $threads
#  done
#  threads=32
#  echo qsub -pe parallel $threads -cwd -S /bin/bash -o $dir/log/qsub.log.tpedify.$chr.$j -e $dir/log/qsub.err.tpedify.$chr.$j $dir/bin/data.tpedify.sh $dir $chr $threads
#  echo qsub -pe parallel $threads -cwd -S /bin/bash -o $dir/log/qsub.log.zip.$chr.$j -e $dir/log/qsub.err.zip.$chr.$j $dir/bin/data.zip.sh $dir $chr
#done

cd data
#tar zcvf summaries.tar.gz *_summary
#tar zcvf infos.tar.gz *_info*
#rm *_samples
#rm *_warnings
#rm *_summary
#rm *_info*
cd ..

cd phenotypes
#../bin/phenotypes.make.r
#threads=4
#for p in `cat ../analysisPhenotypes | grep -v "#"`
#do
#p="HGB"
#  for chr in {1..23}
#  do
#   j="0000"
#   echo qsub -pe parallel $threads -cwd -S /bin/bash -o $dir/log/qsub.log.emmax.$p.$chr.$j -e $dir/log/qsub.err.emmax.$p.$chr.$j $dir/bin/phenotypesEmmax.sh $dir $p $chr $j
#   for j in {0001..1000}
#   for j in {1001..10000}
#    do
#      echo qsub -p "-1024" -pe parallel $threads -cwd -S /bin/bash -o $dir/log/qsub.log.emmax.$p.$chr.$j -e $dir/log/qsub.err.emmax.$p.$chr.$j $dir/bin/phenotypesEmmax.sh $dir $p $chr $j
#    done
#  done
#done
cd ..

cd pathways
#mkdir -p pvalues permutations results genedata
#cd genedata
#ln -s ../../bin/GenGen-1.0.1/lib/kegg.gmt
#ln -s ../../bin/GenGen-1.0.1/lib/human.gol4.gmt
#ln -s ../../bin/GenGen-1.0.1/lib/biocarta.gmt
#cd ..
#./pathway.genes.r
#for phenotype in `grep -v '#' ../phenotypes/analysisPhenotypes`
#do
phenotype="nRGB"
#  echo $phenotype
#  echo -e "Marker\tCHI2" > pvalues/$phenotype
#  zcat ../phenotypes/emmax/$phenotype/0000/*.ps.gz | cut -f-2 >> pvalues/$phenotype
#  for i in {01..10}
  for i in {001..100}
  do
#    echo $i
#    echo qsub -pe parallel 16 -cwd -o $dir/log/qsub.log.pathway.perms.$phenotype.$i -e $dir/log/qsub.err.pathway.perms.$phenotype.$i $dir/pathways/pathway.perms.r $phenotype $i
    echo $dir/pathways/pathway.perms.r $phenotype $i
#    echo "sed 's/ /,/g' permutations/$phenotype.$i.perm | sed 's/,/\t/' | sed '1 s/,V2.*//' > permutations/$phenotype.$i"
#    for g in kegg biocarta human.gol4
#    do
#      echo qsub -pe parallel 8 -cwd -S /bin/bash -o $dir/log/qsub.log.pathway.gsea.$phenotype.$g.$i -e $dir/log/qsub.err.pathway.gsea.$phenotype.$g.$i $dir/pathway/pathway.gsea.sh $dir/pathway $phenotype $g $i
#    done
  done
#  combine_gsea.pl results/$phenotype.kegg.???.log > results/$phenotype
#done
cd ..
