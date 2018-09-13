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

#16a
echo
# cd ${fol8}/${variantdb}/
echo "> Raw VCFs ID data"
wVCF=`find ${fol8}/${variantdb}/${variantdb}_*.vcf -type f -printf "%f\n" | awk '{print " I="$1}' | tr "\n" "\t" | sed 's/\t / /g'`
echo "- END -"

#16b
echo
# cd ${fol8}/${variantdb}/
echo "> Merge VCFs"
java -jar ${PICARD} GatherVcfs ${wVCF} O=${fol9}/${variantdb}/${raw}
echo "- END -"

#del
echo
rm -v ${fol8}/${variantdb}/${variantdb}_*.vcf*

touch step16.done



