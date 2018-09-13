function build_runner_GDBIMP() {
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

#GenomicsDBImport
#pipe step 13
#IN gCVF OUT gVCF-list /// find

echo "bash \${hs}/1313.GATK4_step1313.sh \${param_file}" | qsub -N G4s1313_\${variantdb} -cwd -l h_vmem=2G -q \${sge_q} -hold_jid G4s1212_* -o \${lg}/\${variantdb}/g1313_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g1313_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail}

#GenomicsDBImport
#pipe step 14, job-array
#IN gCVF (gVCF-list) OUT gVCFDB /// GenomicsDBImport

a_size=\`wc -l \${vdb_interval} | cut -f 1 -d " "\`; echo "\${hs}/runner_job_array.sh -d \${hs}/1414.GATK4_step1414.sh \${vdb_interval} \${param_file}" | qsub -t 1-\${a_size} -N G4s1414_\${variantdb}_ -cwd -l h_vmem=\${sge_m_dbi} -hold_jid G4s1313_\${variantdb} -o \${lg}/\${variantdb}/g1414_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/\${variantdb}/g1414_\\\$JOB_ID.\\\$TASK_ID.error -m ea -M \${mail} -q \${sge_q}


#GenotypeGVCFs
#pipe step 15, job-array
#IN gVCFDB OUT raw-VCFs /// GenotypeGVCFs
a_size=\`wc -l \${vdb_interval} | cut -f 1 -d " "\`; echo "\${hs}/runner_job_array.sh -d \${hs}/1515.GATK4_step1515.sh \${vdb_interval} \${param_file}" | qsub -t 1-\${a_size} -N G4s1414_\${variantdb}_ -cwd -l h_vmem=\${sge_m_dbi} -hold_jid G4s1414_\${variantdb} -o \${lg}/\${variantdb}/g1515_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/\${variantdb}/g1515_\\\$JOB_ID.\\\$TASK_ID.error -m ea -M \${mail} -q \${sge_q}


#GenotypeGVCFs
#pipe step 16
#IN raw-VCFs OUT cohort raw-VCF /// GatherVcfs

echo "bash  \${hs}/1616.GATK4_step1616.sh \${param_file}" | qsub -N G4s1616_\${variantdb} -hold_jid G4s1515_\${variantdb}_* -o \${lg}/\${variantdb}/g1616_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g1616_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m} -q \${sge_q}

echo
echo " --- END PIPELINE ---"

exit


EOF

}
