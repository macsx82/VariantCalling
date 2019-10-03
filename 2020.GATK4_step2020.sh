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

#20
echo
# cd ${fol8}/${variantdb}/
echo "> Snp Variant Recalibrator"
${GATK4} --java-options "${java_opt4x} -XX:+UseSerialGC" VariantRecalibrator -V ${fol8}/${variantdb}/${SO} -O ${fol8}/${variantdb}/${sVR} -rscriptFile ${fol8}/${variantdb}/${mode_S}.plots.R --tranches-file ${fol8}/${variantdb}/${trs} -tranche "100.0" -tranche "99.99" -tranche "99.98" -tranche "99.97" -tranche "99.96" -tranche "99.95" -tranche "99.9" -tranche "99.85" -tranche "99.8" -tranche "99.75" -tranche "99.7" -tranche "99.65" -tranche "99.6" -tranche "99.5" -tranche "99.4" -tranche "99.3" -tranche "99.0" -tranche "98.0" -tranche "97.0" -tranche "90.0" -an "QD" -an "MQRankSum" -an "ReadPosRankSum" -an "FS" -an "MQ" -an "SOR" -mode ${mode_S} --max-gaussians 6 -resource hapmap,known=false,training=true,truth=true,prior=15:${HAPMAP} -resource omni,known=false,training=true,truth=true,prior=12:${OMNI} -resource 1000G,known=false,training=true,truth=false,prior=10:${OTGsnps} -resource dbsnp,known=true,training=false,truth=false,prior=7:${DBSNP138} 
echo "- END -"

touch step20.done

# -an "DP" # excluded from WES



