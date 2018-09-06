#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - VARIABILI - ###
iFOLDER=$1
dFOLDER=$2
oFOLDER=$3
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

${GATK4} --java-options ${java_opt2x} SelectVariants -R ${GNMhg38} -V ${iFOLDER} --discordance ${dFOLDER} -O ${oFOLDER}

exit


