#!/usr/bin/env bash
set -e
#####################################
#This script is going to be used to create param file with custom variables and path that will be used by all the pipeline scripts

script_dir=`dirname $0`
echo "Loading template function"
source ${script_dir}/f_build_template.sh
echo "Loading template alignment function"
source ${script_dir}/f_build_runner_alignment.sh
echo "Loading template BQSR function"
source ${script_dir}/f_build_runner_BQSR.sh
echo "Loading template Varcall function"
source ${script_dir}/f_build_runner_varcall.sh
echo "Loading template GDBIMP function"
source ${script_dir}/f_build_runner_GDBIMP.sh
echo "Loading template VQSR function"
source ${script_dir}/f_build_runner_VQSR.sh
echo "Loading template Apply VQSR function"
source ${script_dir}/f_build_runner_applyVQSR.sh
echo "Loading template LastSSel function"
source ${script_dir}/f_build_runner_LastSSel.sh


if [ $# -lt 1 ]
then
    echo "#########################"
    echo "WRONG argument number!"
    echo "Usage:"
    echo "config_file_creation.sh -i <input_file_folder> -t <template_folder> -o <output_folder> -s <sample_name> [-m <mail_address>] "
    echo "Execution options: -a: alignement only "
    echo "                   -b: BQSR only "
    echo "                   -v: Variant calling only "
    echo "                   -p: Post variant calling only"
    echo "                   -g: GDBImport/CombineGVCFs only "
    echo "                   -q: VQSR step only "
    echo "                   -k: Apply VQSR step only "
    echo "                   -l: last step only "
    echo "                   -w: Generate all config and runner files at once "
    echo "                   -d: Specify common out dir for all steps after variant calling."
    echo "                   -c: Provide a path for an existing config file."
    echo "                   -1: Provide fastq file name for R1."
    echo "                   -2: Provide fastq file name for R2."
    echo "                   -n: Execution host full name"
    echo "                   -j: Execution queue name: it is possible to use the format <queue>@<hostname>, to select a specific host for execution."
    echo "                   -z: Activate POOLED mode: generation of pooled templates and pooled configuration file."
    echo "                   -h: this help message "
    echo "#########################"
    exit 1
fi

#ARGS
# template_dir=$1
# out_dir=$2

suffix=`date +"%d%m%Y%H%M%S"`
runner_mode=()

echo "${@}"
while getopts ":t:o:s:m:i:c:d:abvpgqlwkh1:2:n:j:z" opt ${@}; do
  case $opt in
    d)
    common_out_dir=${OPTARG}
    ;;
    z)
    pooled_mode="ON"
    ;;
    n)
    # specify execution node
    exec_host=${OPTARG}
    ;;
    j)
    #specify queue name, also in the form queue@exec_host
    exec_queue=${OPTARG}
    ;;
    t)
      echo ${OPTARG}
      template_dir=${OPTARG}
      ;;
    o)
      echo ${OPTARG}
      out_dir=${OPTARG}
      ;;
    s)
      echo ${OPTARG}
      sample_name=${OPTARG}
      ;;
    h)
      echo "#########################"
      echo "Usage:"
      echo "config_file_creation.sh -i <input_file_folder> -t <template_folder> -o <output_folder> -s <sample_name> [-m <mail_address>] "
      echo "Execution options: -a: alignement only "
      echo "                   -b: BQSR only "
      echo "                   -v: Variant calling only "
      echo "                   -p: Post variant calling only"
      echo "                   -g: GDBImport/CombineGVCFs only "
      echo "                   -q: VQSR step only "
      echo "                   -k: Apply VQSR step only "
      echo "                   -l: last step only "
      echo "                   -w: Generate all config and runner files at once "
      echo "                   -d: Specify common out dir for all steps after variant calling."
      echo "                   -c: Provide a path for an existing config file."
      echo "                   -1: Provide fastq file name for R1."
      echo "                   -2: Provide fastq file name for R2."
      echo "                   -n: Execution host full name"
      echo "                   -j: Execution queue name: it is possible to use the format <queue>@<hostname>, to select a specific host for execution."
      echo "                   -z: Activate POOLED mode: generation of pooled templates and pooled configuration file."
      echo "                   -h: this help message "
      echo "#########################"
      exit 1
      ;;
    i)
      echo ${OPTARG}
      input_file_folder=${OPTARG}
    ;;
    a)
      echo "Alignment only"
      runner_mode+=("A")
      ;;  
    b)
      echo "BQSR only"
      runner_mode+=("B")
    ;;
    v)
      echo "Variant calling only"
      runner_mode+=("C")
    ;;
    p)
      echo "Post Var calling only"
      runner_mode+=("D")
    ;;
    g)
      echo "Gdb Import only"
      runner_mode+=("E")
    ;;
    q)
      echo "VQSR step only"
      runner_mode+=("F")
    ;;
    l)
      echo "Last step only"
      runner_mode+=("G")
    ;;
    m)
      echo ${OPTARG}
      mail_to=${OPTARG}
    ;;
    w)
      echo "Generate all config and runner files at once"
      runner_mode=("H")
    ;;
    k)
      echo "ApplyVQSR step only"
      runner_mode+=("I")
    ;;
    c)
      conf_file_path=${OPTARG}
      echo "Use specified conf file: ${conf_file_path}"
    ;;
    1)
      r1_fq_file=${OPTARG}
      echo "Use specified fastq file name: ${r1_fq_file}"
    ;;
    2)
      r2_fq_file=${OPTARG}
      echo "Use specified fastq file name: ${r2_fq_file}"
    ;;
    *)
      echo $opt
    ;;
  esac

