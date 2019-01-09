function build_runner_VQSR() {
param_file=$1

cat << EOF
#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=\$(date '+%Y/%m/%d %H:%M:%S')
echo "\$dt1"
echo

### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1
source ${param_file}
#source functions file
source \${hs}/pipeline_functions.sh

#log folders creation
mkdir -p \${lg}

### - mkdir FOLDER / make FILE - ###
mkdir -p \${lg}/\${variantdb}
mkdir -p \${fol7}/\${variantdb}
mkdir -p \${fol8}/\${variantdb}
mkdir -p \${fol9}/\${variantdb}
mkdir -p \${fol9}/\${variantdb}/xSamplePassedVariantsVCFs
### - CODE - ###

echo " --- START PIPELINE ---"
echo

#Pre-VQSR
#pipe step 17-18
#IN cohort raw-VCF OUT cohort Hard Filtered raw-VCF /// VariantFiltration
#IN cohort Hard Filtered raw-VCF OUT cohort Site Only raw-VCF /// MakeSitesOnlyVcf

echo "bash \${hs}/1718.GATK4_step1718.sh \${param_file}" | qsub -N G4s1718_\${variantdb} -hold_jid G4s1616_\${variantdb} -o \${lg}/\${variantdb}/g1718_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g1718_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m} -q \${sge_q} 

#VQSR
#pipe step 19
#IN Site cohort Site Only raw-VCF OUT indel tranches, indel recal /// VariantRecalibrator

echo "bash \${hs}/1919.GATK4_step1919.sh \${param_file}" | qsub -N G4s1919_\${variantdb} -hold_jid G4s1718_\${variantdb} -o \${lg}/\${variantdb}/g1919_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g1919_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m_j3} -q \${sge_q} 

#VQSR
#pipe step 20
#IN Site cohort Site Only raw-VCF OUT snp tranches, snp recal /// VariantRecalibrator

echo "bash \${hs}/2020.GATK4_step2020.sh \${param_file}" | qsub -N G4s2020_\${variantdb} -hold_jid G4s1718_\${variantdb} -o \${lg}/\${variantdb}/g2020_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g2020_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m_j4} -q \${sge_q} 

echo " --- END PIPELINE ---"

exit


EOF

}
