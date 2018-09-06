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

#25a
echo
cd ${fol9}/${variantdb}/
echo "> Sample list"
grep "CHROM" ${raw} | sed 's/\t/\n/g' | tail -n +10 > "${variantdb}_g2525_sample.list"
echo "- END -"

#25b
echo
cd ${fol9}/${variantdb}/
echo "> Extract from the SampleOnlyPASS_Variants_PostVQSR.vcf only them present in the Interval List"
while read -r SM ; do ${GATK4} --java-options ${java_opt2x} SelectVariants -R ${GNMhg38} -V xSamplePassedVariantsVCFs/"${variantdb}_${SM}_SampleOnlyPASS_Variants_PostVQSR.vcf" -O xSamplePassedVariantsIntervalFilteredVCFs_WholeGenes/"${variantdb}_${SM}_SampleOnlyPASSandIntervalFiltered_Variants_PostVQSR.vcf" -L ${sorgILhg38wgenesINTERVALS} -sn ${SM}; done < "${variantdb}_g2525_sample.list"
echo "- END -"

#25c
echo
cd ${fol9}/${variantdb}/
echo "> Count Samples and Variants"
echo -n "samples n. = "; wc -l "${variantdb}_g2525_sample.list" | awk '{print $1}'
echo -n "intervals n. = "; wc -l ${sorgILhg38wgenesINTERVALS} | awk '{print $1}'
echo
while read -r SM ; do echo -n "quite number of variants (including header) in ${SM} PRE-filtered VCF = "; wc -l xSamplePassedVariantsVCFs/"${variantdb}_${SM}_SampleOnlyPASS_Variants_PostVQSR.vcf" | awk '{print $1}'; echo -n "quite number of variants (including header) in ${SM} POST-filtered VCF = "; wc -l xSamplePassedVariantsIntervalFilteredVCFs_WholeGenes/"${variantdb}_${SM}_SampleOnlyPASSandIntervalFiltered_Variants_PostVQSR.vcf" | awk '{print $1}'; echo; done < "${variantdb}_g2525_sample.list"
echo "- END -"

#del
echo
rm -v ${fol9}/${variantdb}/"${variantdb}_g2525_sample.list"

exit



