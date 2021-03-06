#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt1"
echo

### - SOURCEs - ###
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${hs}/pipeline_functions.sh
### - CODE - ###

#8
echo
# cd ${fol1}/
echo "> ApplyBQSR"
${GATK4} --java-options "${java_opt2x}" ApplyBQSR -R ${GNMhg38} -I ${fol1}/${fCRAM} -O ${fol4}/${applybqsr} -bqsr ${fol3}/${bqsrrd} --static-quantized-quals 10 --static-quantized-quals 20 --static-quantized-quals 30 --add-output-sam-program-record --create-output-bam-md5 --use-original-qualities
echo "- END -"

#Validation
echo
# cd ${fol4}/
echo "> Validation applybqsr"
# call the sam_validate function
sam_validate ${fol4}/${applybqsr}

#Stat
echo
# cd ${fol4}/
# call the sam_stats function
sam_stats ${fol4}/${applybqsr}

#del
# echo
# rm -r ${fol3}/${SM}_*_recaldata.csv
# rm -r ${fol3}/"${SM}_recal_data.csv"
# rm -r ${fol1}/"${SM}_fixed.bam"
# rm -r ${fol1}/"${SM}_fixed.bai"
# rm -r ${fol1}/"${SM}_fixed.bam.md5"
# exit


touch step0808.done