#!/usr/bin/env bash

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
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

#2a
echo
cd ${fol1}/
echo "> RGI ID data"
zcat ${fol0}/${val1} | head -n1 | sed 's/ /:/g' | sed 's/@//g' > "${SM}_header"; cat "${SM}_header"
PU1=$(cat "${SM}_header" | cut -d":" -f1); echo ${PU1}
PU2=$(cat "${SM}_header" | cut -d":" -f2); echo ${PU2}

echo "- END -"

#2b
echo
cd ${fol1}/
echo "> Read unmapped BAM, convert on-the-fly to FASTQ and stream to BWA MEM for alignment"
java -Dsamjdk.compression_level=${cl} ${java_opt2x} -jar ${PICARD} SamToFastq INPUT=${uBAM} FASTQ=/dev/stdout INTERLEAVE=true NON_PF=true TMP_DIR=${tmp}/ | ${BWA} mem -R "@RG\tID:${PU1}.${PU2}\tSM:${SM}\tLB:${LB}\tPL:${PL}" -K 100000000 -p -v 3 -t ${thr} -Y ${GNMhg38} /dev/stdin | ${SAMTOOLS} view -1 - > ${bBAM}
echo "- END -"

#Validation
echo
cd ${fol1}/
echo "> Validation bBAM"
java -jar ${PICARD} ValidateSamFile I=${bBAM} MODE=SUMMARY TMP_DIR=${tmp}/
echo "- END -"

#Stat
echo
cd ${fol1}/
${SAMTOOLS} flagstat ${bBAM}
echo
${SAMTOOLS} view -H ${bBAM} | grep '@RG'
echo
${SAMTOOLS} view -H ${bBAM} | grep '@PG'
echo "- END -"

#del
echo
rm -v ${fol1}/"${SM}_header"

exit



