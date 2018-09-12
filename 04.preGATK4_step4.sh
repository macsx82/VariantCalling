#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Το χρυσόμαλλο δέρας"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt1"
echo

### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - CODE - ###
mkdir -p ${fol4} ${fol3}
 #4
echo
# cd ${fol2}/
echo "> Fastq QC control"
${ph4} "${fastq1}" -o ${fol3}/
${ph4} "${fastq2}" -o ${fol3}/
echo "- END -"

touch data_prep04.done



