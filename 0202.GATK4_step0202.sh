#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt1"
echo

### - VARIABILI FISSE - ###
SM=$1					#sample name
val1="${SM}_1_val_1.fq.gz"		#fastq 1 after trimming
val2="${SM}_2_val_2.fq.gz"		#fastq 2 after trimming
uBAM="${SM}_unmapped.bam"		#unmapped bam
bBAM="${SM}_bwa.bam"			#mapped bam
### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - CODE - ###

#2a
echo
# cd ${fol1}/
echo "> RGI ID data"
zcat ${fol0}/${val1} | head -n1 | sed 's/ /:/g' | sed 's/@//g' > "${fol1}/${SM}_header"; cat "${fol1}/${SM}_header"
PU1=$(cat "${fol1}/${SM}_header" | cut -d":" -f1); echo ${PU1}
PU2=$(cat "${fol1}/${SM}_header" | cut -d":" -f2); echo ${PU2}

echo "- END -"

#2b
echo
# cd ${fol1}/
echo "> Read unmapped BAM, convert on-the-fly to FASTQ and stream to BWA MEM for alignment"
java -Dsamjdk.compression_level=${cl} ${java_opt2x} -jar ${PICARD} SamToFastq INPUT=${fol1}/${uBAM} FASTQ=/dev/stdout INTERLEAVE=true NON_PF=true TMP_DIR=${tmp}/ | ${BWA} mem -R "@RG\tID:${PU1}.${PU2}\tSM:${SM}\tLB:${LB}\tPL:${PL}" -K 100000000 -p -v 3 -t ${thr} -Y ${GNMhg38} /dev/stdin | ${SAMTOOLS} view -1 - > ${fol1}/${bBAM}
echo "- END -"

#Validation
echo
# call the sam_validate function
echo "> Validation bBAM"
sam_validate ${fol1}/${bBAM}

#Stat
echo
# call the sam_stats function
sam_stats ${fol1}/${bBAM}

#del
echo
rm -v ${fol1}/"${SM}_header"

#generate a file that will tell us if the step is completed
touch step0202.done
# exit



