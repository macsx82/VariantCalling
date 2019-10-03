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
source ${hs}/pipeline_functions.sh
### - CODE - ###

#19
echo
# cd ${fol8}/${variantdb}/
echo "> Indel Variant Recalibrator"
# ${GATK4} --java-options ${java_opt3x} VariantRecalibrator -V ${fol8}/${variantdb}/${SO} -O ${fol8}/${variantdb}/${iVR} --tranches-file ${fol8}/${variantdb}/${tri} --trust-all-polymorphic -tranche "100.0" -tranche "99.95" -tranche "99.9" -tranche "99.5" -tranche "99.0" -tranche "97.0" -tranche "96.0" -tranche "95.0" -tranche "94.0" -tranche "93.5" -tranche "93.0" -tranche "92.0" -tranche "91.0" -tranche "90.0" -an "FS" -an "ReadPosRankSum" -an "MQRankSum" -an "QD" -an "SOR" -mode ${mode_I} --max-gaussians 4 -resource mills,known=false,training=true,truth=true,prior=12:${OTGindels} -resource axiomPoly,known=false,training=true,truth=false,prior=10:${AXIOM} -resource dbsnp,known=true,training=false,truth=false,prior=2:${DBSNP138} 
${GATK4} --java-options "${java_opt3x} -XX:+UseSerialGC" VariantRecalibrator -V ${fol8}/${variantdb}/${SO} -O ${fol8}/${variantdb}/${iVR} -rscriptFile ${fol8}/${variantdb}/${mode_I}.plots.R --tranches-file ${fol8}/${variantdb}/${tri} -tranche "100.0" -tranche "99.95" -tranche "99.9" -tranche "99.5" -tranche "99.0" -tranche "97.0" -tranche "96.0" -tranche "95.0" -tranche "94.0" -tranche "93.5" -tranche "93.0" -tranche "92.0" -tranche "91.0" -tranche "90.0" -an "FS" -an "ReadPosRankSum" -an "MQRankSum" -an "QD" -an "SOR" -mode ${mode_I} --max-gaussians 4 -resource mills,known=false,training=true,truth=true,prior=12:${OTGindels} -resource axiomPoly,known=false,training=true,truth=false,prior=10:${AXIOM} -resource dbsnp,known=true,training=false,truth=false,prior=2:${DBSNP138} 
echo "- END -"

touch step19.done

# -an "DP" # excluded from WES



