#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - VARIABILI FISSE - ###
variantdb=$1				#db name
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - mkdir FOLDER / make FILE - ###
mkdir ${lg}/${variantdb}
mkdir ${fol9}/${variantdb}/xSamplePassedVariantsIntervalFilteredVCFs_WholeGenes
#mkdir ${fol9}/${variantdb}/xSamplePassedVariantsIntervalFilteredVCFs_EXONSplus12
### - CODE - ###

echo " --- START PIPELINE ---"
echo

#Interval Filtered PASS variants selection
#pipe step 25
#IN sample-PASS-variants postVQSR, interval list OUT sample-Interval-Filtered-PASS-variants postVQSR ***Whole Genes /// SelectVariants
#IN sample-PASS-variants postVQSR, interval list OUT sample-Interval-Filtered-PASS-variants postVQSR ***Whole Exons + 12bp each side /// SelectVariants

echo "bash ${hs}/Chr2525.GATK4_step2525.sh ${variantdb}" | qsub -N G4s2525_${variantdb} -cwd -l h_vmem=25G -q all.q -hold_jid G4s2224_${variantdb} -o ${lg}/${variantdb}/g2525_${variantdb}.log -e ${lg}/${variantdb}/g2525_${variantdb}.error -m ea -M emmanouil.a@gmail.com

#echo "bash ${hs}/Chr2626.GATK4_step2626.sh ${variantdb}" | qsub -N G4s2626_${variantdb} -cwd -l h_vmem=25G -q all.q -hold_jid G4s2224_${variantdb} -o ${lg}/${variantdb}/g2626_${variantdb}.log -e ${lg}/${variantdb}/g2626_${variantdb}.error -m ea -M emmanouil.a@gmail.com

echo
echo " --- END PIPELINE ---"

exit



