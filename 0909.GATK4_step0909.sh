#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - SOURCEs - ###
#source functions file
own_folder=`dirname $0`
source ${hs}/pipeline_functions.sh
f1=$1                   ##interval contings
param_file=$2
source ${param_file}

# We don't need to differentiate here if there is job array or not, since we will use the ja_runner par approach
#We need to know if the f1 value is a file name or an actual interval
if [[ -f "${f1}" ]]; then
	#if i'm providing a real file
	interval_name=`basename ${f1}`
else
	#if i'm providing an interval written in any form chrZZ or chrZZ:ps-pe
	interval_name=${f1}
fi
c_gv="${SM}_${interval_name}_g.vcf.gz"     #conting gVCF file

# if [[ ${job_a} -eq 1 ]]; then
# 	#Job array option
# 	# param_file=$2
#     # f2=$2                   #interval index
#     c_gv="${SM}_${f1}_g.vcf.gz"     #conting gVCF file
# else
# 	#No job array option
# 	# param_file=$3
# 	# source ${param_file}
#     # f1=$2                   #interval contings
#     f1_name=`basename ${f1}`
#     c_gv="${SM}_${f1_name}_g.vcf.gz"     #conting gVCF file
# fi

if [[ -z "${fol4_tmp}" || -z "${fol5_tmp}" || -z "${fol5_host}" ]];then
	#The tmp setup is not activated
	echo "One or all the parameters for the tmp setup are missing:"
	echo "fol4_tmp=${fol4_tmp}"
	echo "fol5_tmp=${fol5_tmp}"
	echo "fol5_host=${fol5_host}"
	echo "Calling with standard setup..."
	### - CODE - ###
	mkdir -p ${fol5}
	#loop-9
	echo
	# cd ${fol4}/
	echo "> HaplotypeCaller"
	# ${GATK4} --java-options ${java_opt2x} ${java_XX1} ${java_XX2} HaplotypeCaller -R ${GNMhg38} -I ${fol4}/${applybqsr} -O ${fol5}/${c_gv} -L "${f1}" -ip ${ip1} --max-alternate-alleles ${maa} -ERC GVCF
	#We need to manage also the ploidy based on the sex and the interval
	if [[ ${sex} -eq 2 ]]; then
		#we are working with female samples: no need to worry about ploidy
		#but we need to skip chrY calls
		if [[ -f "${f1}" ]]; then
			#if the interval is a file, we need to check if its a chrY file 
			#and skip the submission
			chrY_content=$(awk '$1~"Y" {print $1}' ${f1} | sort|uniq| wc -l| cut -f 1 -d " ")
		else
			#If the interval is submitted in the form of
			# f1="chrY:2781480-9046914"
			chrY_content=$(echo ${f1} | awk '$0~"Y"'| wc -l | cut -f 1 -d " ")
		fi

		if [[ ${chrY_content} -eq 0 ]]; then
			#we will submit the job
			echo "Job submitted for female sample on non Y chromosome."
			${GATK4} --java-options "${java_opt2x} ${java_XX1} ${java_XX2}" HaplotypeCaller -R ${GNMhg38} -I ${fol4}/${applybqsr} -O ${fol5}/${c_gv} -L "${f1}" -ip ${ip1} --max-alternate-alleles ${maa} -ERC GVCF --output-mode EMIT_ALL_CONFIDENT_SITES
		fi
	else
		#we are working with male samples: we need to worry about ploidy
		#to correctly handle non par regions and chrY calls
		if [[ -f "${f1}" ]]; then
			#if the interval is a file, we need to check if its a chrY file 
			#and skip the submission
			chrY_content=$(awk '$1~"Y" {print $1}' ${f1} | sort|uniq| wc -l| cut -f 1 -d " ")
			chrX_content=$(awk '$0~"NON_PAR"' ${f1}| sort|uniq| wc -l| cut -f 1 -d " ")
		else
			#If the interval is submitted in the form of
			# f1="chrY:2781480-9046914"
			chrY_content=$(echo ${f1} | awk '$0~"Y"'| wc -l | cut -f 1 -d " ")
			#for chrX interval, we need to check if it is in the par or non par regions
            # f1="chrX:10001-2781479"
			#X: 10001 - 2781479 (PAR1)
			#X: 155701383 - 156030895 (PAR2)
			#we are checking if we are outside the par regions
			chrX_content=$( echo ${f1} | awk '$0~"X"' | awk '{split($1,b,":");split(b[2],c,"-");if( (c[1] <= 10001 || (c[1] >= 2781479 && c[1] <= 155701383) || c[1] >= 156030895) && (c[2] <= 10001 ||( c[2] >= 2781479 && c[2] <= 155701383)|| c[2] >= 156030895) ) print $0}' | wc -l | cut -f 1 -d " ")
		fi
		if [[ ${chrY_content} != "0" ]]; then
            chrom_status="SEXC"
		fi
		if [[ ${chrX_content} != "0" ]]; then
            chrom_status="SEXC"
		fi
		if [[ ${chrX_content} -eq 0 && ${chrY_content} -eq 0 ]]; then
            chrom_status="AUTOSOMAL"
		fi
        # echo ${chrom_status}
		case ${chrom_status} in
			AUTOSOMAL )
				echo "Job submitted for male sample on autosomal chromosome or chrX PAR regions."
				${GATK4} --java-options "${java_opt2x} ${java_XX1} ${java_XX2}" HaplotypeCaller -R ${GNMhg38} -I ${fol4}/${applybqsr} -O ${fol5}/${c_gv} -L "${f1}" -ip ${ip1} --max-alternate-alleles ${maa} -ERC GVCF --output-mode EMIT_ALL_CONFIDENT_SITES
				;;
			SEXC )
				echo "Job submitted for male sample on Y chromosome or chrX NON_PAR regions."
				${GATK4} --java-options "${java_opt2x} ${java_XX1} ${java_XX2}" HaplotypeCaller -R ${GNMhg38} -I ${fol4}/${applybqsr} -O ${fol5}/${c_gv} -L "${f1}" -ip ${ip1} -ploidy ${sex} --max-alternate-alleles ${maa} -ERC GVCF --output-mode EMIT_ALL_CONFIDENT_SITES
				;;
		esac
		# ${GATK4} --java-options "${java_opt2x} ${java_XX1} ${java_XX2}" HaplotypeCaller -R ${GNMhg38} -I ${fol4}/${applybqsr} -O ${fol5}/${c_gv} -L "${f1}" -ip ${ip1} --max-alternate-alleles ${maa} -ERC GVCF --output-mode EMIT_ALL_CONFIDENT_SITES
	fi
	
	echo "- END -"

	#qdel
	echo
	# rm -v ${fol4}/"${SM}_bqsr.bam"
	# rm -v ${fol4}/"${SM}_bqsr.bai"
	# rm -v ${fol4}/"${SM}_bqsr.bam.md5"
	#in this step to massimize parallelization we are working on temp folders, so we need to copy all the results back to the correct host

