function build_runner_VarCall(){
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

#HC
#pipe step 9, job-array
#IN bqsrrd OUT interval bqsrrd /// HaplotypeCaller


if [[ \${split_interval} -eq 0 ]]; then
    if [[ \${job_a} -eq 1 ]]; then
        #Normal job array
        a_size=\`wc -l \${vcall_interval} | cut -f 1 -d " "\`; echo "\${hs}/runner_job_array.sh -d \${hs}/0909.GATK4_step0909.sh \${vcall_interval} \${param_file}" | qsub -t 1-\${a_size} -N G4s0909_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0708_\${SM} -o \${lg}/g0909_\${SM}_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/g0909_\${SM}_\\\$JOB_ID.\\\$TASK_ID.error -q \${sge_q_vcall}
    else
        echo "\${hs}/0909.GATK4_step0909.sh whole_interval \${vcall_interval} \${param_file}" | qsub -N G4s0909_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0708_\${SM} -o \${lg}/g0909_\${SM}_\\\$JOB_ID.log -e \${lg}/g0909_\${SM}_\\\$JOB_ID.error -q \${sge_q_vcall}
    fi
else
    #we need to split the interval file by split_interval lines and run n job arrays
    mkdir -p \${tmp}/call_int
    cd \${tmp}/call_int
    split -a 3 --additional-suffix call.intervals -d -l \${split_interval} \${vcall_interval}

    rsync -av -u -P R \${tmp}/call_int ${USER}@${exec_host}:/.

    for int_file in \${tmp}/call_int/x*call.intervals
    do
        if [[ \${job_a} -eq 1 ]]; then
            #Normal job array
            a_size=\`wc -l \${int_file} | cut -f 1 -d " "\`; echo "\${hs}/runner_job_array.sh -d \${hs}/0909.GATK4_step0909.sh \${int_file} \${param_file}" | qsub -t 1-\${a_size} -N G4s0909_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0708_\${SM} -o \${lg}/g0909_\${SM}_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/g0909_\${SM}_\\\$JOB_ID.\\\$TASK_ID.error -q \${sge_q_vcall}
        else
            echo "\${hs}/0909.GATK4_step0909.sh whole_interval \${int_file} \${param_file}" | qsub -N G4s0909_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0708_\${SM} -o \${lg}/g0909_\${SM}_\\\$JOB_ID.log -e \${lg}/g0909_\${SM}_\\\$JOB_ID.error -q \${sge_q_vcall}
        fi
    done
fi

cd \`dirname $0\`

echo
echo " --- END PIPELINE ---"

exit


EOF

}

function build_runner_post_VarCall(){
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

#HC
#pipe step 10-11
#IN conting-bqsrrd OUT gVCF /// MergeVcfs
#IN gVCF OUT fixed gVCF /// bcftools

echo "bash \${hs}/Chr1011.GATK4_step1011.sh \${param_file}" | qsub -N G4s1011_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0909_\${SM}* -o \${lg}/g1011_\\\$JOB_ID_\${SM}.log -e \${lg}/g1011_\\\$JOB_ID_\${SM}.error -m ae -M \${mail} -q \${sge_q_vcall}

#gVCF check
#pipe step 12
#IN fixed gVCF OUT checked gVCF /// ValidateVariants

echo "\${hs}/Chr1212.GATK4_step1212.sh \${param_file}" | qsub -N G4s1212_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s1011_\${SM} -o \${lg}/g1212_\\\$JOB_ID_\${SM}.log -e \${lg}/g1212_\\\$JOB_ID_\${SM}.error -m ea -M \${mail} -q \${sge_q_vcall}

echo
echo " --- END PIPELINE ---"

exit

EOF

}