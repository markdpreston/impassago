#!/usr/bin/perl
use strict;
use warnings;

die("Usage: $0 plinkin plinkout shapeit\n") if ($#ARGV != 2);
my ($psFile1, $psFile2, $psTemp) = @ARGV[0..2];

`mkdir -p $psTemp`;
`rm -f $psTemp/*`;

my @laMissing = ();
for (my $i = 1; $i <= 25; $i++) { # Missing 26 - mitochondrial
  print "Chr: $i\n";
  #  Use plink to separate a chromosome
  `../bin/plink --noweb --bfile $psFile1 --chr $i --make-bed --out $psTemp/$i`;
  #  Check against reference.
  my $lsCommand = "../bin/shapeit2 -check --input-bed $psTemp/$i" .
                  " --input-map ../1000G/1000GP_Phase3/genetic_map_chr${i}_combined_b37.txt" .
                  " --input-ref ../1000G/1000GP_Phase3/1000GP_Phase3_chr$i.hap.gz ../1000G/1000GP_Phase3/1000GP_Phase3_chr${i}.legend.gz ../1000G/1000GP_Phase3/1000GP_Phase3.sample" .
                  " --output-log $psTemp/$i.check.log --thread 20";
  `$lsCommand`;
  if (-e "$psTemp/$i.check.snp.strand") {
    open H, "$psTemp/$i.check.snp.strand" or die("$i\n");
    <H>;
    while (<H>) {
      my @laLine = split;
      push @laMissing, "$i:$laLine[2]\t$laLine[3]";
    }
    close H;
  }
}
open H, ">snps.$psTemp" or die("$psTemp\n");
print H join("\n",@laMissing) . "\n";
close H;

`../bin/plink --noweb --bfile $psFile1 --exclude snps.$psTemp --make-bed --out $psFile2`;
