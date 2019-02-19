function build_runner_alignment(){
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

### - CODE - ###

echo " --- START PIPELINE ---"
echo

#Pre-processing
#pipe step 1
#IN val OUT uBAM /// FastqToSam, ValidateSamFile, flagsta, view

echo "bash \${hs}/0101.GATK4_step0101.sh \${param_file}" | qsub -N G4s0101_\${SM} -cwd -l h_vmem=\${sge_m} -o \${lg}/\\\$JOB_ID_g0101_\${SM}.log -e \${lg}/\\\$JOB_ID_g0101_\${SM}.error -m a -M \${mail} -q \${sge_q}

#Pre-processing
#pipe step 2
#IN uBAM OUT bBAM /// SamToFastq, ValidateSamFile, flagstat, view

# echo "bash \${hs}/0202.GATK4_step0202.sh \${param_file}" | qsub -N G4s0202_\${SM} -cwd -l h_vmem=\${sge_m} -pe \${sge_pe} \${thr} -hold_jid G4s0101_\${SM} -o \${lg}/\\\$JOB_ID_g0202_\${SM}.log -e \${lg}/\\\$JOB_ID_g0202_\${SM}.error -m a -M \${mail} -q \${sge_q}
echo "bash \${hs}/0202.GATK4_step0202.sh \${param_file}" | qsub -N G4s0202_\${SM} -cwd -l h_vmem=\${sge_m} -pe \${sge_pe} \${thr} -o \${lg}/\\\$JOB_ID_g0202_\${SM}.log -e \${lg}/\\\$JOB_ID_g0202_\${SM}.error -m a -M \${mail} -q \${sge_q}

#Pre-processing
#pipe step 3-5
#IN uBAM+bBAM OUT mBAM /// MergeBamAlignment, ValidateSamFile, flagstat, view
#IN mBAM OUT mdBAM /// MarkDuplicates, ValidateSamFile, flagstat, view
#IN mdBAM OUT fBAM /// SortSam, SetNmAndUqTags, ValidateSamFile, flagstat, view, sort, depth

echo "bash \${hs}/0305.GATK4_step0305.sh \${param_file}" | qsub -N G4s0305_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0202_\${SM} -o \${lg}/\\\$JOB_ID_g0305_\${SM}.log -e \${lg}/\\\$JOB_ID_g0305_\${SM}.error -m ea -M \${mail} -q \${sge_q}

echo
echo " --- END PIPELINE ---"

exit

EOF

}