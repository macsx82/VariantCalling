#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt1"
echo

### - VARIABILI FISSE - ###
f1=$1					#interval contings
f2=$2					#interval qsubID
SM=$3					#sample name
fBAM="${SM}_fixed.bam"			#sorted and fixed file
c_bqsrrd="${SM}_${f2}_recaldata.csv"	#conting recalibration report
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

#loop-6
echo
cd ${fol1}/
echo "> BaseRecalibrator"
${GATK4} --java-options ${java_opt2x} BaseRecalibrator -R ${GNMhg38} -I ${fBAM} --use-original-qualities -O ${fol3}/${c_bqsrrd} --known-sites ${DBSNP138} --known-sites ${INDELS} --known-sites ${OTGindels} -L ${f1}
echo "- END -"

exit



