#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - SOURCEs - ###
param_file=$1
#we need a chr parameter, since the file name we generated is not completely standardized
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${hs}/pipeline_functions.sh
### - CODE - ###
mkdir -p ${fol6} ${tmp}
#10a
#in this version of the script, we are working by chromosome, so what we need is just to create a folder for the actual chr and copy the files related to the current sample in it
#we will handle here the chrX overlap problem for males, removing the overlapping variants in the par and non par regions
#the files here will be sent to the GDBimport step, so we can work on single chromosomes
echo "gVCF collection step for the current sample "
# ${SM}_wgs_calling_regions_chr6.hg38.interval_list_g.vcf.gz
# current_file=$(ls ${fol5}/${SM}_*_g.vcf.gz | sed -n "s/\(chr${chr}\.\)/\1/p")
#now we have access to the chr_pool variable, we can use it to iterate and get files from each chr in the right place
for chr in ${chr_pool[@]}
do

	current_file=$(find ${fol5}/ -name "${SM}_*_chr${chr}.*_g.vcf.gz" -type f)
	
	if [[ ${current_file} != "" ]]; then
		current_file_name=$(basename ${current_file})
		#We have to process the files and save them in the correct location
		#We also have to take care of the chrX problem
		# we need to check if there is no chrY file (we're working with a female sample)

		echo ">Normalize indels and Merge variants"
		${BCFTOOLS} norm -f ${GNMhg38} ${current_file} | ${BCFTOOLS} norm -m +any -Oz -o ${fol6_link}/${chr}/${current_file_name}
		echo "- END -"
		echo "> Create index"
		${BCFTOOLS} index -t -f ${fol6_link}/${chr}/${current_file_name}
		echo "- END -"
	else
		echo "Missing ${chr} chromosome."
	fi

done
# rm -v ${fol5}/${SM}_*_g.vcf.gz
# rm -v ${fol5}/${SM}_*_g.vcf.gz.tbi
# rm -v ${fol5}/"${SM}.list"

touch step1011.done



