#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - SOURCEs - ###
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - CODE - ###

#10a
echo
# cd ${fol5}/
echo "> gVCF list"
ls ${fol5}/${SM}_*_g.vcf.gz > "${fol5}/${SM}.list"
echo "- END -"

#10b
echo
# cd ${fol5}/
echo "> MergeVcfs"
${GATK4} --java-options ${java_opt2x} MergeVcfs -I "${fol5}/${SM}.list" -O ${fol6}/${gVCF}
echo "- END -"

#11a
echo
# cd ${fol6}/
echo "> Merge variants"
${BCFTOOLS} norm -m +any -Oz -o ${fol6}/${fixgVCF} ${fol6}/${gVCF}
echo "- END -"

#11b
echo
# cd ${fol6}/
echo "> Move files"
mv -v ${fol6}/${fixgVCF} ${fol6}/${gVCF}
echo "- END -"

#11c
echo
# cd ${fol6}/
echo "> Create index"
${BCFTOOLS} index -t -f ${fol6}/${gVCF}
echo "- END -"

#qdel
echo
# rm -v ${fol5}/${SM}_*_g.vcf.gz
# rm -v ${fol5}/${SM}_*_g.vcf.gz.tbi
# rm -v ${fol5}/"${SM}.list"

touch step1011.done



