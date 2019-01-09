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
source ${own_folder}/pipeline_functions.sh
### - CODE - ###

#22a
echo
# cd ${fol9}/${variantdb}/
echo "> Sample list"
grep "CHROM" ${fol9}/${variantdb}/${raw} | sed 's/\t/\n/g' | tail -n +10 > ${fol8}/${variantdb}/"${variantdb}_sample.list"
echo "- END -"

#22b
echo
# cd ${fol9}/${variantdb}/
echo "> PASS variants list"
grep -w "PASS" ${fol9}/${variantdb}/${final} | tail -n +2 | awk '{print $1":"$2}' > ${fol8}/${variantdb}/"${variantdb}_pass.list"
echo "- END -"

#22c
echo
# cd ${fol8}/${variantdb}/
echo "> Count Samples and Variants"
echo -n "samples n. = "; wc -l "${fol8}/${variantdb}/${variantdb}_sample.list" | awk '{print $1}'
echo -n "PASS variants n. in "pass list"   = "; wc -l "${fol8}/${variantdb}/${variantdb}_pass.list" | awk '{print $1}'
echo -n "PASS variants n. in "VQSR output" = "; grep "PASS" ${fol9}/${variantdb}/"${variantdb}_VQSR_output.vcf" | tail -n +2 | wc -l 
echo "- END -"

#23
echo
# cd ${fol9}/${variantdb}/
echo "> Extract from the raw cohort vcf only the PASS variants by the VQSR steps"
${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" SelectVariants -R ${GNMhg38} -V ${fol9}/${variantdb}/${raw} -O ${fol9}/${variantdb}/${passed} -L ${fol8}/${variantdb}/"${variantdb}_pass.list"
echo "- END -"

#24
echo
# cd ${fol9}/${variantdb}/
echo "> Create per sample only the PASS variants vcf"
while read -r SM 
do
    ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" SelectVariants -R ${GNMhg38} -V ${fol9}/${variantdb}/${passed} -O ${fol9}/${variantdb}/xSamplePassedVariantsVCFs/"${variantdb}_${SM}_SampleOnlyPASS_Variants_PostVQSR.vcf" --exclude-non-variants -sn ${SM}

done < ${fol8}/${variantdb}/"${variantdb}_sample.list"
echo "- END -"

#del
echo
# rm -v ${fol8}/${variantdb}/"${variantdb}_sample.list"
# rm -v ${fol8}/${variantdb}/"${variantdb}_pass.list"
# rm -v -r ${fol8}/${variantdb}

touch step2224.done



