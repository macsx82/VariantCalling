#!/usr/bin/env bash
set -euo pipefail

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

#12
echo
# cd ${fol6}/
echo "> Check gVCF"
while read -r f1
do
    ${GATK4} --java-options ${java_opt1x} ValidateVariants -V ${fol6}/${gVCF} -R ${GNMhg38} -L "${f1}" -gvcf -Xtype ALLELES

done < ${sorgILhg38ChrCHECK}
echo "- END -"

touch step12.done



