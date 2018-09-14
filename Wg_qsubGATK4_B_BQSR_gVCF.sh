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

#BQSR
#pipe step 6, job-array
#IN fBAM OUT conting-bqsrrd /// BaseRecalibrator

a_size=`wc -l /home/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_ID.intervals | cut -f 1 -d " "`; echo "/home/manolis/scripts/runner_job_array.sh -d /home/manolis/GATK4/germlineVariants/0.pipe/0606.GATK4_step0606.sh /home/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_ID.intervals ${SM}" | qsub -t 1-${a_size} -N G4s0606_${SM} -cwd -l h_vmem=20G -hold_jid G4s0305_${SM} -o ${lg}/"${SM}_logs"/g0606_${SM}_\$JOB_ID.\$TASK_ID.log -e ${lg}/"${SM}_logs"/g0606_${SM}_\$JOB_ID.\$TASK_ID.error -m a -M emmanouil.a@gmail.com

#BQSR
#pipe step 7-8
#IN conting-bqsrrd OUT bqsrrd /// GatherBQSRReports
#IN fBAM+bqsrrd OUT conting-bqsrrd /// ApplyBQSR, ValidateSamFile, flagstat, view

echo "bash ${hs}/0708.GATK4_step0708.sh ${SM}" | qsub -N G4s0708_${SM} -cwd -l h_vmem=20G -hold_jid G4s0606_${SM} -o ${lg}/"${SM}_logs"/g0708_${SM}.log -e ${lg}/"${SM}_logs"/g0708_${SM}.error -m a -M emmanouil.a@gmail.com

#HC
#pipe step 9, job-array
#IN bqsrrd OUT interval bqsrrd /// HaplotypeCaller

a_size=`wc -l /home/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_ID.intervals | cut -f 1 -d " "`; echo "/home/manolis/scripts/runner_job_array.sh -d /home/manolis/GATK4/germlineVariants/0.pipe/0909.GATK4_step0909.sh /home/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_ID.intervals ${SM}" | qsub -t 1-${a_size} -N G4s0909_${SM} -cwd -l h_vmem=20G -hold_jid G4s0708_${SM} -o ${lg}/"${SM}_logs"/g0909_${SM}_\$JOB_ID.\$TASK_ID.log -e ${lg}/"${SM}_logs"/g0909_${SM}_\$JOB_ID.\$TASK_ID.error -m a -M emmanouil.a@gmail.com

#HC
#pipe step 10-11
#IN conting-bqsrrd OUT gVCF /// MergeVcfs
#IN gVCF OUT fixed gVCF /// bcftools

echo "bash ${hs}/Wg1011.GATK4_step1011.sh ${SM}" | qsub -N G4s1011_${SM} -cwd -l h_vmem=20G -hold_jid G4s0909_${SM} -o ${lg}/"${SM}_logs"/g1011_${SM}.log -e ${lg}/"${SM}_logs"/g1011_${SM}.error -m a -M emmanouil.a@gmail.com

#gVCF check
#pipe step 12
#IN fixed gVCF OUT checked gVCF /// ValidateVariants

echo "${hs}/Wg1212.GATK4_step1212.sh ${SM}" | qsub -N G4s1212_${SM} -cwd -l h_vmem=20G -hold_jid G4s1011_${SM} -o ${lg}/"${SM}_logs"/g1212_${SM}.log -e ${lg}/"${SM}_logs"/g1212_${SM}.error -m ea -M emmanouil.a@gmail.com

echo
echo " --- END PIPELINE ---"

exit



