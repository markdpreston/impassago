#!/usr/bin/perl
use strict;
use warnings;

die("Usage: $0 plinkin plinkremove plinkflip\n") if ($#ARGV != 2);
my ($psFile1, $psFile2, $psFile3) = @ARGV[0..2];

my %lhRevComp;
$lhRevComp{'A'} = "T";
$lhRevComp{'C'} = "G";
$lhRevComp{'G'} = "C";
$lhRevComp{'T'} = "A";

my %lhAll;
my %lhExm;
my %lhRemove;
my %lhFlip;
my %lhFound;

open H, "$psFile1.bim" or die("Error opening bim file\n");
while (<H>) {
  chomp;
  my @laLine = split '\t';
  my $lsSNP = "$laLine[0]:$laLine[3]";
  if (exists($lhAll{$lsSNP}) || $laLine[4] eq "D" || $laLine[4] eq "I" || $laLine[0] eq "26") {
#print "ID: $laLine[0] $laLine[1] $laLine[2]\n";
    $lhRemove{$lsSNP} = $laLine[1];
  }
  $lhAll{$lsSNP} = "$laLine[4]:$laLine[5]";
  $lhExm{$lsSNP} = "$laLine[1]";
}
close H;
foreach my $lsRemove (keys(%lhRemove)) {
  delete $lhAll{$lsRemove};
}

for (my $i = 1; $i <= 25; $i++) {  # No 26 - mitochondrial!
  print "Chr: $i\n";
##  open H, "gunzip -c ../1000G/1000GP_Phase3/1000GP_Phase3_chr${i}.legend.gz |" or die("Error opening $i legend file\n");
  open H, "../1000G/1000GP_Phase3/1000GP_Phase3_chr${i}.legend" or die("Error opening $i legend file\n");
  <H>;
  while (<H>) {
    chomp;
    my @laLine = split "[\ :]";
    my $lsSNP = "$i:$laLine[1]";
    if (exists($lhAll{$lsSNP})) {
      if (length($laLine[2]) > 1 || length($laLine[3]) > 1) {
#print "Indel: $lsSNP : $lhAll{$lsSNP} : $laLine[2]:$laLine[3]\n";
        $lhRemove{$lsSNP} = $lhExm{$lsSNP};
      } elsif ("$laLine[2]:$laLine[3]" ne $lhAll{$lsSNP} && "$laLine[3]:$laLine[2]" ne $lhAll{$lsSNP} && "$lhRevComp{$laLine[2]}:$lhRevComp{$laLine[3]}" ne $lhAll{$lsSNP} && "$lhRevComp{$laLine[3]}:$lhRevComp{$laLine[2]}" ne $lhAll{$lsSNP}) {
#print "Remove: $lsSNP : $lhAll{$lsSNP} : $laLine[2]:$laLine[3]\n";
        $lhRemove{$lsSNP} = $lhExm{$lsSNP};
      } elsif ("$lhRevComp{$laLine[2]}:$lhRevComp{$laLine[3]}" eq $lhAll{$lsSNP} || "$lhRevComp{$laLine[3]}:$lhRevComp{$laLine[2]}" eq $lhAll{$lsSNP}) {
#print "Flip: $lsSNP : $lhAll{$lsSNP} : $laLine[2]:$laLine[3]\n";
        $lhFlip{$lsSNP} = $lhExm{$lsSNP};
      } else {
#print "Found: $lsSNP\n";
        $lhFound{$lsSNP} = 1;
      }
    }
  }
  close H;
}

open H, ">snps.remove";
print H join("\n",values(%lhRemove)) . "\n";
close H;
open H, ">snps.flip";
print H join("\n",values(%lhFlip)) . "\n";
close H;

foreach my $lsRemove (keys(%lhRemove)) {
  delete $lhAll{$lsRemove};
}
open H, ">snps.all";
print H join("\n",sort(keys(%lhAll))) . "\n";
close H;

foreach my $lsFlip (keys(%lhFlip)) {
  delete $lhAll{$lsFlip};
}
foreach my $lsFound (keys(%lhFound)) {
  delete $lhAll{$lsFound};
}
open H, ">snps.missing";
print H join("\n",keys(%lhAll)) . "\n";
close H;

`../bin/plink --bfile $psFile1 --exclude snps.remove --chr 1-25 --make-bed --out $psFile2`;
`../bin/plink --bfile $psFile2 --flip snps.flip --make-bed --out $psFile3`;
