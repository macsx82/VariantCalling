#!/usr/bin/env bash

#####################################################
# Original scripts from Athanasakis Emmanouil       #
# e-mail: emmanouil.athanasakis[at]burlo.trieste.it #
#                                                   #
# Mods by Massimiliano Cocca - 06/09/2018           #
# e-mail: massimiliano.cocca[at]burlo.trieste.it    #
#                                                   #
#                                                   #
#####################################################

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "${dt1}"
echo

### - VARIABILI FISSE - ###
SM=$1					#sample name
val1="${SM}_1_val_1.fq.gz"		#fastq 1 after trimming
val2="${SM}_2_val_2.fq.gz"		#fastq 2 after trimming
uBAM="${SM}_unmapped.bam"		#unmapped bam

### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1

source ${param_file}
### - CODE - ###

#1a
echo
# cd ${fol1}/
echo "> RGI ID data"
zcat ${fol0}/${val1} | head -n1 | sed 's/ /:/g' | sed 's/@//g' > ${fol1}/${SM}_header; cat ${fol1}/${SM}_header
PU1=$(cat "${fol1}/${SM}_header" | cut -d":" -f1); echo ${PU1}
PU2=$(cat "${fol1}/${SM}_header" | cut -d":" -f2); echo ${PU2}
ID1=$(cat "${fol1}/${SM}_header" | cut -d":" -f3); echo ${ID1}
FL=$(cat "${fol1}/${SM}_header" | cut -d":" -f4); echo ${FL}
TNFL=$(cat "${fol1}/${SM}_header" | cut -d":" -f5); echo ${TNFL}
XX=$(cat "${fol1}/${SM}_header" | cut -d":" -f6); echo ${XX}
YY=$(cat "${fol1}/${SM}_header" | cut -d":" -f7); echo ${YY}
PAIR=$(cat "${fol1}/${SM}_header" | cut -d":" -f8); echo ${PAIR}
FIL=$(cat "${fol1}/${SM}_header" | cut -d":" -f9); echo ${FIL}
BITS=$(cat "${fol1}/${SM}_header" | cut -d":" -f10); echo ${BITS}
ID2=$(cat "${fol1}/${SM}_header" | cut -d":" -f11); echo ${ID2}
echo "- END -"

#1b
echo
# cd ${fol1}/
echo "> Create uBAM starting from fastq trimmed files"
java -jar ${PICARD} FastqToSam F1=${fol0}/${val1} F2=${fol0}/${val2} O=${fol1}/${uBAM} SO=queryname RG="${PU1}.${PU2}" SM=${SM} LB=${LB} PL=${PL} TMP_DIR=${tmp}/
echo "- END -"

#Validation
echo
# cd ${fol1}/
echo "> Validation uBAM"
java -jar ${PICARD} ValidateSamFile I=${fol1}/${uBAM} MODE=SUMMARY TMP_DIR=${tmp}/
echo "- END -"

#Stat
echo
# cd ${fol1}/
${SAMTOOLS} flagstat ${fol1}/${uBAM}
echo
${SAMTOOLS} view -H ${fol1}/${uBAM} | grep '@RG'
echo
${SAMTOOLS} view -H ${fol1}/${uBAM} | grep '@PG'
echo "- END -"

#del
echo
rm -v ${fol1}/"${SM}_header"

# exit



