#!/usr/bin/env bash
set -e
#Wrapper to generate runners for different steps of the variant calling pipeline.
#
#Input: 
#	- a list with sample names and file paths. This list will be used for the single sample stile steps, containing fastq files paths.
#		There will be two entries for each sample, corresponding to R1 and R2.
#	- some options for the runner generators

# while getopts ":t:o:s:m:i:c:abvpgqlwkh" opt ${@}; do
while getopts ":i:t:o:m:c:l:n:j:abh" opt ${@}; do
	case $opt in
	l)
	  echo ${OPTARG}
      config_file_creator=${OPTARG}
	  ;;
    i)
      echo ${OPTARG}
      #in pooled mode, this is the common path for input files
      #in sample mode, this is the path to the file list
      input_file_list=${OPTARG}
      ;;
	t)
      echo ${OPTARG}
      template_dir=${OPTARG}
      ;;
    o)
      echo ${OPTARG}
      out_dir=${OPTARG}
      ;;
  	c)
      conf_file_path=${OPTARG}
      echo "Use specified conf file: ${conf_file_path}"
      ;;
    m)
      echo ${OPTARG}
      mail_to=${OPTARG}
    ;;
    n)
      exec_host=${OPTARG}
    ;;
    j)
      exec_queue=${OPTARG}
    ;;
  	a)
	#generate only single sample steps for each sample
        work_mode="A"
    ;;
    b)
    #generate only multi sample steps
    #ideally, here we should have a list of sample names and paths, processed bams for the samtools implementation
    #or GVCF files for the GATK implementation, that we created using a fixed path structure for each sample, to make things easier
        work_mode="B"
    ;;
	h)
      echo "#########################"
      echo "Usage:"
      echo "varcall_pipe.sh -l <launcher_script> -i <input_file_list> -t <template_folder> -o <output_folder> [-m <mail_address>] "
      echo "Execution options: -a: single sample steps only "
      echo "                   -b: multi sample steps only"
      echo "                   -c: Provide a path for an existing config file."
      echo "                   -n: Execution host full name"
      echo "                   -j: Execution queue name: it is possible to use the format <queue>@<hostname>, to select a specific host for execution."
      echo "                   -h: this help message "
      echo "#########################"
      exit 1
      ;;

	esac

done


#get all samples
sample_names=$(cut -f 1 -d " " ${input_file_list} |sort| uniq)
samples_count=$(cut -f 1 -d " " ${input_file_list} |sort| uniq| wc -l)
fastq_count=$(cut -f 2 -d " " ${input_file_list} | wc -l)
double_sample=$((${samples_count} + ${samples_count}))

#check if we have samples and files in the correct number
echo -e "Samples detected: ${samples_count}.\nFastq files detected: ${fastq_count}"
if [[ ${double_sample} -eq ${fastq_count} ]]; then
    echo -e "Samples and fastq files are coherent in numbers, we can proceed...."
else
    echo 'ERROR!!Mismatch between samples and fastq files. Exiting'
    exit 1
fi

#add additional optional parameters
optional_pars=()
if [[ ! -z ${exec_host} ]]; then
    optional_pars+="-n ${exec_host} "
fi
if [[ ! -z ${exec_queue} ]]; then
    optional_pars+="-j ${exec_queue} "
fi

# if we're still here, we are clear and can go on
case ${work_mode} in
    A)
    #First section to generate runners for the SINGLE SAMPLE steps: at the moment, only the GATK implementation is in production.
    #
    # mkdir -p ${out_dir}/
    # mkdir -p ${template_dir}/
    #now, for each sample, get the name and related files
    for sample_name in ${sample_names}
    do
        #get the fastq files path
        r1_fq=$(awk -v smp_name=${sample_name} '$1==smp_name {print $2}' ${input_file_list} | head -1)
        r2_fq=$(awk -v smp_name=${sample_name} '$1==smp_name {print $2}' ${input_file_list} | tail -1)

        #now, get the fastq folder
        fastq_input_folder=$(dirname ${r1_fq})
        r1_fq_names=$(basename ${r1_fq})
        r2_fq_names=$(basename ${r2_fq})
        echo ${fastq_input_folder}
        
        #now we can start creating templates for each sample
        # echo "${config_file_creator} -i ${fastq_input_folder} -t ${template_dir} -o ${out_dir} -s ${sample_name} -1 ${r1_fq_names} -2 ${r2_fq_names} -m ${mail_to} -a -b -v -p ${optional_pars[@]}"
        ${config_file_creator} -i ${fastq_input_folder} -t ${template_dir}/${sample_name} -o ${out_dir}/${sample_name} -s ${sample_name} -1 ${r1_fq_names} -2 ${r2_fq_names} -m ${mail_to} -a -b -v -p "${optional_pars[@]}"
    done
    ;;
    B)
    #Second section used to generate runner for the MULTI SAMPLES steps
    #
    #ideally, here we should have a list of sample names and paths, processed bams for the samtools implementation
    #or GVCF files for the GATK implementation, that we created using a fixed path structure for each sample, to make things easier
    input_common_folder=${input_file_list}

    ${config_file_creator} -i ${input_common_folder} -t ${template_dir} -m ${mail_to} -z -g -q -k -l "${optional_pars[@]}"

    ;;
esac



