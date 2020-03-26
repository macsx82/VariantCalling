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
#generate the common folders needed for the following steps
mkdir -p ${fol7} ${fol8} ${fol9}
#12
echo
# cd ${fol6}/
echo "> Check gVCF"
for chr in ${chr_pool[@]}
do
	current_file=$(find ${fol5}/ -name "${SM}_*_chr${chr}.*_g.vcf.gz" -type f)
	if [[ ${current_file} != "" ]]; then
		#we have access to the variable ${validate_interval}, the file with the list of intervals used for calling with hapCaller
		#We will subset this file extracting each time the list of interval fo the current chromosome
		current_interval_file=$(sed -n "/chr${chr}\./p" ${validate_interval})
		current_file_name=$(basename ${current_file})
    	#all files are already moved to the final destination, so we just need to validate them
    	${GATK4} --java-options "${java_opt1x} -XX:+UseSerialGC" ValidateVariants -V ${fol6_link}/${chr}/${current_file_name} -R ${GNMhg38} -L ${current_interval_file} -gvcf -Xtype ALLELES
	else
		echo "Missing ${chr} chromosome."
	fi
done
echo "- END -"

touch step12.done



