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

#17
case ${pool_mode} in
    CHROM)
		#16a
		#Here we need to collect the data from each chromosome and put them all together
        current_chr=$2
		echo
		echo "> Hard Filtering pre-VQSR in chromosome pool mode"
		# ${GATK4} --java-options "${java_opt2x}" VariantFiltration --filter-expression 'ExcessHet > 54.69' --filter-name 'ExcessHet' -V ${fol9}/${variantdb}/${raw}.gz -O ${fol8}/${HF}
		${BCFTOOLS} filter -s ExcessHet -e "ExcessHet > 54.69" ${fol9}/${variantdb}/${raw}_${current_chr}.vcf.gz -O z -o ${fol8}/${HF}_${current_chr}.vcf.gz
		echo "- END -"

		#18
		echo
		echo "> Site Only pre-VQSR"
		# ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" MakeSitesOnlyVcf -I ${fol8}/${HF} -O ${fol8}/${SO}
		#this should be done with picard!
		# java ${java_opt2x} -XX:+UseSerialGC -jar ${PICARD} MakeSitesOnlyVcf -I ${fol8}/${HF} -O ${fol8}/${SO}
		${BCFTOOLS} view -G ${fol8}/${HF}_${current_chr}.vcf.gz -O z -o ${fol8}/${SO}_${current_chr}.vcf.gz
		${BCFTOOLS} index -t ${fol8}/${SO}_${current_chr}.vcf.gz
	;;
	SAMPLE)
		echo
		echo "> Hard Filtering pre-VQSR in sample pool mode"
		# ${GATK4} --java-options "${java_opt2x}" VariantFiltration --filter-expression 'ExcessHet > 54.69' --filter-name 'ExcessHet' -V ${fol9}/${variantdb}/${raw}.gz -O ${fol8}/${HF}
		${BCFTOOLS} filter -s ExcessHet -e "ExcessHet > 54.69" ${fol9}/${variantdb}/${raw}.vcf.gz -O z -o ${fol8}/${HF}.vcf.gz
		echo "- END -"

		#18
		echo
		echo "> Site Only pre-VQSR"
		# ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" MakeSitesOnlyVcf -I ${fol8}/${HF} -O ${fol8}/${SO}
		#this should be done with picard!
		${BCFTOOLS} view -G ${fol8}/${HF}.vcf.gz -O z -o ${fol8}/${SO}.vcf.gz
		# java ${java_opt2x} -XX:+UseSerialGC -jar ${PICARD} MakeSitesOnlyVcf -I ${fol8}/${HF} -O ${fol8}/${SO}
	;;
esac


echo "- END -"
touch step1718.done



