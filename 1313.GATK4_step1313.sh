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
#13
echo
# cd ${fol6}/
#Now We need to get all the gVCF produced in the same folder to add them to GenomicDB import step or to use them with Combine GVCF
#we need to behave differently based on the fact that we work by chromosome or by sample
case ${pool_mode} in
	CHROM)
		#now we have access to the chr_pool variable, we can use it to iterate and get files from each chr in the right place
		for chr in ${chr_pool[@]}
		do
			#in this case whe already have all the info we need for each chr, son we don't need to take in account missing data for females
			current_variant_db=${variantdb}_${chr}
			echo "> cohort gVCF ID list for chr ${chr}"
			find -L ${fol6_link}/${chr}/*_g.vcf.gz -type f -printf "%f\n" | awk -v base_folder="${fol6_link}/${chr}" '{OFS="\t"}{split($1,n,"_");print n[1],base_folder"/"$1}' > ${fol7}/${current_variant_db}/gVCF.list
			echo -n "gVCF files count= "; ls -lh ${fol6_link}/${chr}/*gz | wc -l; wc -l ${fol7}/${current_variant_db}/gVCF.list
			echo "- END -"
		done
	;;
	SAMPLE)
		mkdir -p ${fol7}/${variantdb}
		mkdir -p ${fol8}/${variantdb}
		mkdir -p ${fol9}/${variantdb}
		mkdir -p ${fol9}/${variantdb}/xSamplePassedVariantsVCFs
		
		echo "> cohort gVCF ID list"
		find -L ${fol6_link}/*_g.vcf.gz -type f -printf "%f\n" | sed 's/_g.vcf.gz//g' | awk -v base_folder=${fol6_link} '{print $1"\t"base_folder"/"$1"_g.vcf.gz"}' > ${fol7}/${variantdb}/gVCF.list
		echo -n "gVCF files count= "; ls -lh ${fol6_link}/*gz | wc -l; wc -l ${fol7}/${variantdb}/gVCF.list
		echo "- END -"
	;;
esac
touch step13.done



