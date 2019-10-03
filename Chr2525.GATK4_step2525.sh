#!/usr/bin/env bash

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

#25a
echo
# cd ${fol9}/${variantdb}/
echo "> Sample list"
grep "CHROM" ${fol9}/${variantdb}/${raw} | sed 's/\t/\n/g' | tail -n +10 > "${fol9}/${variantdb}/${variantdb}_g2525_sample.list"
echo "- END -"

#25b
echo
# cd ${fol9}/${variantdb}/
echo "> Extract from the SampleOnlyPASS_Variants_PostVQSR.vcf only them present in the Interval List"
while read -r SID
do
    ${GATK4} --java-options ${java_opt2x} SelectVariants -R ${GNMhg38} -V ${fol9}/${variantdb}/xSamplePassedVariantsVCFs/"${variantdb}_${SID}_SampleOnlyPASS_Variants_PostVQSR.vcf" -O ${fol9}/${variantdb}/xSamplePassedVariantsIntervalFilteredVCFs_WholeGenes/"${variantdb}_${SID}_SampleOnlyPASSandIntervalFiltered_Variants_PostVQSR.vcf" -L ${filter_interval} -sn ${SID}

done < ${fol9}/${variantdb}/${variantdb}_g2525_sample.list
echo "- END -"

#25c
echo
# cd ${fol9}/${variantdb}/
echo "> Count Samples and Variants"
echo -n "samples n. = "; wc -l ${fol9}/${variantdb}/${variantdb}_g2525_sample.list | awk '{print $1}'
echo -n "intervals n. = "; wc -l ${fol9}/${variantdb}/${filter_interval} | awk '{print $1}'
echo
while read -r SID
do
    echo -n "quite number of variants (including header) in ${SID} PRE-filtered VCF = ";
    wc -l ${fol9}/${variantdb}/xSamplePassedVariantsVCFs/${variantdb}_${SID}_SampleOnlyPASS_Variants_PostVQSR.vcf | awk '{print $1}';
    echo -n "quite number of variants (including header) in ${SID} POST-filtered VCF = ";
    wc -l ${fol9}/${variantdb}/xSamplePassedVariantsIntervalFilteredVCFs_WholeGenes/"${variantdb}_${SID}_SampleOnlyPASSandIntervalFiltered_Variants_PostVQSR.vcf" | awk '{print $1}'
    echo
done < ${fol9}/${variantdb}/${variantdb}_g2525_sample.list

echo "- END -"

#del
echo
# rm -v ${fol9}/${variantdb}/"${variantdb}_g2525_sample.list"

touch step25.done
