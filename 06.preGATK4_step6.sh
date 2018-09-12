#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Το χρυσόμαλλο δέρας"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt1"
echo

### - VARIABILI FISSE - ###
### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - CODE - ###
#6
echo
echo "> Fastq QC control"
${ph4} ${fol4}/${val1} -o ${fol3}/
${ph4} ${fol4}/${val2} -o ${fol3}/
echo "- END -"

touch data_prep06.done



