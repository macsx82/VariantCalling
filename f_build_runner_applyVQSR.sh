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
mkdir -p \${lg}/\${variantdb}
mkdir -p \${fol7}/\${variantdb}
mkdir -p \${fol8}/\${variantdb}
mkdir -p \${fol9}/\${variantdb}
### - CODE - ###

echo " --- START PIPELINE ---"
echo

case \${cluster_man} in
	BURLO )
		#Apply VQSR
		#IN Site cohort Site Only raw-VCF, tranche file, recal file OUT cohort VQSR vcf 

		echo "bash \${hs}/2121.GATK4_step2121.sh \${param_file}" | qsub -N G4s2121_\${variantdb} -hold_jid G4s1919_\${variantdb} -hold_jid G4s2020_\${variantdb} -o \${lg}/\${variantdb}/g2121_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g2121_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m_j1} -q \${sge_q} 
	;;
	CINECA )
		#Apply VQSR
		#IN Site cohort Site Only raw-VCF, tranche file, recal file OUT cohort VQSR vcf 
		jid_step_2121_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/g2121_%j.error -o \${lg}/g2121_%j.log --mem=\${sge_m_j1} -J "G4s2121_\${variantdb}" --dependency=afterok:\${jid_step_1919}:\${jid_step_2020} --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/2121.GATK4_step2121.sh \${param_file})
		jid_step_2121=\$(echo \${jid_step_2121_m}| cut -f 4 -d " ")
	;;
esac

echo
echo " --- END PIPELINE ---"

exit


EOF

}
