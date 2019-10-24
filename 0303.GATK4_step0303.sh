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
#3
echo
# cd ${fol1}/
echo "> Merge original input uBAM file with BWA-aligned BAM file"
echo "> Generating a sorted BAM file by queryname, so values for NM, MD and UQ tags are calculated"
# java -Dsamjdk.compression_level=${cl} ${java_opt2x} -XX:+UseSerialGC -jar ${PICARD} MergeBamAlignment VALIDATION_STRINGENCY=SILENT ORIENTATIONS=FR ATTRIBUTES_TO_RETAIN=X0 UNMAPPED=${fol1}/${uBAM} ALIGNED=${fol1}/${bBAM} O=${fol1}/${mBAM} R=${GNMhg38} PE=true SO=unsorted IS_BISULFITE_SEQUENCE=false ALIGNED_READS_ONLY=false CLIP_ADAPTERS=false MAX_RECORDS_IN_RAM=2000000 MC=true MAX_GAPS=-1 PRIMARY_ALIGNMENT_STRATEGY=MostDistant UNMAPPED_READ_STRATEGY=COPY_TO_TAG ALIGNER_PROPER_PAIR_FLAGS=true UNMAP_CONTAM=true TMP_DIR=${tmp}/
# ${SAMTOOLS} sort -n -T ${tmp}/ ${fol1}/${mBAM} | 
java -Dsamjdk.compression_level=${cl} ${java_opt2x} -XX:+UseSerialGC -jar ${PICARD} MergeBamAlignment VALIDATION_STRINGENCY=SILENT ORIENTATIONS=FR ATTRIBUTES_TO_RETAIN=X0 UNMAPPED=${fol1}/${uBAM} ALIGNED=${fol1}/${bBAM} O=${fol1}/${mBAM} R=${GNMhg38} PE=true SO=unsorted IS_BISULFITE_SEQUENCE=false ALIGNED_READS_ONLY=false CLIP_ADAPTERS=false MAX_RECORDS_IN_RAM=2000000 MC=true MAX_GAPS=-1 PRIMARY_ALIGNMENT_STRATEGY=MostDistant UNMAPPED_READ_STRATEGY=COPY_TO_TAG ALIGNER_PROPER_PAIR_FLAGS=true UNMAP_CONTAM=true TMP_DIR=${tmp}/
echo "- END -"

#Stat
echo
# call the sam_stats function
sam_stats ${fol1}/${mBAM}


#generate a file that will tell us if the step is completed
touch step0303_${SM}.done
# exit