else
	#The tmp setup is fully active
	echo "Tmp setup for calling..."
	### - CODE - ###
	mkdir -p ${fol4_tmp}
	mkdir -p ${fol5_tmp}
	mkdir -p ${fol5_host}
	#we also need to copy the data from the host node to the current fol4_tmp
	rsync -av -u -P ${USER}@${exec_host}:${fol4}/ ${fol4_tmp}/.
	echo "tmp copy finished ..." 
	#loop-9
	echo
	# cd ${fol4}/
	echo "> HaplotypeCaller"
	# ${GATK4} --java-options ${java_opt2x} ${java_XX1} ${java_XX2} HaplotypeCaller -R ${GNMhg38} -I ${fol4}/${applybqsr} -O ${fol5}/${c_gv} -L "${f1}" -ip ${ip1} --max-alternate-alleles ${maa} -ERC GVCF
	#We need to manage also the ploidy based on the sex and the interval
    if [[ ${sex} -eq 2 ]]; then
        #we are working with female samples: no need to worry about ploidy
        #but we need to skip chrY calls
        if [[ -f "${f1}" ]]; then
            #if the interval is a file, we need to check if its a chrY file 
            #and skip the submission
            chrY_content=$(awk '$1~"Y" {print $1}' ${f1} | sort|uniq| wc -l| cut -f 1 -d " ")
        else
            #If the interval is submitted in the form of
            # f1="chrY:2781480-9046914"
            chrY_content=$(echo ${f1} | awk '$0~"Y"'| wc -l | cut -f 1 -d " ")
        fi

        if [[ ${chrY_content} -eq 0 ]]; then
            #we will submit the job
            echo "Job submitted for female sample on non Y chromosome."
            ${GATK4} --java-options "${java_opt2x} ${java_XX1} ${java_XX2}" HaplotypeCaller -R ${GNMhg38} -I ${fol4_tmp}/${applybqsr} -O ${fol5_tmp}/${c_gv} -L "${f1}" -ip ${ip1} --max-alternate-alleles ${maa} -ERC GVCF --output-mode EMIT_ALL_CONFIDENT_SITES
        fi
    else
        #we are working with male samples: we need to worry about ploidy
        #to correctly handle non par regions and chrY calls
        if [[ -f "${f1}" ]]; then
            #if the interval is a file, we need to check if its a chrY file 
            #and skip the submission
            chrY_content=$(awk '$1~"Y" {print $1}' ${f1} | sort|uniq| wc -l| cut -f 1 -d " ")
            chrX_content=$(awk '$0~"NON_PAR"' ${f1}| sort|uniq| wc -l| cut -f 1 -d " ")
        else
            #If the interval is submitted in the form of
            # f1="chrY:2781480-9046914"
            chrY_content=$(echo ${f1} | awk '$0~"Y"'| wc -l | cut -f 1 -d " ")
            #for chrX interval, we need to check if it is in the par or non par regions
            # f1="chrX:10001-2781479"
            #X: 10001 - 2781479 (PAR1)
            #X: 155701383 - 156030895 (PAR2)
            #we are checking if we are outside the par regions
            chrX_content=$( echo ${f1} | awk '$0~"X"' | awk '{split($1,b,":");split(b[2],c,"-");if( (c[1] <= 10001 || (c[1] >= 2781479 && c[1] <= 155701383) || c[1] >= 156030895) && (c[2] <= 10001 ||( c[2] >= 2781479 && c[2] <= 155701383)|| c[2] >= 156030895) ) print $0}' | wc -l | cut -f 1 -d " ")
        fi
        if [[ ${chrY_content} != "0" ]]; then
            chrom_status="SEXC"
        fi
        if [[ ${chrX_content} != "0" ]]; then
            chrom_status="SEXC"
        fi
        if [[ ${chrX_content} -eq 0 && ${chrY_content} -eq 0 ]]; then
            chrom_status="AUTOSOMAL"
        fi
        # echo ${chrom_status}
        case ${chrom_status} in
            AUTOSOMAL )
                echo "Job submitted for male sample on autosomal chromosome or chrX PAR regions."
                ${GATK4} --java-options "${java_opt2x} ${java_XX1} ${java_XX2}" HaplotypeCaller -R ${GNMhg38} -I ${fol4_tmp}/${applybqsr} -O ${fol5_tmp}/${c_gv} -L "${f1}" -ip ${ip1} --max-alternate-alleles ${maa} -ERC GVCF --output-mode EMIT_ALL_CONFIDENT_SITES
                ;;
            SEXC )
                echo "Job submitted for male sample on Y chromosome or chrX NON_PAR regions."
                ${GATK4} --java-options "${java_opt2x} ${java_XX1} ${java_XX2}" HaplotypeCaller -R ${GNMhg38} -I ${fol4_tmp}/${applybqsr} -O ${fol5_tmp}/${c_gv} -L "${f1}" -ip ${ip1} -ploidy ${sex} --max-alternate-alleles ${maa} -ERC GVCF --output-mode EMIT_ALL_CONFIDENT_SITES
                ;;
        esac
        # ${GATK4} --java-options "${java_opt2x} ${java_XX1} ${java_XX2}" HaplotypeCaller -R ${GNMhg38} -I ${fol4}/${applybqsr} -O ${fol5}/${c_gv} -L "${f1}" -ip ${ip1} --max-alternate-alleles ${maa} -ERC GVCF --output-mode EMIT_ALL_CONFIDENT_SITES
    fi
    
    echo "- END -"
    # ${GATK4} --java-options "${java_opt2x} ${java_XX1} ${java_XX2}" HaplotypeCaller -R ${GNMhg38} -I ${fol4_tmp}/${applybqsr} -O ${fol5_tmp}/${c_gv} -L "${f1}" -ip ${ip1} --max-alternate-alleles ${maa} -ERC GVCF --output-mode EMIT_ALL_CONFIDENT_SITES
	echo "- END -"

	#qdel
	echo
	# rm -v ${fol4}/"${SM}_bqsr.bam"
	# rm -v ${fol4}/"${SM}_bqsr.bai"
	# rm -v ${fol4}/"${SM}_bqsr.bam.md5"
	#in this step to massimize parallelization we are working on temp folders, so we need to copy all the results back to the correct host
	rsync -av -u -P ${fol5_tmp}/${c_gv}* ${USER}@${exec_host}:${fol5_host}/processing/.
fi



touch step09.done
