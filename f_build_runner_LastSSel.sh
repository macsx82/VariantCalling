function build_runner_LastSSel() {
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
### - CODE - ###

echo " --- START PIPELINE ---"
echo
case \${cluster_man} in
	BURLO )
	#PASS variants selection
	#pipe step 22-24
	#IN cohort VQSR.vcf, cohort raw.vcf OUT pass.list, sample.list /// grep
	#IN cohort raw.vcf, pass.list OUT cohort-PASS-variants postVQSR /// SelectVariants
	#IN cohort-PASS-variants postVQSR, sample.list OUT per sample-PASS-variants postVQSR /// SelectVariants
	for chr in \${chr_pool[@]}
    do
		#echo "bash \${hs}/2224.GATK4_step2224.sh \${param_file}" | qsub -N G4s2224_\${variantdb} -hold_jid G4s2121_\${variantdb} -o \${lg}/\${variantdb}/g2224_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g2224_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m} -q \${sge_q} 
		echo "bash \${hs}/2224.GATK4_step2224.sh \${param_file} \${chr}" | qsub -N G4s2224_\${variantdb}_\${chr} -o \${lg}/\${variantdb}/g2224_\${variantdb}_\${chr}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g2224_\${variantdb}_\${chr}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m} -q \${sge_q} 

    done

	#Interval Filtered PASS variants selection
	#pipe step 25
	#IN sample-PASS-variants postVQSR, interval list OUT sample-Interval-Filtered-PASS-variants postVQSR ***Whole Genes /// SelectVariants
	#IN sample-PASS-variants postVQSR, interval list OUT sample-Interval-Filtered-PASS-variants postVQSR ***Whole Exons + 12bp each side /// SelectVariants
	# No strict need for this
	#echo "bash \${hs}/Chr2525.GATK4_step2525.sh \${param_file}" | qsub -N G4s2525_\${variantdb} -hold_jid G4s2224_\${variantdb} -o \${lg}/\${variantdb}/g2525_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g2525_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m} -q \${sge_q} 
	;;
	CINECA )
	#PASS variants selection
	#pipe step 22-24
	#IN cohort VQSR.vcf, cohort raw.vcf OUT pass.list, sample.list /// grep
	#IN cohort raw.vcf, pass.list OUT cohort-PASS-variants postVQSR /// SelectVariants
	#IN cohort-PASS-variants postVQSR, sample.list OUT per sample-PASS-variants postVQSR /// SelectVariants
	jid_step_2224_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/g2224_%j.error -o \${lg}/g2224_%j.log --mem=\${sge_m} -J "G4s2224_\${variantdb}" --dependency=afterok:\${jid_step_2121} --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/2224.GATK4_step2224.sh \${param_file})
	jid_step_2224=\$(echo \${jid_step_2224_m}| cut -f 4 -d " ")

	;;
esac


echo
echo " --- END PIPELINE ---"

exit


EOF

}

