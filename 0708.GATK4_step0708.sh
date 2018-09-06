#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt1"
echo

### - VARIABILI FISSE - ###
SM=$1					#sample name
f1=$2					#interval contings
f2=$3					#interval qsubID
fBAM="${SM}_fixed.bam"			#sorted and fixed file
c_bqsrrd="${SM}_${f2}_recaldata.csv"	#conting recalibration report
bqsrrd="${SM}_recal_data.csv"		#final_merged recalibration report
applybqsr="${SM}_bqsr.bam"		#final_merged apply recalibration report in bam
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

#7a
echo
cd ${fol3}/
echo "> BQSRReports ID data"
BRs=`find ${SM}_*_recaldata.csv -type f -printf "%f\n" | awk '{print " -I "$1}' | tr "\n" "\t" | sed 's/\t / /g'`
echo "- END -"

#7b
echo
cd ${fol3}/
echo "> GatherBqsrReports"
${GATK4} --java-options ${java_opt2x} GatherBQSRReports ${BRs} -O ${bqsrrd}
echo "- END -"

#8
echo
cd ${fol1}/
echo "> ApplyBQSR"
${GATK4} --java-options ${java_opt2x} ApplyBQSR -R ${GNMhg38} -I ${fBAM} -O ${fol4}/${applybqsr} -bqsr ${fol3}/${bqsrrd} --static-quantized-quals 10 --static-quantized-quals 20 --static-quantized-quals 30 --add-output-sam-program-record --create-output-bam-md5 --use-original-qualities
echo "- END -"

#Validation
echo
cd ${fol4}/
echo "> Validation applybqsr"
java -jar ${PICARD} ValidateSamFile I=${applybqsr} MODE=SUMMARY TMP_DIR=${tmp}/
echo "- END -"

#Stat
echo
cd ${fol4}/
${SAMTOOLS} flagstat ${applybqsr}
echo
${SAMTOOLS} view -H ${applybqsr} | grep '@RG'
echo
${SAMTOOLS} view -H ${applybqsr} | grep '@PG'
echo "- END -"

#del
echo
rm -r ${fol3}/${SM}_*_recaldata.csv
rm -r ${fol3}/"${SM}_recal_data.csv"
rm -r ${fol1}/"${SM}_fixed.bam"
rm -r ${fol1}/"${SM}_fixed.bam.bai"
rm -r ${fol1}/"${SM}_fixed.bam.md5"
exit



