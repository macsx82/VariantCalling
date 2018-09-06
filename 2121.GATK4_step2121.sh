#!/usr/bin/env bash

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
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

#21a
echo
cd ${fol8}/${variantdb}/
echo "> indel Apply VQSR"
${GATK4} --java-options ${java_opt1x} ApplyVQSR -O ${inout} -V ${SO} --recal-file ${iVR} --tranches-file ${tri} --truth-sensitivity-filter-level 99.7 --create-output-variant-index true -mode ${mode_I}
echo "- END -"

#21b
echo
cd ${fol8}/${variantdb}/
echo "> snp Apply VQSR"
${GATK4} --java-options ${java_opt1x} ApplyVQSR -O ${fol9}/${variantdb}/${final} -V ${inout} --recal-file ${sVR} --tranches-file ${trs} --truth-sensitivity-filter-level 99.7 --create-output-variant-index true -mode ${mode_S}
echo "- END -"

#del
echo
rm -v ${fol8}/${variantdb}/${variantdb}_rawHFSO.vcf*
rm -v ${fol8}/${variantdb}/${variantdb}_rawHFSO-iVR.vcf*
rm -v ${fol8}/${variantdb}/${variantdb}_rawHFSO-sVR.vcf*
rm -v ${fol8}/${variantdb}/${variantdb}_*.tranches
rm -v ${fol8}/${variantdb}/${variantdb}_tmp.indel.recalibrated.vcf*

exit



