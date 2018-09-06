#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - VARIABILI FISSE - ###
variantdb=$1				#db name
f1=$2					#interval file
f2=$3					#interval file
int_vcf="${variantdb}_${f2}.vcf"	#interval vcf
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

#15
echo
cd ${fol7}/
echo "> GenotypeGVCFs"
${GATK4} --java-options ${java_opt2x} GenotypeGVCFs -R ${GNMhg38} -O ${fol8}/${variantdb}/${int_vcf} -G StandardAnnotation --only-output-calls-starting-in-intervals --use-new-qual-calculator -V gendb://${variantdb}/${f2} -L "${f1}"
echo "- END -"

exit



