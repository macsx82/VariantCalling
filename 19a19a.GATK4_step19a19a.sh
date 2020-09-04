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
echo "> Merge cromosome files"
case ${pool_mode} in
    CHROM)
	#19a
	#First collect all vcf files without genotypes and merge them
	#I need generate the list of files to merge together
	for current_chr in ${chr_pool[@]}
	do
		#we need to collect ALL chromosomes to merge them. we are not working by chr at this point
		int_vcf="${fol8}/${SO}_${current_chr}.vcf.gz"
		find ${int_vcf} -type f 
	done > ${fol8}/${variantdb}_all_chr_vcf.list
	
	echo -e "\n> Merge sites only VCFs"
	# concat , sort and normalize indels 
	${BCFTOOLS} concat -a -f ${fol8}/${variantdb}_all_chr_vcf.list | ${BCFTOOLS} sort -T ${tmp} | ${BCFTOOLS} norm -f ${GNMhg38} -O z -o ${fol8}/${SO}.vcf.gz
	;;
esac

#19
echo
echo "- END -"

touch step19a.done

# -an "DP" # excluded from WES



