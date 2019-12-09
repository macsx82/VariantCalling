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

#7a
echo
# cd ${fol3}/
echo "> BQSRReports ID data"
# BRs=`find ${fol3}/${SM}_*_recaldata.csv -type f -printf "%f\n" | awk '{print " -I "$1}' | tr "\n" "\t" | sed 's/\t / /g'`
BRs=`find ${fol3}/${SM}_*_recaldata.csv -type f | awk '{print " -I "$1}' | tr "\n" "\t" | sed 's/\t / /g'`
echo "- END -"

#7b
echo
# cd ${fol3}/
echo "> GatherBqsrReports"
${GATK4} --java-options "${java_opt2x}" GatherBQSRReports ${BRs} -O ${fol3}/${bqsrrd}
echo "- END -"

touch step0707.done