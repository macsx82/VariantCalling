#!/usr/bin/env bash
#####################################################
# Original scripts from Athanasakis Emmanouil       #
# e-mail: emmanouil.athanasakis[at]burlo.trieste.it #
#                                                   #
# Mods by Massimiliano Cocca - 24/10/2019           #
# e-mail: massimiliano.cocca[at]burlo.trieste.it    #
#                                                   #
#                                                   #
#####################################################
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt1"
echo

### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${hs}/pipeline_functions.sh

### - CODE - ###
mkdir -p ${fol1} ${fol2} ${fol3} ${fol4} ${fol5} ${fol6} ${tmp} #${fol7} ${fol8} ${fol9}
#4
echo
# cd ${fol1}/
echo "> Mark duplicate reads to avoid counting non-independent observations"
java -Dsamjdk.compression_level=${cl} ${java_opt2x} -XX:+UseSerialGC -jar ${PICARD} MarkDuplicates INPUT=${fol1}/${mBAM} OUTPUT=${fol1}/${mdBAM} METRICS_FILE=${fol1}/${metfile} VALIDATION_STRINGENCY=SILENT OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 ASSUME_SORT_ORDER=queryname MAX_RECORDS_IN_RAM=2000000 CREATE_MD5_FILE=true TMP_DIR=${tmp}/
echo "- END -"

#Stat
echo
# call the sam_stats function
sam_stats ${fol1}/${mdBAM}

#generate a file that will tell us if the step is completed
touch step0404_${SM}.done
# exit



