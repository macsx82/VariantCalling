#!/usr/bin/env bash
set -e

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
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - CODE - ###

#10a1
echo
# cd ${fol5}/
echo "> gVCF list"
mkdir -p ${fol5}/f_${SM}
ls ${fol5}/${SM}_*_g.vcf.gz > ${fol5}/f_${SM}/${SM}.list

#10a2
echo
# cd ${fol5}/f_${SM}/
echo "> Split gVCF list"
awk '{print "../"$1}' "${SM}.list" > listToSplit
split -a 2 -d listToSplit
for i in x*; do mv ${i} "${i}.list"; done
echo "- END -"

#10b
echo
cd ${fol5}/"f_${SM}"/
echo "> Sub-merge gVCF files"
for ((b=0; b<=9; b++)); do ${GATK4} --java-options ${java_opt2x} MergeVcfs -I x0${b}.list -O 0${b}_g.vcf.gz; echo; done
for ((b=10; b<=21; b++)); do ${GATK4} --java-options ${java_opt2x} MergeVcfs -I x${b}.list -O ${b}_g.vcf.gz; echo; done

#10c
echo
cd ${fol5}/"f_${SM}"/
echo "> Merged-gVCF list"
ls *_g.vcf.gz > "${SM}.list"
echo "- END -"

#10d
echo
cd ${fol5}/"f_${SM}"/
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
rm -r ${fol5}/"f_${SM}"/

exit



