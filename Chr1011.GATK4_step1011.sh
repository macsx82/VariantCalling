#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - SOURCEs - ###
param_file=$1
#we need a chr parameter, since the file name we generated is not completely standardized
chr=$2
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${hs}/pipeline_functions.sh
### - CODE - ###
mkdir -p ${fol6} ${tmp}
#10a
#in this version of the script, we are working by chromosome, so what we need is just to create a folder for the actual chr and copy the files related to the current sample in it
#we will handle here the chrX overlap problem for males, removing the overlapping variants in the par and non par regions
#the files here will be sent to the GDBimport step, so we can work on single chromosomes
echo "gVCF collection step for the current sample "
# ${SM}_wgs_calling_regions_chr6.hg38.interval_list_g.vcf.gz
current_file=$(ls ${fol5}/${SM}_*_g.vcf.gz | sed -n "s/\(chr${chr}\.\)/\1/p")
echo "- END -"

#10b
#We have to process the files and save them in the correct location
#We also have to take care of the chrX problem
echo "> Copy gVcf files in the correct path"
# ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" MergeVcfs -I "${fol6}/${SM}.list" -O ${fol6}/${gVCF}
#use the bcftools option: faster and without java (which is a drag!!)
#Since we added padding to the HapCaller step, we need to take care of chrX par and non par region merging
${BCFTOOLS} concat -a -D -f ${fol6}/${SM}.list | ${BCFTOOLS} sort -T ${tmp} -O z -o ${fol6}/${gVCF}

echo "- END -"

#11a
echo
# cd ${fol6}/
echo ">Normalize indels and Merge variants"
${BCFTOOLS} norm -f ${GNMhg38} ${fol6}/${gVCF} | ${BCFTOOLS} norm -m +any -Oz -o ${fol6}/${fixgVCF}
echo "- END -"

#11b
echo
# cd ${fol6}/
echo "> Move files"
# mv -v ${fol6}/${fixgVCF} ${fol6}/${gVCF}
rsync -au -Pv ${fol6}/${fixgVCF} ${fol6}/${gVCF}
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



