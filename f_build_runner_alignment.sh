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

case \${cluster_man} in
	BURLO )
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
	#pipe step 3 to 5
	#IN uBAM+bBAM OUT mBAM /// MergeBamAlignment, ValidateSamFile, flagstat, view
	#IN mBAM OUT mdBAM /// MarkDuplicates, ValidateSamFile, flagstat, view
	#IN mdBAM OUT fBAM /// SortSam, SetNmAndUqTags, ValidateSamFile, flagstat, view, sort, depth

	echo "bash \${hs}/0303.GATK4_step0303.sh \${param_file}" | qsub -N G4s0303_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0202_\${SM} -o \${lg}/\\\$JOB_ID_g0303_\${SM}.log -e \${lg}/\\\$JOB_ID_g0303_\${SM}.error -m ea -M \${mail} -q \${sge_q}
	echo "bash \${hs}/0404.GATK4_step0404.sh \${param_file}" | qsub -N G4s0404_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0303_\${SM} -o \${lg}/\\\$JOB_ID_g0404_\${SM}.log -e \${lg}/\\\$JOB_ID_g0404_\${SM}.error -m ea -M \${mail} -q \${sge_q}
	echo "bash \${hs}/0505.GATK4_step0505.sh \${param_file}" | qsub -N G4s0505_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0404_\${SM} -o \${lg}/\\\$JOB_ID_g0505_\${SM}.log -e \${lg}/\\\$JOB_ID_g0505_\${SM}.error -m ea -M \${mail} -q \${sge_q}

	;;
	CINECA )

	#Pre-processing
	#pipe step 1
	#IN val OUT uBAM /// FastqToSam, ValidateSamFile, flagsta, view

	jid_step_0101_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g0101_\${SM}.error -o \${lg}/%j_g0101_\${SM}.log --mem=\${sge_m} -J "G4s0101_\${SM}" --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/0101.GATK4_step0101.sh ${param_file})
	jid_step_0101=\$(echo \${jid_step_0101_m}| cut -f 4 -d " ")

	#Pre-processing
	#pipe step 2
	#IN uBAM OUT bBAM /// SamToFastq, ValidateSamFile, flagstat, view
	#We work straight wit fastq files
	jid_step_0202_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g0202_\${SM}.error -o \${lg}/%j_g0202_\${SM}.log --mem=\${sge_m} -J "G4s0202_\${SM}" --get-user-env -n \${thr} --mail-type END,FAIL --mail-user \${mail} \${hs}/0202.GATK4_step0202.sh ${param_file})
	jid_step_0202=\$(echo \${jid_step_0202_m}| cut -f 4 -d " ")

	#Pre-processing
	#pipe step 3 to 5
	#IN uBAM+bBAM OUT mBAM /// MergeBamAlignment, ValidateSamFile, flagstat, view
	#IN mBAM OUT mdBAM /// MarkDuplicates, ValidateSamFile, flagstat, view
	#IN mdBAM OUT fBAM /// SortSam, SetNmAndUqTags, ValidateSamFile, flagstat, view, sort, depth

	jid_step_0303_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g0303_\${SM}.error -o \${lg}/%j_g0303_\${SM}.log --mem=\${sge_m} -J "G4s0303_\${SM}" --dependency=afterok:\${jid_step_0202}:\${jid_step_0101} --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/0303.GATK4_step0303.sh ${param_file})
	jid_step_0303=\$(echo \${jid_step_0303_m}| cut -f 4 -d " ")

	#use sambamba for duplicate marking
	#jid_step_0404_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g0404_\${SM}.error -o \${lg}/%j_g0404_\${SM}.log --mem=\${sge_m} -J "G4s0404_\${SM}" --dependency=afterok:\${jid_step_0303} --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/0404.GATK4_step0404.sh ${param_file})
	jid_step_0404_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g0404_\${SM}.error -o \${lg}/%j_g0404_\${SM}.log --mem-per-cpu=\${sge_m_u} -J "G4s0404_\${SM}" --dependency=afterok:\${jid_step_0303} --get-user-env -n 24 --mail-type END,FAIL --mail-user \${mail} \${hs}/0404.GATK4_step0404.sh ${param_file})
	jid_step_0404=\$(echo \${jid_step_0404_m}| cut -f 4 -d " ")

	#in this last step we are using samtools to sort and than producing the cram file
	# jid_step_0505_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g0505_\${SM}.error -o \${lg}/%j_g0505_\${SM}.log --mem=\${sge_m} -J "G4s0505_\${SM}" --dependency=afterok:\${jid_step_0404} --get-user-env -n 30 --mail-type END,FAIL --mail-user \${mail} \${hs}/0505.GATK4_step0505.sh ${param_file})
	jid_step_0505_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g0505_\${SM}.error -o \${lg}/%j_g0505_\${SM}.log --mem-per-cpu=\${sge_m_u} -J "G4s0505_\${SM}" --dependency=afterok:\${jid_step_0404} --get-user-env -n 30 --mail-type END,FAIL --mail-user \${mail} \${hs}/0505.GATK4_step0505.sh ${param_file})
	jid_step_0505=\$(echo \${jid_step_0505_m}| cut -f 4 -d " ")

	#in this last step we are just validating and calculating stats and depth for our files, before BQSR
	jid_step_0505b_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g0505b_\${SM}.error -o \${lg}/%j_g0505b_\${SM}.log --mem=\${sge_m} -J "G4s0505b_\${SM}" --dependency=afterok:\${jid_step_0505} --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/0505b.GATK4_step0505.sh ${param_file})

	;;
esac

echo
echo " --- END PIPELINE ---"

exit

EOF

}

