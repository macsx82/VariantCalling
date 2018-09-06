#!/usr/bin/env bash

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
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

#loop-9
echo
cd ${fol4}/
echo "> HaplotypeCaller"
${GATK4} --java-options ${java_opt2x} ${java_XX1} ${java_XX2} HaplotypeCaller -R ${GNMhg38} -I ${applybqsr} -O ${fol5}/${c_gv} -L "${f1}" -ip ${ip1} --max-alternate-alleles ${maa} -ERC GVCF
echo "- END -"

#qdel
echo
rm -v ${fol4}/"${SM}_bqsr.bam"
rm -v ${fol4}/"${SM}_bqsr.bai"
rm -v ${fol4}/"${SM}_bqsr.bam.md5"

exit



