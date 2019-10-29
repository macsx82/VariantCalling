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
### - VARIABILI FISSE - ###
#Here we need an option to work on the whole genome dataset, instead of downsampling with the -L option
### - CODE - ###
f1=${bqsr_intervals}                   #interval contigs

echo "> BaseRecalibrator"

if [[ ${whole_genome} -eq 1 ]]; then
    c_bqsrrd="${SM}_wg_recaldata.csv"    #contig recalibration report
    # f1=$2                   #interval contigs
    #No need for intervals...we'll use them only in the calling step
	# ${GATK4} --java-options "${java_opt2x}" BaseRecalibrator -R ${GNMhg38} -I ${fol1}/${fBAM} --use-original-qualities -O ${fol3}/${c_bqsrrd} --known-sites ${DBSNP_latest} --known-sites ${INDELS} --known-sites ${OTGindels}
	${GATK4} --java-options "${java_opt2x}" BaseRecalibrator -R ${GNMhg38} -I ${fol1}/${fCRAM} --use-original-qualities -O ${fol3}/${c_bqsrrd} --known-sites ${DBSNP_latest} --known-sites ${INDELS} --known-sites ${OTGindels}

else
    # f1=$1                   #interval contigs
    # f2=$2                   #interval qsubID
    c_bqsrrd="${SM}_wes_recaldata.csv"    #contig recalibration report
	# ${GATK4} --java-options "${java_opt2x}" BaseRecalibrator -R ${GNMhg38} -I ${fol1}/${fBAM} --use-original-qualities -O ${fol3}/${c_bqsrrd} --known-sites ${DBSNP_latest} --known-sites ${INDELS} --known-sites ${OTGindels} -ip 100 -L ${f1}
	${GATK4} --java-options "${java_opt2x}" BaseRecalibrator -R ${GNMhg38} -I ${fol1}/${fCRAM} --use-original-qualities -O ${fol3}/${c_bqsrrd} --known-sites ${DBSNP_latest} --known-sites ${INDELS} --known-sites ${OTGindels} -ip 100 -L ${f1}
fi

echo "- END -"

#generate a file that will tell us if the step is completed
touch step0606_${SM}.done
# exit


