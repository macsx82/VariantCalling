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
mkdir ${fol7}/${variantdb}
mkdir ${fol8}/${variantdb}
mkdir ${fol9}/${variantdb}
mkdir ${fol9}/${variantdb}/xSamplePassedVariantsVCFs
### - CODE - ###

echo " --- START PIPELINE ---"
echo

#GenomicsDBImport
#pipe step 13
#IN gCVF OUT gVCF-list /// find

echo "bash ${hs}/1313.GATK4_step1313.sh ${variantdb}" | qsub -N G4s1313_${variantdb} -cwd -l h_vmem=2G -q all.q -hold_jid G4s1212_* -o ${lg}/${variantdb}/g1313_${variantdb}.log -e ${lg}/${variantdb}/g1313_${variantdb}.error -m a -M emmanouil.a@gmail.com 

#GenomicsDBImport
#pipe step 14, job-array
#IN gCVF (gVCF-list) OUT gVCFDB /// GenomicsDBImport

while read -r f1 f2; do echo "bash ${hs}/1414.GATK4_step1414.sh ${variantdb} ${f1} ${f2}" | qsub -N G4s1414_${variantdb}_${f2} -cwd -l h_vmem=25G -q all.q -hold_jid G4s1313_${variantdb} -o ${lg}/${variantdb}/g1414_${variantdb}_${f2}.log -e ${lg}/${variantdb}/g1414_${variantdb}_${f2}.error -m a -M emmanouil.a@gmail.com; done < ${sorgILhg38Chr}

#GenotypeGVCFs
#pipe step 15, job-array
#IN gVCFDB OUT raw-VCFs /// GenotypeGVCFs

while read -r f1 f2; do echo "bash ${hs}/1515.GATK4_step1515.sh ${variantdb} ${f1} ${f2}" | qsub -N G4s1515_${variantdb}_${f2} -cwd -l h_vmem=25G -q all.q -hold_jid G4s1414_${variantdb}_* -o ${lg}/${variantdb}/g1515_${variantdb}_${f2}.log -e ${lg}/${variantdb}/g1515_${variantdb}_${f2}.error -m a -M emmanouil.a@gmail.com; done < ${sorgILhg38Chr}

#GenotypeGVCFs
#pipe step 16
#IN raw-VCFs OUT cohort raw-VCF /// GatherVcfs

echo "bash ${hs}/1616.GATK4_step1616.sh ${variantdb}" | qsub -N G4s1616_${variantdb} -cwd -l h_vmem=20G -q all.q -hold_jid G4s1515_${variantdb}_* -o ${lg}/${variantdb}/g1616_${variantdb}.log -e ${lg}/${variantdb}/g1616_${variantdb}.error -m ea -M emmanouil.a@gmail.com

#Pre-VQSR
#pipe step 17-18
#IN cohort raw-VCF OUT cohort Hard Filtered raw-VCF /// VariantFiltration
#IN cohort Hard Filtered raw-VCF OUT cohort Site Only raw-VCF /// MakeSitesOnlyVcf

echo "bash ${hs}/1718.GATK4_step1718.sh ${variantdb}" | qsub -N G4s1718_${variantdb} -cwd -l h_vmem=20G -q all.q -hold_jid G4s1616_${variantdb} -o ${lg}/${variantdb}/g1718_${variantdb}.log -e ${lg}/${variantdb}/g1718_${variantdb}.error -m a -M emmanouil.a@gmail.com

#VQSR
#pipe step 19
#IN Site cohort Site Only raw-VCF OUT indel tranches, indel recal /// VariantRecalibrator

echo "bash ${hs}/1919.GATK4_step1919.sh ${variantdb}" | qsub -N G4s1919_${variantdb} -cwd -l h_vmem=40G -q all.q -hold_jid G4s1718_${variantdb} -o ${lg}/${variantdb}/g1919_${variantdb}.log -e ${lg}/${variantdb}/g1919_${variantdb}.error -m a -M emmanouil.a@gmail.com

#VQSR
#pipe step 20
#IN Site cohort Site Only raw-VCF OUT snp tranches, snp recal /// VariantRecalibrator

echo "bash ${hs}/2020.GATK4_step2020.sh ${variantdb}" | qsub -N G4s2020_${variantdb} -cwd -l h_vmem=120G -q all.q -hold_jid G4s1718_${variantdb} -o ${lg}/${variantdb}/g2020_${variantdb}.log -e ${lg}/${variantdb}/g2020_${variantdb}.error -m a -M emmanouil.a@gmail.com

#VQSR
#pipe step 21
#IN Site cohort Site Only raw-VCF, tranche file, recal file OUT cohort VQSR vcf /// ApplyVQSR

echo "bash ${hs}/2121.GATK4_step2121.sh ${variantdb}" | qsub -N G4s2121_${variantdb} -cwd -l h_vmem=20G -q all.q -hold_jid G4s1919_${variantdb} -hold_jid G4s2020_${variantdb} -o ${lg}/${variantdb}/g2121_${variantdb}.log -e ${lg}/${variantdb}/g2121_${variantdb}.error -m ea -M emmanouil.a@gmail.com

#PASS variants selection
#pipe step 22-24
#IN cohort VQSR.vcf, cohort raw.vcf OUT pass.list, sample.list /// grep
#IN cohort raw.vcf, pass.list OUT cohort-PASS-variants postVQSR /// SelectVariants
#IN cohort-PASS-variants postVQSR, sample.list OUT per sample-PASS-variants postVQSR /// SelectVariants

echo "bash ${hs}/2224.GATK4_step2224.sh ${variantdb}" | qsub -N G4s2224_${variantdb} -cwd -l h_vmem=25G -q all.q -hold_jid G4s2121_${variantdb} -o ${lg}/${variantdb}/g2224_${variantdb}.log -e ${lg}/${variantdb}/g2224_${variantdb}.error -m ea -M emmanouil.a@gmail.com

echo
echo " --- END PIPELINE ---"

exit



