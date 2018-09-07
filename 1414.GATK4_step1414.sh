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
### - SOURCEs - ###
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - CODE - ###

#14
echo
cd ${fol7}/${variantdb}/
echo "> GenomicsDBImport"
${GATK4} --java-options ${java_opt2x} GenomicsDBImport --genomicsdb-workspace-path ${fol7}/${variantdb}/${f2} --batch-size ${bs} -L "${f1}" --sample-name-map gVCF.list --reader-threads ${rt} -ip ${ip2}
echo "- END -"

touch step14.done



