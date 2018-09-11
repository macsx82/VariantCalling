#!/usr/bin/env bash

echo
echo "> pipeline: Το χρυσόμαλλο δέρας"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt1"
echo

### - VARIABILI FISSE - ###
SM=$1					#sample name
fastq1="${SM}_1.fastq"			#fastq 1
fastq2="${SM}_2.fastq"			#fastq 2
### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - CODE - ###

#4
echo
# cd ${fol2}/
echo "> Fastq QC control"
${ph4} "${fol2}/${fastq1}.gz" -o ${fol3}/
${ph4} "${fol2}/${fastq2}.gz" -o ${fol3}/
echo "- END -"

touch data_prep04.done



