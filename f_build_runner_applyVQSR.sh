function build_runner_applyVQSR() {
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
mkdir \${lg}/\${variantdb}
mkdir \${fol7}/\${variantdb}
mkdir \${fol8}/\${variantdb}
mkdir \${fol9}/\${variantdb}
mkdir \${fol9}/\${variantdb}/xSamplePassedVariantsVCFs
### - CODE - ###

echo " --- START PIPELINE ---"
echo

#Apply VQSR
#IN Site cohort Site Only raw-VCF, tranche file, recal file OUT cohort VQSR vcf 

echo "bash \${hs}/2121.GATK4_step2121.sh \${param_file}" | qsub -N G4s2121_\${variantdb} -hold_jid G4s1919_\${variantdb} -hold_jid G4s2020_\${variantdb} -o \${lg}/\${variantdb}/g2121_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g2121_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m_j1} -q \${sge_q} 

echo
echo " --- END PIPELINE ---"

exit


EOF

}
