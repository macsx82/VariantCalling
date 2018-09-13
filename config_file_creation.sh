#!/usr/bin/env bash
set -e
#####################################
#This script is going to be used to create param file with custom variables and path that will be used by all the pipeline scripts

script_dir=`dirname $0`
echo "Loading template function"
source ${script_dir}/f_build_template.sh
echo "Loading templete alignment function"
source ${script_dir}/f_build_runner_alignment.sh
echo "Loading templete BQSR function"
source ${script_dir}/f_build_runner_BQSR.sh
echo "Loading templete Varcall function"
source ${script_dir}/f_build_runner_varcall.sh
echo "Loading templete GDBIMP function"
source ${script_dir}/f_build_runner_GDBIMP.sh
echo "Loading templete VQSR function"
source ${script_dir}/f_build_runner_VQSR.sh
echo "Loading templete LastSSel function"
source ${script_dir}/f_build_runner_LastSSel.sh


if [ $# -lt 1 ]
then
    echo "#########################"
    echo "WRONG argument number!"
    echo "Usage:"
    echo "config_file_creation.sh -i <input_file_folder> -t <template_folder> -o <output_folder> -s <sample_name> [-m <mail_address>] [-f (toggle fastq format only pipeline)]"
    echo "#########################"
    exit 1
fi

#ARGS
# template_dir=$1
# out_dir=$2

suffix=`date +"%d%m%Y%H%M%S"`

echo "${@}"
while getopts ":t:o:s:h:m:i:abvpgqlw" opt ${@}; do
  case $opt in
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
        echo "WRONG argument number!"
        echo "Usage:"
        echo "config_file_creation.sh -i <input_file_folder> -t <template_folder> -o <output_folder> -s <sample_name> [-m <mail_address>] [-f (toggle fastq format only pipeline)]"
        echo "#########################"
        exit 1
        ;;
    i)
      echo ${OPTARG}
      input_file_folder=${OPTARG}
    ;;
    a)
      echo "Alignment only"
      runner_mode="A"
      ;;  
    b)
      echo "BQSR only"
      runner_mode="B"
    ;;
    v)
      echo "Variant calling only"
      runner_mode="C"
    ;;
    p)
      echo "Post Var calling only"
      runner_mode="D"
    ;;
    g)
      echo "Gdb Import only"
      runner_mode="E"
    ;;
    q)
      echo "VQSR step only"
      runner_mode="F"
    ;;
    l)
      echo "Last step only"
      runner_mode="G"
    ;;
    m)
      echo ${OPTARG}
      mail_to=${OPTARG}
    ;;
    w)
      echo "Generate all config and runner files at once"
      runner_mode="H"
    ;;
    *)
      echo $opt
    ;;
  esac

done

mkdir -p ${out_dir}
mkdir -p ${template_dir}


build_template ${out_dir} ${sample_name} ${mail_to} > ${template_dir}/VarCall_${suffix}.conf
echo "Template file ${template_dir}/VarCall_${suffix}.conf created. You can edit it to modify any non default parameter."

case ${runner_mode} in
  A )
    build_runner_alignment ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_AlignRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_AlignRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
  ;;
  B )
    build_runner_BQSR ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_BQSRRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_BQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
  ;;
  C )
    build_runner_VarCall ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_VarCallRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_VarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
  ;;
  D )
    build_runner_post_VarCall ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_PostVarCallRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_PostVarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
  ;;
  E )
    build_runner_GDBIMP ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_GDBIMPRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_GDBIMPRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
  ;;
  F )
    build_runner_VQSR ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_VQSRRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_VQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
  ;;
  G )
    build_runner_LastSSel ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_LastSSelRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_LastSSelRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
  ;;
  H )
    build_runner_alignment ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_AlignRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_AlignRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
    
    build_runner_BQSR ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_BQSRRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_BQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
    
    build_runner_VarCall ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_VarCallRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_VarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
    
    build_runner_post_VarCall ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_PostVarCallRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_PostVarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
    
    build_runner_GDBIMP ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_GDBIMPRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_GDBIMPRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
    
    build_runner_VQSR ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_VQSRRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_VQSRRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
    
    build_runner_LastSSel ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_LastSSelRunner_${suffix}.sh
    echo "Runner file ${template_dir}/VarCall_LastSSelRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
  ;;
esac


