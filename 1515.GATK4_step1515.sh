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
mkdir -p ${tmp}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - VARIABILI FISSE - ###
f1=$1					#interval file
# f2=$2                    #interval file
f2="all_intervals"					#interval file
int_vcf="${variantdb}_${f2}.vcf.gz"	#interval vcf
### - CODE - ###


case ${joint_mode} in
    DB )
        #15
        echo
        # cd ${fol7}/
        echo "> GenotypeGVCFs"
        # ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" GenotypeGVCFs -R ${GNMhg38} -O ${fol8}/${variantdb}/${int_vcf} -G StandardAnnotation --only-output-calls-starting-in-intervals --use-new-qual-calculator -V gendb://${fol7}/${variantdb}/${f2} -L "${f1}"
        ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" GenotypeGVCFs -R ${GNMhg38} -O ${fol8}/${variantdb}/${int_vcf} -G StandardAnnotation --only-output-calls-starting-in-intervals --use-new-qual-calculator -V gendb://${fol7}/${variantdb}/dbImport -L "${f1}"
        echo "- END -"

    ;;
    GENO )
        #15
        echo
        # cd ${fol7}/
        echo "> GenotypeGVCFs"
        ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" GenotypeGVCFs -R ${GNMhg38} -O ${fol8}/${variantdb}/${int_vcf} -G StandardAnnotation --only-output-calls-starting-in-intervals --use-new-qual-calculator -V ${fol7}/${variantdb}/${f2}_g.vcf.gz -L "${f1}"
        echo "- END -"
    ;;
esac



touch step15.done



