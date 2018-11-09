#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - SOURCEs - ###
param_file=$3
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh

### - VARIABILI FISSE - ###
if [[ ${job_a} -eq 0 ]]; then
    f1=$2                   #interval contings
    f1_name=`basename ${f1}`
    c_gv="${SM}_${f1_name}_g.vcf.gz"     #conting gVCF file
else
    f1=$1                   ##interval contings
    f2=$2                   #interval index
    c_gv="${SM}_${f2}_g.vcf.gz"     #conting gVCF file
fi

### - CODE - ###
mkdir -p ${fol5_tmp}
#loop-9
echo
# cd ${fol4}/
echo "> HaplotypeCaller"
# ${GATK4} --java-options ${java_opt2x} ${java_XX1} ${java_XX2} HaplotypeCaller -R ${GNMhg38} -I ${fol4}/${applybqsr} -O ${fol5}/${c_gv} -L "${f1}" -ip ${ip1} --max-alternate-alleles ${maa} -ERC GVCF
${GATK4} --java-options ${java_opt2x} HaplotypeCaller -R ${GNMhg38} -I ${fol4_tmp}/${applybqsr} -O ${fol5_tmp}/${c_gv} -L "${f1}" -ip ${ip1} --max-alternate-alleles ${maa} -ERC GVCF
echo "- END -"

#qdel
echo
# rm -v ${fol4}/"${SM}_bqsr.bam"
# rm -v ${fol4}/"${SM}_bqsr.bai"
# rm -v ${fol4}/"${SM}_bqsr.bam.md5"
#in this step to massimize parallelization we are working on temp folders, so we need to copy all the results back to the correct host
rsync -av -u -P ${fol5_tmp}/${c_gv}* ${USER}@${exec_host}:${fol5_host}/processing/.

touch step09.done
