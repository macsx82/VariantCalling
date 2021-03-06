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
#we need to re-create the tmp folder after this source, otherwise, the folder will not be generated
mkdir -p ${tmp}
### - CODE - ###


case ${pool_mode} in
    CHROM)
		#16a
		#Here we need to collect the data from each chromosome and put them all together
		echo -e "\n> Raw VCFs ID data in chromosome pool mode"
        current_all_vcf_list=$2
        current_chr=$3
        #I need generate the list of files to merge together
   #      for current_chr in ${chr_pool[@]}
   #      do
   #      	#we need to collect ALL chunks for all chromosomes to merge them we are not working by chr at this point
   #      	current_variant_db="${variantdb}_${current_chr}_*"
	  #       # current_variant_db=${variantdb}_${chr}
   #  	    int_vcf="${current_variant_db}.vcf.gz"
			# find ${fol8}/${current_variant_db}/${int_vcf} -type f 
   #      done > ${fol8}/${variantdb}_all_vcf.list

		# wVCF=`find ${fol8}/${variantdb}/${variantdb}_*.vcf.gz -type f | awk '{print " I="$1}' | tr "\n" "\t" | sed 's/\t / /g'`
		# find ${fol8}/${variantdb}/${variantdb}_*.vcf.gz -type f > ${fol8}/${variantdb}/${variantdb}_all_vcf.list
		# We need to proceed by steps, splitting we need to and sorting data by chunks of 1000 files each maximum (bcftools limit)
		#16b
		echo -e "\n> Merge VCFs, by chr"
		# concat , sort and normalize indels 
		# ${BCFTOOLS} concat -a -f ${fol8}/${variantdb}_all_vcf.list | ${BCFTOOLS} sort -T ${tmp} | bcftools norm -f ${GNMhg38} -O z -o ${fol9}/${variantdb}/${raw}.gz
		
		${BCFTOOLS} concat -a -f ${current_all_vcf_list} | ${BCFTOOLS} sort -T ${tmp} | ${BCFTOOLS} norm -f ${GNMhg38} -O z -o ${fol9}/${variantdb}/${raw}_${current_chr}.vcf.gz
		tabix -f -p vcf ${fol9}/${variantdb}/${raw}_${current_chr}.vcf.gz
		echo "- END -"
		echo -e "\n> Validate VCF"
		# vcf-validator -d ${fol9}/${variantdb}/${raw}_${current_chr}.vcf.gz > ${fol9}/${variantdb}/${raw}_${current_chr}.validate

		echo -e "\n> Produce VCF stats"
		vcf_stats ${fol9}/${variantdb}/${raw}_${current_chr}.vcf.gz ${fol9}/${variantdb}/${raw}_${current_chr}.vchk

    ;;
    SAMPLE)
		#16a
		# cd ${fol8}/${variantdb}/
		echo -e "\n> Raw VCFs ID data in sample pool mode"
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

		# concat , sort and normalize indels 
		${BCFTOOLS} concat -a ${pVCF} | ${BCFTOOLS} sort -T ${tmp} | bcftools norm -f ${GNMhg38} -O z -o ${fol9}/${variantdb}/${raw}.vcf.gz
		tabix -f -p vcf ${fol9}/${variantdb}/${raw}.vcf.gz

		#add reference tag in vcf
		##reference=file:///nfs/users/GD/resource/human/hg19/hg19.fasta
		echo -e "\n> Validate VCF"
		vcf-validator -d ${fol9}/${variantdb}/${raw}.vcf.gz > ${fol9}/${variantdb}/${raw}.validate

		echo -e "\n> Produce VCF stats"
		vcf_stats ${fol9}/${variantdb}/${raw}.vcf.gz ${fol9}/${variantdb}/${raw}.vchk

    ;;
esac



echo "- END -"
# rm -v ${fol8}/${variantdb}/${variantdb}_*.vcf*
touch step16.done