done


if [[ -z ${out_dir} ]]; then
  if [[ -z ${pooled_mode} ]]; then
    echo "Error. Out folder not specified, but POOLED mode not selected (-z option). Exiting..."
    exit 1
  else
    echo "Out folder not specified. Pooled mode detected. "
  fi
else
  mkdir -p ${out_dir}
fi

mkdir -p ${template_dir}

echo ${runner_mode[@]}
echo ${conf_file_path}


if [[ -z "${conf_file_path}" ]]; then

  if [[ -z ${pooled_mode} ]]; then

    #check existence of fastq file names
    if [[ ! -z "${r1_fq_file}" ]]; then
      echo "User selected fastq files names used in conf file... "
    else
      echo "Standard fastq files name used in conf file... "
      r1_fq_file=${sample_name}_R1_val_1.fq.gz
      r2_fq_file=${sample_name}_R2_val_2.fq.gz
    fi
  fi
  #check existence of execution host name
  if [[ ! -z ${exec_host} ]]; then
    echo "User selected execution host: ${exec_host}"
  else
    exec_host="apollo1.lan10gb"
    echo "general execution host set to: ${exec_host}"
  fi
  #check existence of execution queue name
  if [[ ! -z ${exec_queue} ]]; then
    echo "User selected execution host: ${exec_queue}"
  else
    exec_queue="all.q"
    echo "general execution queue set to: ${exec_queue}"
  fi
  #check existence of the common_out_dir specification
  if [[ ! -z ${common_out_dir} ]]; then
    #this need to be specified in the sample mode
    echo "User selected common folder : ${common_out_dir}"
    mkdir -p ${common_out_dir}
  else
    #we use the same out_dir for the pooled mode or if we don't need it
    common_out_dir=${out_dir}
    echo "general common folder set to: ${common_out_dir}"
  fi

  if [[ -z ${pooled_mode} ]]; then
    build_template_sample ${out_dir} ${sample_name} ${mail_to} ${input_file_folder} ${r1_fq_file} ${r2_fq_file} ${exec_host} ${exec_queue} ${common_out_dir} > ${template_dir}/VarCall_${suffix}.conf
    echo "Template file ${template_dir}/VarCall_${suffix}.conf created. You can edit it to modify any non default parameter."
  else
    build_template_pooled ${input_file_folder} ${mail_to} ${exec_host} ${exec_queue} > ${template_dir}/VarCall_pooled_${suffix}.conf
    echo "Template file ${template_dir}/VarCall_pooled_${suffix}.conf created. You can edit it to modify any non default parameter."
    
  fi

  
  for runner_gen in ${runner_mode[@]}; do
    case ${runner_gen} in
      A )
        build_runner_alignment ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/01_VarCall_AlignRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_AlignRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      B )
        build_runner_BQSR ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/02_VarCall_BQSRRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_BQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      C )
        build_runner_VarCall ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/03_VarCall_VarCallRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_VarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      D )
        build_runner_post_VarCall ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/04_VarCall_PostVarCallRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_PostVarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      E )
        build_runner_GDBIMP ${template_dir}/VarCall_pooled_${suffix}.conf > ${template_dir}/05_VarCall_GDBIMPRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_GDBIMPRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      F )
        build_runner_VQSR ${template_dir}/VarCall_pooled_${suffix}.conf > ${template_dir}/06_VarCall_VQSRRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_VQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      G )
        build_runner_LastSSel ${template_dir}/VarCall_pooled_${suffix}.conf > ${template_dir}/07_VarCall_LastSSelRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_LastSSelRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      I)
        build_runner_applyVQSR ${template_dir}/VarCall_pooled_${suffix}.conf > ${template_dir}/06_VarCall_ApplyVQSRRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_ApplyVQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      H )
        build_runner_alignment ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/01_VarCall_AlignRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_AlignRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
        
        build_runner_BQSR ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/02_VarCall_BQSRRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_BQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
        
        build_runner_VarCall ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/03_VarCall_VarCallRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_VarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
        
        build_runner_post_VarCall ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/04_VarCall_PostVarCallRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_PostVarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
        
        build_runner_GDBIMP ${template_dir}/VarCall_pooled_${suffix}.conf > ${template_dir}/05_VarCall_GDBIMPRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_GDBIMPRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
        
        build_runner_VQSR ${template_dir}/VarCall_pooled_${suffix}.conf > ${template_dir}/06_VarCall_VQSRRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_VQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
        
        build_runner_applyVQSR ${template_dir}/VarCall_pooled_${suffix}.conf > ${template_dir}/06_VarCall_ApplyVQSRRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_ApplyVQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."

        build_runner_LastSSel ${template_dir}/VarCall_pooled_${suffix}.conf > ${template_dir}/07_VarCall_LastSSelRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_LastSSelRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
    esac
  done
