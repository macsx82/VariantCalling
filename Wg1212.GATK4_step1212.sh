#!/usr/bin/env bash
set -eo pipefail

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - VARIABILI FISSE - ###
SM=$1					#sample name
gVCF="${SM}_g.vcf.gz"			#final_merged 
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

#12
echo
cd ${fol6}/
echo "> Check gVCF"
while read -r f1; do ${GATK4} --java-options ${java_opt1x} ValidateVariants -V ${gVCF} -R ${GNMhg38} -L "${f1}" -gvcf -Xtype ALLELES; done < ${sorgILhg38wgenesCHECK}
echo "- END -"

exit



