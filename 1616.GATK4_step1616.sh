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

#16a
# cd ${fol8}/${variantdb}/
echo -e "\n> Raw VCFs ID data"
# wVCF=`find ${fol8}/${variantdb}/${variantdb}_*.vcf.gz -type f | awk '{print " I="$1}' | tr "\n" "\t" | sed 's/\t / /g'`
# find ${fol8}/${variantdb}/${variantdb}_*.vcf.gz -type f > ${fol8}/${variantdb}/${variantdb}_all_vcf.list
# We need to proceed by steps, splitting we need to and sorting data by chunks of 1000 files each maximum (bcftools limit)
find ${fol8}/${variantdb}/${variantdb}_*.vcf.gz -type f | split -a 4 --additional-suffix _all_vcf.list -d -l 1000 - ${fol8}/${variantdb}/${variantdb}_  
echo "- END -"

#16b
# cd ${fol8}/${variantdb}/
echo -e "\n> Merge VCFs"
# ${BCFTOOLS} concat -a -f ${fol8}/${variantdb}/${variantdb}_all_vcf.list | ${BCFTOOLS} sort -T ${tmp} -O z -o ${fol9}/${variantdb}/${raw}
for par_file in ${fol8}/${variantdb}/${variantdb}_*_all_vcf.list
do
	par_file_name=`basename ${par_file}`
	${BCFTOOLS} concat -a -f ${par_file} | ${BCFTOOLS} sort -T ${tmp} -O z -o ${fol9}/${variantdb}/${par_file_name}.vcf.gz
	tabix -f -p vcf ${fol9}/${variantdb}/${par_file_name}.vcf.gz
done

pVCF=$(find ${fol9}/${variantdb}/${variantdb}_*_all_vcf.list.vcf.gz -type f)

${BCFTOOLS} concat -a ${pVCF} | ${BCFTOOLS} sort -T ${tmp} -O z -o ${fol9}/${variantdb}/${raw}.gz
tabix -f -p vcf ${fol9}/${variantdb}/${raw}.gz

#add reference tag in vcf
##reference=file:///nfs/users/GD/resource/human/hg19/hg19.fasta

echo -e "\n> Validate VCF"
vcf-validator -d ${fol9}/${variantdb}/${raw}.gz > ${fol9}/${variantdb}/${raw}.validate

echo -e "\n> Produce VCF stats"

vcf_stats ${fol9}/${variantdb}/${raw}.gz ${fol9}/${variantdb}/${raw}.vchk

echo "- END -"

#del
echo
# rm -v ${fol8}/${variantdb}/${variantdb}_*.vcf*

touch step16.done



