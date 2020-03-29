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
source ${hs}/pipeline_functions.sh
### - CODE - ###

#17
echo
echo "> Hard Filtering pre-VQSR"
${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" VariantFiltration --filter-expression 'ExcessHet > 54.69' --filter-name 'ExcessHet' -V ${fol9}/${variantdb}/${raw}.gz -O ${fol8}/${HF}
echo "- END -"

#18
echo
echo "> Site Only pre-VQSR"
# ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" MakeSitesOnlyVcf -I ${fol8}/${HF} -O ${fol8}/${SO}
#this should be done with picard!
java ${java_opt2x} -XX:+UseSerialGC -jar ${PICARD} MakeSitesOnlyVcf -I ${fol8}/${HF} -O ${fol8}/${SO}
echo "- END -"

#del
echo
# rm -v ${fol8}/${variantdb}/${variantdb}_rawHF.vcf*

touch step1718.done



