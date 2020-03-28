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
mkdir -p \${lg}/\${variantdb}

### - CODE - ###

echo " --- START PIPELINE ---"
echo
case \${cluster_man} in
	BURLO )
		#GenomicsDBImport
		#pipe step 13
		#IN gCVF OUT gVCF-list /// find

		echo "bash \${hs}/1313.GATK4_step1313.sh \${param_file}" | qsub -N G4s1313_\${variantdb} -cwd -l h_vmem=2G -q \${sge_q} -hold_jid G4s1212_* -o \${lg}/\${variantdb}/g1313_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g1313_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail}

		#GenomicsDBImport
		#pipe step 14, job-array
		#IN gCVF (gVCF-list) OUT gVCFDB /// GenomicsDBImport
		#we need to split the interval file by 100 lines, but we need to do it on the fly
		#than we nedd to collect each interval file path in another file and run a job array of intervals
		#we should end up with a job array with ~2K tasks each with a file of 100 intervals
		mkdir -p \${tmp}/db_imp_int
		cd \${tmp}/db_imp_int

		split -a 4 --additional-suffix dbImp.intervals -d -l 100 \${vdb_interval}

		ls \${tmp}/db_imp_int/x*dbImp.intervals > \${tmp}/db_imp_int/ALL_dbImp.intervals

		# rsync -av -u -P R \${tmp}/db_imp_int ${USER}@${exec_host}:/.


		a_size=\`wc -l \${tmp}/db_imp_int/ALL_dbImp.intervals | cut -f 1 -d " "\`; echo "\${hs}/runner_job_array.sh -s \${hs}/1414.GATK4_step1414.sh \${tmp}/db_imp_int/ALL_dbImp.intervals \${param_file}" | qsub -t 1-\${a_size} -tc 15 -N G4s1414_\${variantdb}_ -cwd -l h_vmem=\${sge_m_dbi} -hold_jid G4s1313_\${variantdb} -o \${lg}/\${variantdb}/g1414_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/\${variantdb}/g1414_\\\$JOB_ID.\\\$TASK_ID.error -m ea -M \${mail} -q \${sge_q}


		#GenotypeGVCFs
		#pipe step 15, job-array
		#IN gVCFDB OUT raw-VCFs /// GenotypeGVCFs
		a_size=\`wc -l \${tmp}/db_imp_int/ALL_dbImp.intervals | cut -f 1 -d " "\`; echo "\${hs}/runner_job_array.sh -s \${hs}/1515.GATK4_step1515.sh \${tmp}/db_imp_int/ALL_dbImp.intervals \${param_file}" | qsub -t 1-\${a_size} -tc 15 -N G4s1515_\${variantdb}_ -cwd -l h_vmem=\${sge_m_dbi} -hold_jid G4s1414_\${variantdb}_* -o \${lg}/\${variantdb}/g1515_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/\${variantdb}/g1515_\\\$JOB_ID.\\\$TASK_ID.error -m ea -M \${mail} -q \${sge_q}


		#GenotypeGVCFs
		#pipe step 16
		#IN raw-VCFs OUT cohort raw-VCF /// GatherVcfs

		echo "bash  \${hs}/1616.GATK4_step1616.sh \${param_file}" | qsub -N G4s1616_\${variantdb} -hold_jid G4s1515_\${variantdb}_* -o \${lg}/\${variantdb}/g1616_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g1616_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m} -q \${sge_q}
	;;
	CINECA )
		#GenomicsDBImport
		#pipe step 13
		#IN gCVF OUT gVCF-list /// find
		case \${pool_mode} in
            CHROM )
                #this should run as a job array or submit as many jobs as the chromosomes
                #we have access to the param file variables, so we can create all oputput folders once
                for chr in \${chr_pool[@]}
                do
                    mkdir -p \${fol7}/\${variantdb}_\${chr}
                done

                jid_step_1313_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g1313_\${SM}.error -o \${lg}/%j_g1313_\${SM}.log --mem=\${sge_m} -J "G4s1313_\${SM}" --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/1313.GATK4_step1313.sh \${param_file})
                jid_step_1313=\$(echo \${jid_step_1011_m}| cut -f 4 -d " ")
                
                #gVCF check
                #pipe step 12
                #IN fixed gVCF OUT checked gVCF /// ValidateVariants
                jid_step_1212_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g1212_\${SM}.error -o \${lg}/%j_g1212_\${SM}.log --mem=\${sge_m} -J "G4s1212_\${SM}" --dependency=afterok:\${jid_step_1011} --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/Chr1212.GATK4_step1212.sh \${param_file})
                jid_step_1212=\$(echo \${jid_step_1212_m}| cut -f 4 -d " ")
				
				#GenomicsDBImport
				#pipe step 14, job-array
				#IN gCVF (gVCF-list) OUT gVCFDB /// GenomicsDBImport
				#We will need to work with a job array by chromosome
				#we will have one array with 25 tasks, each passing a file containing intervals for DBimport
				size=\$(wc -l \${vdb_interval}|cut -f 1 -d " ")
				jid_step_1414_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --array=1-\${size} --time=24:00:00 -e \${lg}/%A_g1414_\${SM}_%a.error -o \${lg}/%A_g1414_\${SM}_%a.log --mem=\${sge_m} -J "G4s1414_\${SM}" --dependency=afterok:\${jid_step_1313} --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/runner_job_array_CINECA.sh -s \${hs}/1414.GATK4_step1414.sh \${vdb_interval} \${param_file}
                jid_step_1414=\$(echo \${jid_step_1414_m}| cut -f 4 -d " ")



            ;;
            SAMPLE)
                jid_step_1011_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g1011_\${SM}.error -o \${lg}/%j_g1011_\${SM}.log --mem=\${sge_m} -J "G4s1011_\${SM}" --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/sample1011.GATK4_step1011.sh \${param_file})
                jid_step_1011=\$(echo \${jid_step_1011_m}| cut -f 4 -d " ")
                
                #gVCF check
                #pipe step 12
                #IN fixed gVCF OUT checked gVCF /// ValidateVariants
                jid_step_1212_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/%j_g1212_\${SM}.error -o \${lg}/%j_g1212_\${SM}.log --mem=\${sge_m} -J "G4s1212_\${SM}" --dependency=afterok:\${jid_step_1011} --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/sample1212.GATK4_step1212.sh \${param_file})
                jid_step_1212=\$(echo \${jid_step_1212_m}| cut -f 4 -d " ")
            ;;
        esac




		#GenotypeGVCFs
		#pipe step 15, job-array
		#IN gVCFDB OUT raw-VCFs /// GenotypeGVCFs
		a_size=\`wc -l \${tmp}/db_imp_int/ALL_dbImp.intervals | cut -f 1 -d " "\`; echo "\${hs}/runner_job_array.sh -s \${hs}/1515.GATK4_step1515.sh \${tmp}/db_imp_int/ALL_dbImp.intervals \${param_file}" | qsub -t 1-\${a_size} -tc 15 -N G4s1515_\${variantdb}_ -cwd -l h_vmem=\${sge_m_dbi} -hold_jid G4s1414_\${variantdb}_* -o \${lg}/\${variantdb}/g1515_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/\${variantdb}/g1515_\\\$JOB_ID.\\\$TASK_ID.error -m ea -M \${mail} -q \${sge_q}


		#GenotypeGVCFs
		#pipe step 16
		#IN raw-VCFs OUT cohort raw-VCF /// GatherVcfs

		echo "bash  \${hs}/1616.GATK4_step1616.sh \${param_file}" | qsub -N G4s1616_\${variantdb} -hold_jid G4s1515_\${variantdb}_* -o \${lg}/\${variantdb}/g1616_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g1616_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m} -q \${sge_q}
	;;
esac
echo
echo " --- END PIPELINE ---"

exit


EOF

}
