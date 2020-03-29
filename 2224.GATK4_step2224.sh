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

#22a
echo
# cd ${fol9}/${variantdb}/
echo "> Sample list"
${BCFTOOLS} view -h ${fol9}/${variantdb}/${final}| tail -n 1 |cut -f 10-| tr "\t" "\n" > ${fol9}/${variantdb}/"${variantdb}_sample.list"
echo "- END -"

#22b
# echo
# # cd ${fol9}/${variantdb}/
# echo "> PASS variants list"
# ${BCFTOOLS} view -H -i "FILTER=='PASS'" ${fol9}/${variantdb}/${final} | awk '{print $1":"$2}' > ${fol8}/"${variantdb}_pass.list"
# echo "- END -"

echo "> Calculate stats for all the called sites"
vcf_stats ${fol9}/${variantdb}/${final} ${fol9}/${variantdb}/${final}.vchk
echo "- END -"

#23
echo
# cd ${fol9}/${variantdb}/
echo "> Extract from the cohort vcf only the PASS variants by the VQSR steps"
# ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" SelectVariants -R ${GNMhg38} -V ${fol9}/${variantdb}/${raw} -O ${fol9}/${variantdb}/${passed} -L ${fol8}/${variantdb}/"${variantdb}_pass.list"
${BCFTOOLS} view -i "FILTER=='PASS'" ${fol9}/${variantdb}/${final} -O z -o ${fol9}/${variantdb}/${passed}
tabix -p vcf -f ${fol9}/${variantdb}/${passed}

echo "> Calculate stats for the VQSR passed sites"
vcf_stats ${fol9}/${variantdb}/${passed} ${fol9}/${variantdb}/${passed}
echo "- END -"

#24
echo e "\nAdd rsID annotations from dbSNP and some other useful fields"
${BCFTOOLS} annotate -a ${DBSNP_latest} -c ID ${fol9}/${variantdb}/${passed} | ${BCFTOOLS} +fill-tags -O z -o ${fol9}/${variantdb}/${rsID_added}
tabix -p vcf -f ${fol9}/${variantdb}/${rsID_added}
# cd ${fol9}/${variantdb}/
# echo "> Create per sample only the PASS variants vcf"
# while read -r SM 
# do
#     ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" SelectVariants -R ${GNMhg38} -V ${fol9}/${variantdb}/${passed} -O ${fol9}/${variantdb}/xSamplePassedVariantsVCFs/"${variantdb}_${SM}_SampleOnlyPASS_Variants_PostVQSR.vcf" --exclude-non-variants -sn ${SM}

# done < ${fol8}/${variantdb}/"${variantdb}_sample.list"
# echo "- END -"

#del
echo
# rm -v ${fol8}/${variantdb}/"${variantdb}_sample.list"
# rm -v ${fol8}/${variantdb}/"${variantdb}_pass.list"
# rm -v -r ${fol8}/${variantdb}

touch step2224.done



