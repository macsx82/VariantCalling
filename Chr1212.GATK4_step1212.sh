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
#generate the common folders needed for the following steps
mkdir -p ${fol7} ${fol8} ${fol9}
#12
echo
# cd ${fol6}/
echo "> Check gVCF"
# while read -r f1
# do
    # ${GATK4} --java-options "${java_opt1x} -XX:+UseSerialGC" ValidateVariants -V ${fol6}/${gVCF} -R ${GNMhg38} -L "${f1}" -gvcf -Xtype ALLELES
    ${GATK4} --java-options "${java_opt1x} -XX:+UseSerialGC" ValidateVariants -V ${fol6}/${gVCF} -R ${GNMhg38} -L ${validate_interval} -gvcf -Xtype ALLELES

# done < ${validate_interval}

#after the merging and validating, we need to generate a link to the file in the collective folder
ln -f -s ${fol6}/${gVCF} ${fol6_link}/${gVCF}

echo "- END -"

touch step12.done



