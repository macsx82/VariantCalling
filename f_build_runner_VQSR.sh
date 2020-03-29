function build_runner_VQSR() {
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
		#Pre-VQSR
		#pipe step 17-18
		#IN cohort raw-VCF OUT cohort Hard Filtered raw-VCF /// VariantFiltration
		#IN cohort Hard Filtered raw-VCF OUT cohort Site Only raw-VCF /// MakeSitesOnlyVcf

		echo "bash \${hs}/1718.GATK4_step1718.sh \${param_file}" | qsub -N G4s1718_\${variantdb} -hold_jid G4s1616_\${variantdb} -o \${lg}/\${variantdb}/g1718_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g1718_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m} -q \${sge_q} 

		#VQSR
		#pipe step 19
		#IN Site cohort Site Only raw-VCF OUT indel tranches, indel recal /// VariantRecalibrator

		echo "bash \${hs}/1919.GATK4_step1919.sh \${param_file}" | qsub -N G4s1919_\${variantdb} -hold_jid G4s1718_\${variantdb} -o \${lg}/\${variantdb}/g1919_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g1919_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m_j3} -q \${sge_q} 

		#VQSR
		#pipe step 20
		#IN Site cohort Site Only raw-VCF OUT snp tranches, snp recal /// VariantRecalibrator

		echo "bash \${hs}/2020.GATK4_step2020.sh \${param_file}" | qsub -N G4s2020_\${variantdb} -hold_jid G4s1718_\${variantdb} -o \${lg}/\${variantdb}/g2020_\${variantdb}_\\\$JOB_ID.log -e \${lg}/\${variantdb}/g2020_\${variantdb}_\\\$JOB_ID.error -m ea -M \${mail} -cwd -l h_vmem=\${sge_m_j4} -q \${sge_q} 
	;;
	CINECA)
		#Pre-VQSR
		#pipe step 17-18
		#IN cohort raw-VCF OUT cohort Hard Filtered raw-VCF /// VariantFiltration
		#IN cohort Hard Filtered raw-VCF OUT cohort Site Only raw-VCF /// MakeSitesOnlyVcf
		jid_step_1718_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/g1718_%j.error -o \${lg}/g1718_%j.log --mem=\${sge_m} -J "G4s1718_\${variantdb}" --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/1718.GATK4_step1718.sh \${param_file})
		jid_step_1718=\$(echo \${jid_step_1718_m}| cut -f 4 -d " ")

		#VQSR
		#pipe step 19
		#IN Site cohort Site Only raw-VCF OUT indel tranches, indel recal /// VariantRecalibrator
		jid_step_1919_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/g1919_%j.error -o \${lg}/g1919_%j.log --mem=\${sge_m_j3} -J "G4s1919_\${variantdb}" --dependency=afterok:\${jid_step_1718} --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/1919.GATK4_step1919.sh \${param_file})
		jid_step_1919=\$(echo \${jid_step_1919_m}| cut -f 4 -d " ")
		

		#VQSR
		#pipe step 20
		#IN Site cohort Site Only raw-VCF OUT snp tranches, snp recal /// VariantRecalibrator
		jid_step_2020_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=24:00:00 -e \${lg}/g2020_%j.error -o \${lg}/g2020_%j.log --mem=\${sge_m_j4} -J "G4s2020_\${variantdb}" --dependency=afterok:\${jid_step_1718} --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/2020.GATK4_step2020.sh \${param_file})
		jid_step_2020=\$(echo \${jid_step_2020_m}| cut -f 4 -d " ")
		

	;;
esac


echo " --- END PIPELINE ---"

exit


EOF

}
