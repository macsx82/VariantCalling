#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - VARIABILI FISSE - ###
variantdb=$1				#db name
SO="${variantdb}_rawHFSO.vcf"
iVR="${variantdb}_rawHFSO-iVR.vcf"
tri="${variantdb}_indel.tranches"
mode_I=INDEL
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

#19
echo
cd ${fol8}/${variantdb}/
echo "> Indel Variant Recalibrator"
${GATK4} --java-options ${java_opt3x} VariantRecalibrator -V ${SO} -O ${iVR} --tranches-file ${tri} --trust-all-polymorphic -tranche "100.0" -tranche "99.95" -tranche "99.9" -tranche "99.5" -tranche "99.0" -tranche "97.0" -tranche "96.0" -tranche "95.0" -tranche "94.0" -tranche "93.5" -tranche "93.0" -tranche "92.0" -tranche "91.0" -tranche "90.0" -an "FS" -an "ReadPosRankSum" -an "MQRankSum" -an "QD" -an "SOR" -mode ${mode_I} --max-gaussians 4 -resource mills,known=false,training=true,truth=true,prior=12:${OTGindels} -resource axiomPoly,known=false,training=true,truth=false,prior=10:${AXIOM} -resource dbsnp,known=true,training=false,truth=false,prior=2:${DBSNP138} 
echo "- END -"

exit

# -an "DP" # excluded from WES



