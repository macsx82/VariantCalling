#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - VARIABILI FISSE - ###
f1=$1					#interval file
f2=$2					#interval file
SM=$3					#sample name
applybqsr="${SM}_bqsr.bam"		#final_merged apply recalibration report in bam
c_gv="${SM}_${f2}_g.vcf.gz"		#conting gVCF file
### - SOURCEs - ###
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - CODE - ###

#loop-9
echo
# cd ${fol4}/
echo "> HaplotypeCaller"
${GATK4} --java-options ${java_opt2x} ${java_XX1} ${java_XX2} HaplotypeCaller -R ${GNMhg38} -I ${fol4}/${applybqsr} -O ${fol5}/${c_gv} -L "${f1}" -ip ${ip1} --max-alternate-alleles ${maa} -ERC GVCF
echo "- END -"

#qdel
echo
rm -v ${fol4}/"${SM}_bqsr.bam"
rm -v ${fol4}/"${SM}_bqsr.bai"
rm -v ${fol4}/"${SM}_bqsr.bam.md5"

touch step09.done
