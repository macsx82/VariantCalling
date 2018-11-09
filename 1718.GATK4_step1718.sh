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

#17
echo
# cd ${fol9}/${variantdb}/
echo "> Hard Filtering pre-VQSR"
${GATK4} --java-options ${java_opt2x} VariantFiltration --filter-expression 'ExcessHet > 54.69' --filter-name 'ExcessHet' -V ${fol9}/${variantdb}/${raw} -O ${fol8}/${variantdb}/${HF}
echo "- END -"

#18
echo
# cd ${fol8}/${variantdb}/
echo "> Site Only pre-VQSR"
${GATK4} --java-options ${java_opt2x} MakeSitesOnlyVcf -I ${fol9}/${variantdb}/${HF} -O ${fol8}/${variantdb}/${SO}
echo "- END -"

#del
echo
# rm -v ${fol8}/${variantdb}/${variantdb}_rawHF.vcf*

touch step1718.done



