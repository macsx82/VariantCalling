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

#21a
echo
echo "> indel Apply VQSR"
${GATK4} --java-options "${java_opt1x} -XX:+UseSerialGC" ApplyVQSR -O ${fol8}/${inout} -V ${fol8}/${HF} --recal-file ${fol8}/${iVR} --tranches-file ${fol8}/${tri} --truth-sensitivity-filter-level ${vqsr_thr_i} --create-output-variant-index true -mode ${mode_I}
echo "- END -"

#21b
echo
echo "> snp Apply VQSR"
${GATK4} --java-options "${java_opt1x} -XX:+UseSerialGC" ApplyVQSR -O ${fol9}/${variantdb}/${final} -V ${fol8}/${inout} --recal-file ${fol8}/${sVR} --tranches-file ${fol8}/${trs} --truth-sensitivity-filter-level ${vqsr_thr_s} --create-output-variant-index true -mode ${mode_S}
echo "- END -"

#del
# echo
# rm -v ${fol8}/${variantdb}/${variantdb}_rawHFSO.vcf*
# rm -v ${fol8}/${variantdb}/${variantdb}_rawHFSO-iVR.vcf*
# rm -v ${fol8}/${variantdb}/${variantdb}_rawHFSO-sVR.vcf*
# rm -v ${fol8}/${variantdb}/${variantdb}_*.tranches
# rm -v ${fol8}/${variantdb}/${variantdb}_tmp.indel.recalibrated.vcf*

touch step21.done



