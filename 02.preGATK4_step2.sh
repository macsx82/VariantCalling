#!/usr/bin/env bash

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

#2
echo
# cd ${fol1}/
echo "> Revert to uBAM"
java ${java_opt1x} -jar ${PICARD} RevertSam I=${fol1}/${inbam} O=${fol2}/${ubam} SANITIZE=true MAX_DISCARD_FRACTION=0.005 ATTRIBUTE_TO_CLEAR=XT ATTRIBUTE_TO_CLEAR=XN ATTRIBUTE_TO_CLEAR=AS ATTRIBUTE_TO_CLEAR=OC ATTRIBUTE_TO_CLEAR=OP SORT_ORDER=queryname RESTORE_ORIGINAL_QUALITIES=true REMOVE_DUPLICATE_INFORMATION=true REMOVE_ALIGNMENT_INFORMATION=true TMP_DIR=${tmp}/
echo "- END -"

#Validation
echo
# cd ${fol2}/
echo "> Validation uBAM"
java -jar ${PICARD} ValidateSamFile I=${fol2}/${ubam} MODE=SUMMARY TMP_DIR=${tmp}/
java -jar ${PICARD} ValidateSamFile I=${fol2}/${ubam} MAX_OUTPUT=10 MODE=VERBOSE TMP_DIR=${tmp}/
echo "- END -"

touch data_prep02.done



