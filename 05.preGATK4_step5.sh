#!/usr/bin/env bash

echo
echo "> pipeline: Το χρυσόμαλλο δέρας"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt1"
echo

### - VARIABILI FISSE - ###
# SM=$1					#bam file name
# fastq1="${SM}_1.fastq"			#fastq 1
# fastq2="${SM}_2.fastq"			#fastq 2
### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - CODE - ###

#5
echo
# cd ${fol2}/
echo "> Trimming"
${ph5} -paired -q ${q} -e ${e} -o ${fol4}/ -clip_R1 ${cR1} -clip_R2 ${cR2} -three_prime_clip_R1 ${tpcR1} -three_prime_clip_R2 ${tpcR2} "${fastq1}" "${fastq2}"
echo "- END -"

touch data_prep05.done



