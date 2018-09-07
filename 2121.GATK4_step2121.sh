#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - VARIABILI FISSE - ###
variantdb=$1				#db name
SO="${variantdb}_rawHFSO.vcf"		# -V
final="${variantdb}_VQSR_output.vcf"	# -O
iVR="${variantdb}_rawHFSO-iVR.vcf"
tri="${variantdb}_indel.tranches"
mode_I=INDEL
inout="${variantdb}_tmp.indel.recalibrated.vcf"
sVR="${variantdb}_rawHFSO-sVR.vcf"
trs="${variantdb}_snp.tranches"
mode_S=SNP

### - SOURCEs - ###
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - CODE - ###

#21a
echo
# cd ${fol8}/${variantdb}/
echo "> indel Apply VQSR"
${GATK4} --java-options ${java_opt1x} ApplyVQSR -O ${fol8}/${variantdb}/${inout} -V ${fol8}/${variantdb}/${SO} --recal-file ${fol8}/${variantdb}/{iVR} --tranches-file ${fol8}/${variantdb}/${tri} --truth-sensitivity-filter-level 99.7 --create-output-variant-index true -mode ${mode_I}
echo "- END -"

#21b
echo
# cd ${fol8}/${variantdb}/
echo "> snp Apply VQSR"
${GATK4} --java-options ${java_opt1x} ApplyVQSR -O ${fol9}/${variantdb}/${final} -V ${fol8}/${variantdb}/${inout} --recal-file ${fol8}/${variantdb}/${sVR} --tranches-file ${fol8}/${variantdb}/${trs} --truth-sensitivity-filter-level 99.7 --create-output-variant-index true -mode ${mode_S}
echo "- END -"

#del
echo
rm -v ${fol8}/${variantdb}/${variantdb}_rawHFSO.vcf*
rm -v ${fol8}/${variantdb}/${variantdb}_rawHFSO-iVR.vcf*
rm -v ${fol8}/${variantdb}/${variantdb}_rawHFSO-sVR.vcf*
rm -v ${fol8}/${variantdb}/${variantdb}_*.tranches
rm -v ${fol8}/${variantdb}/${variantdb}_tmp.indel.recalibrated.vcf*

touc step21.done



