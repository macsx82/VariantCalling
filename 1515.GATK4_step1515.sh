#!/usr/bin/env bash
set -e

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
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - CODE - ###

#15
echo
cd ${fol7}/
echo "> GenotypeGVCFs"
${GATK4} --java-options ${java_opt2x} GenotypeGVCFs -R ${GNMhg38} -O ${fol8}/${variantdb}/${int_vcf} -G StandardAnnotation --only-output-calls-starting-in-intervals --use-new-qual-calculator -V gendb://${variantdb}/${f2} -L "${f1}"
echo "- END -"

touch step15.done