else
  echo "Template file already present: ${conf_file_path}. You can edit it to modify any non default parameter."
  for runner_gen in ${runner_mode[@]}; do
    echo ${runner_gen}
    case ${runner_gen} in
      A )
        build_runner_alignment ${conf_file_path} > ${template_dir}/01_VarCall_AlignRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_AlignRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      B )
        build_runner_BQSR ${conf_file_path} > ${template_dir}/02_VarCall_BQSRRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_BQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      C )
        build_runner_VarCall ${conf_file_path} > ${template_dir}/03_VarCall_VarCallRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_VarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      D )
        build_runner_post_VarCall ${conf_file_path} > ${template_dir}/04_VarCall_PostVarCallRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_PostVarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      E )
        build_runner_GDBIMP ${conf_file_path} > ${template_dir}/05_VarCall_GDBIMPRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_GDBIMPRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      F )
        build_runner_VQSR ${conf_file_path} > ${template_dir}/06_VarCall_VQSRRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_VQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      G )
        build_runner_LastSSel ${conf_file_path} > ${template_dir}/07_VarCall_LastSSelRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_LastSSelRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      I)
        build_runner_applyVQSR ${conf_file_path} > ${template_dir}/06_VarCall_ApplyVQSRRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_ApplyVQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
      H )
        build_runner_alignment ${conf_file_path} > ${template_dir}/01_VarCall_AlignRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_AlignRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
        
        build_runner_BQSR ${conf_file_path} > ${template_dir}/02_VarCall_BQSRRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_BQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
        
        build_runner_VarCall ${conf_file_path} > ${template_dir}/03_VarCall_VarCallRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_VarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
        
        build_runner_post_VarCall ${conf_file_path} > ${template_dir}/04_VarCall_PostVarCallRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_PostVarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
        
        build_runner_GDBIMP ${conf_file_path} > ${template_dir}/05_VarCall_GDBIMPRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_GDBIMPRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
        
        build_runner_VQSR ${conf_file_path} > ${template_dir}/06_VarCall_VQSRRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_VQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
        
        build_runner_applyVQSR ${conf_file_path} > ${template_dir}/06_VarCall_ApplyVQSRRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_ApplyVQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."

        build_runner_LastSSel ${conf_file_path} > ${template_dir}/07_VarCall_LastSSelRunner_${suffix}.sh
        echo "Runner file ${template_dir}/VarCall_LastSSelRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
      ;;
    esac
  done
fi



