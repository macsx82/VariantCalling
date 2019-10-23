function build_runner_BQSR(){
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


case \${cluster_man} in
	BURLO )
		#BQSR
		#pipe step 6, job-array
		#IN fBAM OUT conting-bqsrrd /// BaseRecalibrator

		if [[ \${whole_genome} -eq 1 ]]; then
		    #statements
		    echo "\${hs}/0606.GATK4_step0606.sh whole_genome_mode \${bqsr_intervals} \${param_file}" | qsub -N G4s0606_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0305_\${SM} -o \${lg}/g0606_\${SM}_\\\$JOB_ID.log -e \${lg}/g0606_\${SM}_\\\$JOB_ID.error -m ea -M \${mail} -q \${sge_q}
		else
		    a_size=\`wc -l \${bqsr_intervals} | cut -f 1 -d " "\`; echo "\${hs}/runner_job_array.sh -d \${hs}/0606.GATK4_step0606.sh \${bqsr_intervals} \${param_file}" | qsub -t 1-\${a_size} -N G4s0606_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0305_\${SM} -o \${lg}/g0606_\${SM}_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/g0606_\${SM}_\\\$JOB_ID.\\\$TASK_ID.error -m ea -M \${mail} -q \${sge_q}
		fi

		#BQSR
		#pipe step 7-8
		#IN conting-bqsrrd OUT bqsrrd /// GatherBQSRReports
		#IN fBAM+bqsrrd OUT conting-bqsrrd /// ApplyBQSR, ValidateSamFile, flagstat, view

		echo "bash \${hs}/0708.GATK4_step0708.sh \${param_file}" | qsub -N G4s0708_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0606_\${SM} -o \${lg}/g0708_\\\$JOB_ID_\${SM}.log -e \${lg}/g0708_\\\$JOB_ID_\${SM}.error -m ea -M \${mail} -q \${sge_q}
	;;
	CINECA )
		#BQSR
		#pipe step 6, job-array
		#IN fBAM OUT conting-bqsrrd /// BaseRecalibrator

		if [[ \${whole_genome} -eq 1 ]]; then
		    #statements
		    jid_step_0606_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g0606_\${SM}.error -o \${lg}/%j_g0606_\${SM}.log --mem=\${seq_m} -J "G4s0606_\${SM}" --get-user-env -n 10 --mail-type END,FAIL --mail-user \${mail} \${hs}/0606.GATK4_step0606.sh \${param_file})
			jid_step_0606=\$(echo \${jid_step_0606_m}| cut -f 4 -d " ")
		    
		else
		    #a_size=\`wc -l \${bqsr_intervals} | cut -f 1 -d " "\`; echo "\${hs}/runner_job_array.sh -d \${hs}/0606.GATK4_step0606.sh \${bqsr_intervals} \${param_file}" | qsub -t 1-\${a_size} -N G4s0606_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0305_\${SM} -o \${lg}/g0606_\${SM}_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/g0606_\${SM}_\\\$JOB_ID.\\\$TASK_ID.error -m ea -M \${mail} -q \${sge_q}
		fi

		#BQSR
		#pipe step 7-8
		#IN conting-bqsrrd OUT bqsrrd /// GatherBQSRReports
		#IN fBAM+bqsrrd OUT conting-bqsrrd /// ApplyBQSR, ValidateSamFile, flagstat, view
		jid_step_0708_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g0708_\${SM}.error -o \${lg}/%j_g0708_\${SM}.log --mem=\${seq_m} -J "G4s0708_\${SM}" --dependency=afterok:\${jid_step_0606} --get-user-env -n \${thr} --mail-type END,FAIL --mail-user \${mail} \${hs}/0708.GATK4_step0708.sh \${param_file})

	;;
esac


echo
echo " --- END PIPELINE ---"

exit


EOF
}
