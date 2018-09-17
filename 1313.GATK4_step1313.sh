#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - SOURCEs - ###
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - CODE - ###

#13
echo
# cd ${fol6}/
#Now We need to get all the gVCF produced in the same folder to add them to GenomicDB import step or to use them with Combine GVCF
echo "> cohort gVCF ID list"
find ${fol6}/*_g.vcf.gz -type f -printf "%f\n" | sed 's/_g.vcf.gz//g' | awk -v base_folder=${fol6} '{print $1"\t"base_folder"/"$1"_g.vcf.gz"}' > ${fol7}/${variantdb}/gVCF.list
echo -n "gVCF files count= "; ls -lh ${fol6}/*gz | wc -l; wc -l ${fol7}/${variantdb}/gVCF.list
echo "- END -"

touch step13.done



