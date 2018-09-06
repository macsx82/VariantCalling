#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - VARIABILI FISSE - ###
variantdb=$1				#db name
raw="${variantdb}_raw.vcf"
HF="${variantdb}_rawHF.vcf"
SO="${variantdb}_rawHFSO.vcf"
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

#17
echo
cd ${fol9}/${variantdb}/
echo "> Hard Filtering pre-VQSR"
${GATK4} --java-options ${java_opt2x} VariantFiltration --filter-expression 'ExcessHet > 54.69' --filter-name 'ExcessHet' -V ${raw} -O ${fol8}/${variantdb}/${HF}
echo "- END -"

#18
echo
cd ${fol8}/${variantdb}/
echo "> Site Only pre-VQSR"
${GATK4} --java-options ${java_opt2x} MakeSitesOnlyVcf -I ${HF} -O ${SO}
echo "- END -"

#del
echo
rm -v ${fol8}/${variantdb}/${variantdb}_rawHF.vcf*

exit



