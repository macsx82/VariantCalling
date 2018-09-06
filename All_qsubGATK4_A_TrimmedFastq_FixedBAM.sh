#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - VARIABILI FISSE - ###
SM=$1					#sample name
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - mkdir FOLDER / make FILE - ###
mkdir ${lg}/"${SM}_logs"
### - CODE - ###

echo " --- START PIPELINE ---"
echo

#Pre-processing
#pipe step 1
#IN val OUT uBAM /// FastqToSam, ValidateSamFile, flagsta, view

echo "bash ${hs}/0101.GATK4_step0101.sh ${SM}" | qsub -N G4s0101_${SM} -cwd -l h_vmem=30G -o ${lg}/"${SM}_logs"/g0101_${SM}.log -e ${lg}/"${SM}_logs"/g0101_${SM}.error -m a -M emmanouil.a@gmail.com

#Pre-processing
#pipe step 2
#IN uBAM OUT bBAM /// SamToFastq, ValidateSamFile, flagstat, view

echo "bash ${hs}/0202.GATK4_step0202.sh ${SM}" | qsub -N G4s0202_${SM} -cwd -l h_vmem=30G -pe orte 16 -hold_jid G4s0101_${SM} -o ${lg}/"${SM}_logs"/g0202_${SM}.log -e ${lg}/"${SM}_logs"/g0202_${SM}.error -m a -M emmanouil.a@gmail.com

#Pre-processing
#pipe step 3-5
#IN uBAM+bBAM OUT mBAM /// MergeBamAlignment, ValidateSamFile, flagstat, view
#IN mBAM OUT mdBAM /// MarkDuplicates, ValidateSamFile, flagstat, view
#IN mdBAM OUT fBAM /// SortSam, SetNmAndUqTags, ValidateSamFile, flagstat, view, sort, depth

echo "bash ${hs}/0305.GATK4_step0305.sh ${SM}" | qsub -N G4s0305_${SM} -cwd -l h_vmem=30G -hold_jid G4s0202_${SM} -o ${lg}/"${SM}_logs"/g0305_${SM}.log -e ${lg}/"${SM}_logs"/g0305_${SM}.error -m ea -M emmanouil.a@gmail.com

echo
echo " --- END PIPELINE ---"

exit



