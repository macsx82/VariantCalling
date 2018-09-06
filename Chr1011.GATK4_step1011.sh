#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - VARIABILI FISSE - ###
SM=$1					#sample name
gVCF="${SM}_g.vcf.gz"			#final_merged gVCF file
fixgVCF="${SM}-g.vcf.gz"		#fixed gVCF file
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

#10a
echo
cd ${fol5}/
echo "> gVCF list"
ls ${SM}_*_g.vcf.gz > "${SM}.list"
echo "- END -"

#10b
echo
cd ${fol5}/
echo "> MergeVcfs"
${GATK4} --java-options ${java_opt2x} MergeVcfs -I "${SM}.list" -O ${fol6}/${gVCF}
echo "- END -"

#11a
echo
cd ${fol6}/
echo "> Merge variants"
${BCFTOOLS} norm -m +any -Oz -o ${fixgVCF} ${gVCF}
echo "- END -"

#11b
echo
cd ${fol6}/
echo "> Move files"
mv -v ${fixgVCF} ${gVCF}
echo "- END -"

#11c
echo
cd ${fol6}/
echo "> Create index"
${BCFTOOLS} index -t -f ${gVCF}
echo "- END -"

#qdel
echo
rm -v ${fol5}/${SM}_*_g.vcf.gz
rm -v ${fol5}/${SM}_*_g.vcf.gz.tbi
rm -v ${fol5}/"${SM}.list"

exit



