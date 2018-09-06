#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - VARIABILI FISSE - ###
variantdb=$1				#db name
raw="${variantdb}_raw.vcf"
final="${variantdb}_VQSR_output.vcf"
passed="${variantdb}_CohortOnlyPASS_Variants_PostVQSR.vcf"
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

#22a
echo
cd ${fol9}/${variantdb}/
echo "> Sample list"
grep "CHROM" ${raw} | sed 's/\t/\n/g' | tail -n +10 > ${fol8}/${variantdb}/"${variantdb}_sample.list"
echo "- END -"

#22b
echo
cd ${fol9}/${variantdb}/
echo "> PASS variants list"
grep -w "PASS" ${final} | tail -n +2 | awk '{print $1":"$2}' > ${fol8}/${variantdb}/"${variantdb}_pass.list"
echo "- END -"

#22c
echo
cd ${fol8}/${variantdb}/
echo "> Count Samples and Variants"
echo -n "samples n. = "; wc -l "${variantdb}_sample.list" | awk '{print $1}'
echo -n "PASS variants n. in "pass list"   = "; wc -l "${variantdb}_pass.list" | awk '{print $1}'
echo -n "PASS variants n. in "VQSR output" = "; grep "PASS" ${fol9}/${variantdb}/"${variantdb}_VQSR_output.vcf" | tail -n +2 | wc -l 
echo "- END -"

#23
echo
cd ${fol9}/${variantdb}/
echo "> Extract from the raw cohort vcf only the PASS variants by the VQSR steps"
${GATK4} --java-options ${java_opt2x} SelectVariants -R ${GNMhg38} -V ${raw} -O ${passed} -L ${fol8}/${variantdb}/"${variantdb}_pass.list"
echo "- END -"

#24
echo
cd ${fol9}/${variantdb}/
echo "> Create per sample only the PASS variants vcf"
while read -r SM ; do ${GATK4} --java-options ${java_opt2x} SelectVariants -R ${GNMhg38} -V ${passed} -O xSamplePassedVariantsVCFs/"${variantdb}_${SM}_SampleOnlyPASS_Variants_PostVQSR.vcf" --exclude-non-variants -sn ${SM}; done < ${fol8}/${variantdb}/"${variantdb}_sample.list"
echo "- END -"

#del
echo
rm -v ${fol8}/${variantdb}/"${variantdb}_sample.list"
rm -v ${fol8}/${variantdb}/"${variantdb}_pass.list"
rm -v -r ${fol8}/${variantdb}

exit



