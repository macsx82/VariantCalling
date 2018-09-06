#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - VARIABILI FISSE - ###
variantdb=$1				#db name
f1=$2					#interval file
f2=$3					#interval file
raw="${variantdb}_raw.vcf"		#cohort raw vcf
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

#16a
echo
cd ${fol8}/${variantdb}/
echo "> Raw VCFs ID data"
wVCF=`find ${variantdb}_*.vcf -type f -printf "%f\n" | awk '{print " I="$1}' | tr "\n" "\t" | sed 's/\t / /g'`
echo "- END -"

#16b
echo
cd ${fol8}/${variantdb}/
echo "> Merge VCFs"
java -jar ${PICARD} GatherVcfs ${wVCF} O=${fol9}/${variantdb}/${raw}
echo "- END -"

#del
echo
rm -v ${fol8}/${variantdb}/${variantdb}_*.vcf*

exit



