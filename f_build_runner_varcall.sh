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


case \${cluster_man} in
    BURLO )
        if [[ \${split_interval} -eq 0 ]]; then
            if [[ \${job_a} -eq 1 ]]; then
                #Normal job array
                a_size=\`wc -l \${vcall_interval} | cut -f 1 -d " "\`; echo "\${hs}/runner_job_array.sh -s \${hs}/0909.GATK4_step0909.sh \${vcall_interval} \${param_file}" | qsub -t 1-\${a_size} -N G4s0909_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0708_\${SM} -o \${lg}/g0909_\${SM}_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/g0909_\${SM}_\\\$JOB_ID.\\\$TASK_ID.error -q \${sge_q_vcall}
            else
                echo "\${hs}/0909.GATK4_step0909.sh \${vcall_interval} \${param_file}" | qsub -N G4s0909_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0708_\${SM} -o \${lg}/g0909_\${SM}_\\\$JOB_ID.log -e \${lg}/g0909_\${SM}_\\\$JOB_ID.error -q \${sge_q_vcall}
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
                    a_size=\`wc -l \${int_file} | cut -f 1 -d " "\`; echo "\${hs}/runner_job_array.sh -s \${hs}/0909.GATK4_step0909.sh \${int_file} \${param_file}" | qsub -t 1-\${a_size} -N G4s0909_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0708_\${SM} -o \${lg}/g0909_\${SM}_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/g0909_\${SM}_\\\$JOB_ID.\\\$TASK_ID.error -q \${sge_q_vcall}
                else
                    echo "\${hs}/0909.GATK4_step0909.sh \${int_file} \${param_file}" | qsub -N G4s0909_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0708_\${SM} -o \${lg}/g0909_\${SM}_\\\$JOB_ID.log -e \${lg}/g0909_\${SM}_\\\$JOB_ID.error -q \${sge_q_vcall}
                fi
            done
        fi
    ;;
    CINECA )
        if [[ \${split_interval} -eq 0 ]]; then
            if [[ \${job_a} -eq 1 ]]; then
                #Normal job array
                echo "Generate a job array submission.."
                size=\`wc -l \${vcall_interval}|cut -f 1 -d " "\`;jid_step_0909_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --array=1-\$[size] --time=24:00:00 -e \${lg}/%A_%a_g0909_\${SM}.error -o \${lg}/%A_%a_g0909_\${SM}.log --mem=\${sge_m} -J "G4s0909_\${SM}" --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} /galileo/home/userexternal/mcocca00/scripts/bash_scripts/ja_runner_par_CINECA.sh -s \${hs}/0909.GATK4_step0909.sh \${vcall_interval} \${param_file})
            else
                echo "Whole interval file option..."
                jid_step_0909_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g0909_\${SM}.error -o \${lg}/%j_g0909_\${SM}.log --mem=\${sge_m} -J "G4s0909_\${SM}" --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/0909.GATK4_step0909.sh \${vcall_interval} \${param_file})
            fi
            jid_step_0909=\$(echo \${jid_step_0909_m}| cut -f 4 -d " ")
        else
            #we need to split the interval file by split_interval lines and run n job arrays
            echo "We will split the interval according to the parameter file data..."
            #mkdir -p \${tmp}/call_int
            #cd \${tmp}/call_int
            #split -a 3 --additional-suffix call.intervals -d -l \${split_interval} \${vcall_interval}

            #rsync -av -u -P R \${tmp}/call_int ${USER}@${exec_host}:/.

            #for int_file in \${tmp}/call_int/x*call.intervals
            #do
            #    if [[ \${job_a} -eq 1 ]]; then
            #        #Normal job array
            #        echo "Generate a job array submission.."
            #        #a_size=\`wc -l \${int_file} | cut -f 1 -d " "\`; echo "\${hs}/runner_job_array.sh -s \${hs}/0909.GATK4_step0909.sh \${int_file} \${param_file}" | qsub -t 1-\${a_size} -N G4s0909_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0708_\${SM} -o \${lg}/g0909_\${SM}_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/g0909_\${SM}_\\\$JOB_ID.\\\$TASK_ID.error -q \${sge_q_vcall}
            #    else
            #        echo "Whole interval file option..."
            #        jid_step_0909_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g0909_\${SM}.error -o \${lg}/%j_g0909_\${SM}.log --mem=\${sge_m} -J "G4s0909_\${SM}" --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/0909.GATK4_step0909.sh \${int_file} \${param_file})
            #        jid_step_0909=\$(echo \${jid_step_0909_m}| cut -f 4 -d " ")
            #    fi
            #done
        fi
        
    ;;
esac
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
mkdir -p \${lg} \${fol6_link}

### - CODE - ###

echo " --- START PIPELINE ---"
echo


case \${cluster_man} in
    BURLO )
        #HC
        #pipe step 10-11
        #IN conting-bqsrrd OUT gVCF /// MergeVcfs
        #IN gVCF OUT fixed gVCF /// bcftools

        echo "bash \${hs}/Chr1011.GATK4_step1011.sh \${param_file}" | qsub -N G4s1011_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0909_\${SM}* -o \${lg}/g1011_\\\$JOB_ID_\${SM}.log -e \${lg}/g1011_\\\$JOB_ID_\${SM}.error -m ae -M \${mail} -q \${sge_q_vcall}

        #gVCF check
        #pipe step 12
        #IN fixed gVCF OUT checked gVCF /// ValidateVariants

        echo "\${hs}/Chr1212.GATK4_step1212.sh \${param_file}" | qsub -N G4s1212_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s1011_\${SM} -o \${lg}/g1212_\\\$JOB_ID_\${SM}.log -e \${lg}/g1212_\\\$JOB_ID_\${SM}.error -m ea -M \${mail} -q \${sge_q_vcall}
    ;;
    CINECA )
        #HC
        #pipe step 10-11
        #IN conting-bqsrrd OUT gVCF /// MergeVcfs
        #IN gVCF OUT fixed gVCF /// bcftools
        jid_step_1011_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g1011_\${SM}.error -o \${lg}/%j_g1011_\${SM}.log --mem=\${sge_m} -J "G4s1011_\${SM}" --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/Chr1011.GATK4_step1011.sh \${param_file})
        jid_step_1011=\$(echo \${jid_step_1011_m}| cut -f 4 -d " ")
        
        #gVCF check
        #pipe step 12
        #IN fixed gVCF OUT checked gVCF /// ValidateVariants
        jid_step_1212_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g1212_\${SM}.error -o \${lg}/%j_g1212_\${SM}.log --mem=\${sge_m} -J "G4s1212_\${SM}" --dependency=afterok:\${jid_step_1011} --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/Chr1212.GATK4_step1212.sh \${param_file})
        jid_step_1212=\$(echo \${jid_step_1212_m}| cut -f 4 -d " ")

    ;;
esac

echo
echo " --- END PIPELINE ---"

exit

EOF

}