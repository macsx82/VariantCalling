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
echo "> Snp Variant Recalibrator"
# ${GATK4} --java-options "${java_opt4x}" VariantRecalibrator -V ${fol8}/${SO} -O ${fol8}/${sVR} -rscriptFile ${fol8}/${mode_S}.plots.R --tranches-file ${fol8}/${trs} -tranche "100.0" -tranche "99.99" -tranche "99.98" -tranche "99.97" -tranche "99.96" -tranche "99.95" -tranche "99.94" -tranche "99.93" -tranche "99.92" -tranche "99.91" -tranche "99.9" -tranche "99.85" -tranche "99.8" -tranche "99.75" -tranche "99.7" -tranche "99.65" -tranche "99.6" -tranche "99.5" -tranche "99.4" -tranche "99.3" -tranche "99.0" -tranche "98.0" -tranche "97.0" -tranche "90.0" -an "QD" -an "MQRankSum" -an "ReadPosRankSum" -an "FS" -an "MQ" -an "SOR" -mode ${mode_S} --max-gaussians 6 -resource hapmap,known=false,training=true,truth=true,prior=15:${HAPMAP} -resource omni,known=false,training=true,truth=true,prior=12:${OMNI} -resource 1000G,known=false,training=true,truth=false,prior=10:${OTGsnps} -resource dbsnp,known=true,training=false,truth=false,prior=7:${DBSNP138} 
${GATK4} --java-options "${java_opt4x}" VariantRecalibrator -V ${fol8}/${SO}.vcf.gz -O ${fol8}/${sVR}.vcf --rscript-file ${fol8}/${mode_S}.plots.R --tranches-file ${fol8}/${trs} -tranche "100.0" -tranche "99.99" -tranche "99.98" -tranche "99.97" -tranche "99.96" -tranche "99.95" -tranche "99.94" -tranche "99.93" -tranche "99.92" -tranche "99.91" -tranche "99.9" -tranche "99.85" -tranche "99.8" -tranche "99.75" -tranche "99.7" -tranche "99.65" -tranche "99.6" -tranche "99.5" -tranche "99.4" -tranche "99.3" -tranche "99.0" -tranche "98.0" -tranche "97.0" -tranche "90.0" -an "QD" -an "MQRankSum" -an "ReadPosRankSum" -an "FS" -an "MQ" -an "SOR" -an "DP" -mode ${mode_S} --resource omni,known=false,training=true,truth=true,prior=12:${OMNI} --resource 1000G,known=false,training=true,truth=false,prior=10:${OTGsnps} --resource dbsnp,known=true,training=false,truth=false,prior=7:${DBSNP138} --resource hapmap,known=false,training=true,truth=true,prior=15:${HAPMAP} --max-gaussians 6
echo "- END -"

touch step20.done

# -an "DP" # excluded from WES



