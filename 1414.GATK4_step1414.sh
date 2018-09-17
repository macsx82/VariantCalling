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
f1=$1					#interval file
f2=$2					#interval file
### - CODE - ###

case ${joint_mode} in
    DB )
        #14
        echo
        cd ${fol7}/${variantdb}/
        echo "> GenomicsDBImport"
        bs=`wc -l ${fol7}/${variantdb}/gVCF.list| cut -f 1 -d " "`
        ${GATK4} --java-options ${java_opt2x} GenomicsDBImport --genomicsdb-workspace-path ${fol7}/${variantdb}/${f2} --batch-size ${bs} -L "${f1}" --sample-name-map ${fol7}/${variantdb}/gVCF.list --reader-threads ${rt} -ip ${ip2}
        echo "- END -"
    ;;
    GENO )
        echo
        # cd ${fol7}/${variantdb}/
        samples_list=`find ${fol6}/*_g.vcf.gz -type f -printf "%f\n" | awk -v base_folder=${fol6} '{print "-V "base_folder"/"$1}'| tr "\n" " "`
        echo "> CombineGVCFs"
        ${GATK4} --java-options ${java_opt2x} CombineGVCFs -O ${fol7}/${variantdb}/${f2}_g.vcf.gz -R ${GNMhg38} -L "${f1}" ${samples_list}
        echo "- END -"
    ;;
esac

touch step14.done



