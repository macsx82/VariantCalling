#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt1"
echo


### - SOURCEs - ###
param_file=$3
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - VARIABILI FISSE - ###
#Here we need an option to work on the whole genome dataset, instead of downsampling with the -L option
### - CODE - ###
if [[ ${whole_genome} -eq 1 ]]; then
    c_bqsrrd="${SM}_wg_recaldata.csv"    #conting recalibration report
    f1=$2                   #interval contings
else
    f1=$1                   #interval contings
    f2=$2                   #interval qsubID
    c_bqsrrd="${SM}_${f2}_recaldata.csv"    #conting recalibration report
fi

echo "> BaseRecalibrator"
${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" BaseRecalibrator -R ${GNMhg38} -I ${fol1}/${fBAM} --use-original-qualities -O ${fol3}/${c_bqsrrd} --known-sites ${DBSNP138} --known-sites ${INDELS} --known-sites ${OTGindels} -ip 100 -L ${f1}
echo "- END -"

#generate a file that will tell us if the step is completed
touch step0606.done
# exit


