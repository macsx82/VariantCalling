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
echo "> Indel Variant Recalibrator"
# ${GATK4} --java-options ${java_opt3x} VariantRecalibrator -V ${fol8}/${variantdb}/${SO} -O ${fol8}/${variantdb}/${iVR} --tranches-file ${fol8}/${variantdb}/${tri} --trust-all-polymorphic -tranche "100.0" -tranche "99.95" -tranche "99.9" -tranche "99.5" -tranche "99.0" -tranche "97.0" -tranche "96.0" -tranche "95.0" -tranche "94.0" -tranche "93.5" -tranche "93.0" -tranche "92.0" -tranche "91.0" -tranche "90.0" -an "FS" -an "ReadPosRankSum" -an "MQRankSum" -an "QD" -an "SOR" -mode ${mode_I} --max-gaussians 4 -resource mills,known=false,training=true,truth=true,prior=12:${OTGindels} -resource axiomPoly,known=false,training=true,truth=false,prior=10:${AXIOM} -resource dbsnp,known=true,training=false,truth=false,prior=2:${DBSNP138} 
# ${GATK4} --java-options "${java_opt3x}" VariantRecalibrator -V ${fol8}/${SO} -O ${fol8}/${iVR} -rscriptFile ${fol8}/${mode_I}.plots.R --tranches-file ${fol8}/${tri} -tranche "100.0" -tranche "99.99" -tranche "99.98" -tranche "99.97" -tranche "99.96" -tranche "99.95" -tranche "99.8" -tranche "99.7" -tranche "99.6" -tranche "99.5" -tranche "99.0" -tranche "97.0" -tranche "96.0" -tranche "95.0" -tranche "94.0" -tranche "93.5" -tranche "93.0" -tranche "92.0" -tranche "91.0" -tranche "90.0" -an "FS" -an "ReadPosRankSum" -an "MQRankSum" -an "QD" -an "SOR" -mode ${mode_I} --max-gaussians 4 -resource mills,known=false,training=true,truth=true,prior=12:${OTGindels} -resource axiomPoly,known=false,training=true,truth=false,prior=10:${AXIOM} -resource dbsnp,known=true,training=false,truth=false,prior=2:${DBSNP138} 
${GATK4} --java-options "${java_opt3x}" VariantRecalibrator -V ${fol8}/${SO}.vcf.gz -O ${fol8}/${iVR}.vcf -rscriptFile ${fol8}/${mode_I}.plots.R --tranches-file ${fol8}/${tri} -tranche "100.0" -tranche "99.99" -tranche "99.98" -tranche "99.97" -tranche "99.96" -tranche "99.95" -tranche "99.8" -tranche "99.7" -tranche "99.6" -tranche "99.5" -tranche "99.0" -tranche "97.0" -tranche "96.0" -tranche "95.0" -tranche "94.0" -tranche "93.5" -tranche "93.0" -tranche "92.0" -tranche "91.0" -tranche "90.0" -an "FS" -an "ReadPosRankSum" -an "MQRankSum" -an "QD" -an "SOR" --an "DP" -mode ${mode_I} --max-gaussians 4 -resource mills,known=false,training=true,truth=true,prior=12:${OTGindels} -resource axiomPoly,known=false,training=true,truth=false,prior=10:${AXIOM} -resource dbsnp,known=true,training=false,truth=false,prior=2:${DBSNP138} 
echo "- END -"

touch step19.done

# -an "DP" # excluded from WES



