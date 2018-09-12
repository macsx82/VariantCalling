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
mkdir -p ${fol1}

#Validation
echo
echo "> Validation inBAM"
java -jar ${PICARD} ValidateSamFile I=${fol1}/${inbam} MODE=SUMMARY TMP_DIR=${tmp}/
java -jar ${PICARD} ValidateSamFile I=${fol1}/${inbam} MAX_OUTPUT=10 MODE=VERBOSE TMP_DIR=${tmp}/
echo "- END -"

#Stat
echo
# call the sam_stats function
sam_stats ${fol1}/${inbam}

touch data_prep01.done



