#!/usr/bin/env bash
set -e
#####################################
#This script is going to be used to create param file with custom variables and path that will be used by all the pipeline scripts


function build_template_all(){

cat << EOF
### - FIXED PARAMETERS - ###
#step1
SM=$2         #sample name
#input_path=$4 #input file path

inbam=\${SM}.bam     #input bam

#step2
inbam=\${SM}.bam     #input bam
ubam=\${SM}_unmap.bam      #unmapped bam

#step3
ubam=\${SM}_unmap.bam      #unmapped bam
fastq1=\${SM}_1.fq     #fastq 1
fastq2=\${SM}_2.fq     #fastq 2

#step4
fastq1=\${fol2}/\${SM}_1.fastq      #fastq 1
fastq2=\${fol2}/\${SM}_2.fastq      #fastq 2

#step6
val1=\${SM}_1_val_1.fq.gz    
val2=\${SM}_2_val_2.fq.gz  

### - Pipeline parameters - ###
# Modify these values to work with non default parameters
q=20        #quality
e=0.1       #error rate
cR1=0        #cut 5'
cR2=0        #cut 5'
tpcR1=0       #cut 3'
tpcR2=0       #cut 3'
stringency=7  #stringency parameter for adapter trimming [default is 1]
#-#-#
java_opt1x=-Xmx5g    #java memory requirement

#########SET UP YOUR EMAIL HERE ##############
mail=$3
#########SET UP YOUR EMAIL HERE ##############

#######SET UP SGE/QUEUE MANAGER PARAMETERS HERE ############
cluster_man="CINECA" #Specify the cluster manager:BURLO or CINECA
sge_q=all
seq_m=10G
#######SET UP SGE/QUEUE MANAGER PARAMETERS HERE ############

### - PATH FILE - ###
base_out=$1
tmp=${WORK}/localtemp

### - PATH FOLDER - ###
fol1=\${base_out}/1.bam
fol2=\${base_out}/2.fastq_pre
fol3=\${base_out}/3.fastqc
fol4=\${base_out}/4.fastq_post
fol5=\${base_out}/Storage

# ### - PATH TOOL - ###
# PICARD=/share/apps/bio/picard-2.17.3/picard.jar    #
# SAMTOOLS=/share/apps/bio/samtools/samtools     #
# ph3=/share/apps/bio/bin/bedtools      #
# ph4=/share/apps/bio/miniconda2/bin/fastqc   #
# ph5=/share/apps/bio/miniconda2/bin/trim_galore    #
### - PATH TOOL - CINECA SLURM version - ###
PICARD=/galileo/prod/opt/applications/picardtools/2.3.0/binary/bin/picard.jar
SAMTOOLS=/galileo/prod/opt/applications/samtools/1.9/intel--pe-xe-2018--binary/bin/samtools
ph3=/share/apps/bio/bin/bedtools      #
ph4=/cineca/prod/opt/applications/fastqc/0.11.5/jre--1.8.0_111--binary/bin/fastqc
ph5=/galileo/home/userexternal/mcocca00/bin/trim_galore 

### - PATH SCRIPT / Log - ###
lg=\${base_out}/Log
hs=${HOME}/scripts/pipelines/VariantCalling

EOF

}


function build_template_fastq(){

cat << EOF
############################################
#Template to pre-process fastq files
### - FIXED PARAMETERS - ###
#step4
SM=$2         #sample name
#input_path=$4 #input file path

#Template to pre-process fastq files
# MODIFY FASTQ PATH HERE
#
fastq1="${r1_fq_file}"      #fastq 1
fastq2="${r2_fq_file}"      #fastq 2

#step6
val1="\${SM}_1_val_1.fq.gz"    
val2="\${SM}_2_val_2.fq.gz"  

### - Pipeline parameters - ###
# MODIFY THESE VALUES TO WORK WITH NON DEFAULT PARAMETERS
q=20        #quality
e=0.1       #error rate
cR1=0        #cut 5'
cR2=0        #cut 5'
tpcR1=0       #cut 3'
tpcR2=0       #cut 3'
stringency=7  #stringency parameter for adapter trimming [default is 1]
#-#-#
java_opt1x=-Xmx5g    #java memory requirement

#########SET UP YOUR EMAIL HERE ##############
mail=$3
#########SET UP YOUR EMAIL HERE ##############

#########SET UP SGE/QUEUE MANAGER PARAMETERS HERE ##########
cluster_man="CINECA" #Specify the cluster manager:BURLO or CINECA
sge_q=${exec_queue}
seq_m=10G
#########SET UP SGE/QUEUE MANAGER PARAMETERS HERE ##########

### - PATH FILE - ###
base_out=$1
tmp=${WORK}/localtemp

### - PATH FOLDER - ###
fol1=\${base_out}/1.bam
fol2=\${base_out}/2.fastq_pre
fol3=\${base_out}/3.fastqc
fol4=\${base_out}/4.fastq_post
fol5=\${base_out}/Storage

### - PATH TOOL - ###
# PICARD=/share/apps/bio/picard-2.17.3/picard.jar    #
# SAMTOOLS=/share/apps/bio/samtools/samtools     #
# ph3=/share/apps/bio/bin/bedtools      #
# ph4=/share/apps/bio/miniconda2/bin/fastqc   #
# ph5=/share/apps/bio/miniconda2/bin/trim_galore    #
### - PATH TOOL - CINECA SLURM version - ###
PICARD=/galileo/prod/opt/applications/picardtools/2.3.0/binary/bin/picard.jar
SAMTOOLS=/galileo/prod/opt/applications/samtools/1.9/intel--pe-xe-2018--binary/bin/samtools
ph3=/share/apps/bio/bin/bedtools      #
ph4=/cineca/prod/opt/applications/fastqc/0.11.5/jre--1.8.0_111--binary/bin/fastqc
ph5=/galileo/home/userexternal/mcocca00/bin/trim_galore 



### - PATH SCRIPT / Log - ###
lg=\${base_out}/Log
hs=${HOME}/scripts/pipelines/VariantCalling

EOF

}

function build_runner_all(){

param_file=$1

cat << EOF
#!/usr/bin/env bash
#

#Runner for the data preparation pipeline with default parameter file and default steps
source ${param_file}
#source functions file
source \${hs}/pipeline_functions.sh

#log folders creation
mkdir -p \${lg}

#step 1
#IN unknow BAM OUT check and stat info /// ValidateSamFile, flagstat, view
echo "bash \${hs}/01.preGATK4_step1.sh ${param_file}" | qsub -N pGs01_\${SM} -cwd -l h_vmem=\${seq_m} -o \${lg}/\\\$JOB_ID_pG01_\${SM}.log -e \${lg}/\\\$JOB_ID_pG01_\${SM}.error -m a -M \${mail} -q \${sge_q}

#step 2
#IN BAM OUT uBAM /// RevertSam, ValidateSamFile
echo "bash \${hs}/02.preGATK4_step2.sh ${param_file}" | qsub -N pGs02_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs01_\${SM} -o \${lg}/\\\$JOB_ID_pG02_\${SM}.log -e \${lg}/\\\$JOB_ID_pG02_\${SM}.error -m a -M \${mail} -q \${sge_q}

#step 3
#IN uBAM OUT fastq, fastqc /// bamtofastq, gzip, fastqc
echo "bash \${hs}/03.preGATK4_step3.sh ${param_file}" | qsub -N pGs03_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs02_\${SM} -o \${lg}/\\\$JOB_ID_pG03_\${SM}.log -e \${lg}/\\\$JOB_ID_pG03_\${SM}.error -m ea -M \${mail} -q \${sge_q}

#step 4
#IN fastq OUT fastqc /// fastqc
echo "bash \${hs}/04.preGATK4_step4.sh ${param_file}" | qsub -N pGs04_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs03_\${SM} -o \${lg}/\\\$JOB_ID_pG04_\${SM}.log -e \${lg}/\\\$JOB_ID_pG04_\${SM}.error -m ea -M \${mail} -q \${sge_q}

#step 5
#IN fastq OUT val /// trim_galore
echo "bash \${hs}/05.preGATK4_step5.sh ${param_file}" | qsub -N pGs05_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs04_\${SM} -o \${lg}/\\\$JOB_ID_pG05_\${SM}.log -e \${lg}/\\\$JOB_ID_pG05_\${SM}.error -m a -M \${mail} -q \${sge_q}

#step 6
#IN val OUT fastqc /// fastqc
echo "bash \${hs}/06.preGATK4_step6.sh ${param_file}" | qsub -N pGs06_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs05_\${SM} -o \${lg}/\\\$JOB_ID_pG06_\${SM}.log -e \${lg}/\\\$JOB_ID_pG06_\${SM}.error -m ea -M \${mail} -q \${sge_q}

echo " --- END PIPELINE ---"

EOF
  
}


function build_runner_fastq(){

#this runner is to use when we start from unaligned fastq files
param_file=$1

cat << EOF
#!/usr/bin/env bash
#

#Runner for the data preparation pipeline with default parameter file and default steps
source ${param_file}
#source functions file
source \${hs}/pipeline_functions.sh

#log folders creation
mkdir -p \${lg}

#Since we work with fast files, we will skip steps 1 to 4

#step 4
#IN fastq OUT fastqc /// fastqc
echo "bash \${hs}/04.preGATK4_step4.sh ${param_file}" | qsub -N pGs04_\${SM} -cwd -l h_vmem=\${seq_m} -o \${lg}/\\\$JOB_ID_pG04_\${SM}.log -e \${lg}/\\\$JOB_ID_pG04_\${SM}.error -m ea -M \${mail} -q \${sge_q}

#step 5
#IN fastq OUT val /// trim_galore
echo "bash \${hs}/05.preGATK4_step5.sh ${param_file}" | qsub -N pGs05_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs04_\${SM} -o \${lg}/\\\$JOB_ID_pG05_\${SM}.log -e \${lg}/\\\$JOB_ID_pG05_\${SM}.error -m a -M \${mail} -q \${sge_q}

#step 6
#IN val OUT fastqc /// fastqc
echo "bash \${hs}/06.preGATK4_step6.sh ${param_file}" | qsub -N pGs06_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs05_\${SM} -o \${lg}/\\\$JOB_ID_pG06_\${SM}.log -e \${lg}/\\\$JOB_ID_pG06_\${SM}.error -m ea -M \${mail} -q \${sge_q}

echo " --- END PIPELINE ---"

EOF

}


function build_runner_fastq_cineca(){

#this runner is to use when we start from unaligned fastq files
param_file=$1

cat << EOF
#!/usr/bin/env bash
#

#Runner for the data preparation pipeline with default parameter file and default steps
source ${param_file}
#source functions file
source \${hs}/pipeline_functions.sh

#log folders creation
mkdir -p \${lg}

#Since we work with fast files, we will skip steps 1 to 4

#step 4
#IN fastq OUT fastqc /// fastqc
# echo "bash \${hs}/04.preGATK4_step4.sh ${param_file}" | qsub -N pGs04_\${SM} -cwd -l h_vmem=\${seq_m} -o \${lg}/\\\$JOB_ID_pG04_\${SM}.log -e \${lg}/\\\$JOB_ID_pG04_\${SM}.error -m ea -M \${mail} -q \${sge_q}
# jid_step_4_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=96:00:00 -e \${lg}/%j_pG04_\${SM}.error -o \${lg}/%j_pG04_\${SM}.log --mem=\${seq_m} -J "pGs04_\${SM}" --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/04.preGATK4_step4.sh ${param_file})
# jid_step_4=\$(echo \${jid_step_4_m}| cut -f 4 -d " ")

#step 5
#IN fastq OUT val /// trim_galore
# echo "bash \${hs}/05.preGATK4_step5.sh ${param_file}" | qsub -N pGs05_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs04_\${SM} -o \${lg}/\\\$JOB_ID_pG05_\${SM}.log -e \${lg}/\\\$JOB_ID_pG05_\${SM}.error -m a -M \${mail} -q \${sge_q}
# jid_step_5_m=\$(sbatch --partition=\${sge_q} -e \${lg}/%j_pG05_\${SM}.error -o \${lg}/%j_pG05_\${SM}.log --mem=\${seq_m} -J "pGs05_\${SM}" --dependency=afterok:\${jid_step_4} --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/05.preGATK4_step5.sh ${param_file})
jid_step_5_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=96:00:00 -e \${lg}/%j_pG05_\${SM}.error -o \${lg}/%j_pG05_\${SM}.log --mem=\${seq_m} -J "pGs05_\${SM}" --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/05.preGATK4_step5.sh ${param_file})
jid_step_5=\$(echo \${jid_step_5_m}| cut -f 4 -d " ")

#step 6
#IN val OUT fastqc /// fastqc
# echo "bash \${hs}/06.preGATK4_step6.sh ${param_file}" | qsub -N pGs06_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs05_\${SM} -o \${lg}/\\\$JOB_ID_pG06_\${SM}.log -e \${lg}/\\\$JOB_ID_pG06_\${SM}.error -m ea -M \${mail} -q \${sge_q}
jid_step_6_m=\$(sbatch --partition=\${sge_q} --account=uts19_dadamo --time=96:00:00 -e \${lg}/%j_pG06_\${SM}.error -o \${lg}/%j_pG06_\${SM}.log --mem=\${seq_m} -J "pGs06_\${SM}" --dependency=afterok:\${jid_step_5} --get-user-env -n 1 --mail-type END,FAIL --mail-user \${mail} \${hs}/06.preGATK4_step6.sh ${param_file})


echo " --- END PIPELINE ---"

EOF

}


if [ $# -lt 1 ]
then
    echo "#########################"
    echo "WRONG argument number!"
    echo "Usage:"
    echo "data_prep_config_file_creation.sh -i <input_file_folder> "
    echo "                   -t <template_folder> "
    echo "                   -o <output_folder> "
    echo "                   -s <sample_name> "
    echo "                   -1: Provide fastq file name for R1."
    echo "                   -2: Provide fastq file name for R2."
    echo "                   -n: Execution host full name"
    echo "                   -j: Execution queue name: it is possible to use the format <queue>@<hostname>, to select a specific host for execution.(In SGE mode only)"
    echo "                  [-m <mail_address>] "
    echo "                  [-f (toggle fastq format only pipeline)]"
    echo "                  [-c (toggle CINECA SLURM pipeline builder functions)]"
    echo "#########################"
    exit 1
fi

#ARGS
# template_dir=$1
# out_dir=$2

suffix=`date +"%d%m%Y%H%M%S"`

echo "${@}"
while getopts ":t:o:s:h:m:i:n:j:1:2:cf" opt ${@}; do
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
        echo "data_prep_config_file_creation.sh -i <input_file_folder> "
        echo "                   -t <template_folder> "
        echo "                   -o <output_folder> "
        echo "                   -s <sample_name> "
        echo "                   -1: Provide fastq file name for R1."
        echo "                   -2: Provide fastq file name for R2."
        echo "                   -n: Execution host full name"
        echo "                   -j: Execution queue name: it is possible to use the format <queue>@<hostname>, to select a specific host for execution.(In SGE mode only)"
        echo "                  [-m <mail_address>] "
        echo "                  [-f (toggle fastq format only pipeline)]"
        echo "                  [-c (toggle CINECA SLURM pipeline builder functions)]"
        echo "#########################"
        exit 1
        ;;
    i)
      echo ${OPTARG}
      input_file_folder=${OPTARG}
    ;;
    f)
      echo "Fastq formatted data"
      fastq_mode=1
      ;;  
    c)
      echo "Working on CINECA SLURM cluster"
      cineca_mode=1
      ;;  
    m)
    echo ${OPTARG}
    mail_to=${OPTARG}
    ;;
    1)
      r1_fq_file=${OPTARG}
      echo "Use specified fastq file name: ${r1_fq_file}"
    ;;
    2)
      r2_fq_file=${OPTARG}
      echo "Use specified fastq file name: ${r2_fq_file}"
    ;;
    n)
    # specify execution node
    exec_host=${OPTARG}
    ;;
    j)
    #specify queue name, also in the form queue@exec_host
    exec_queue=${OPTARG}
    ;;
    *)
      echo $opt
    ;;
  esac

done

mkdir -p ${out_dir}
mkdir -p ${template_dir}


if [[ ${fastq_mode} -eq 1 ]]; then
  #statements
  # build_template_fastq ${out_dir} ${sample_name} ${mail_to} ${input_file_folder} > ${template_dir}/DataPrep_${suffix}.conf
  build_template_fastq ${out_dir} ${sample_name} ${mail_to} > ${template_dir}/DataPrep_${suffix}.conf
  if [[ ${cineca_mode} -eq 1 ]]; then
    build_runner_fastq_cineca ${template_dir}/DataPrep_${suffix}.conf > ${template_dir}/DataPrepRunner_${suffix}.sh
  else
    build_runner_fastq ${template_dir}/DataPrep_${suffix}.conf > ${template_dir}/DataPrepRunner_${suffix}.sh
  fi
else
  # build_template_all ${out_dir} ${sample_name} ${mail_to} ${input_file_folder} > ${template_dir}/DataPrep_${suffix}.conf
  build_template_all ${out_dir} ${sample_name} ${mail_to} > ${template_dir}/DataPrep_${suffix}.conf
  build_runner_all ${template_dir}/DataPrep_${suffix}.conf > ${template_dir}/DataPrepRunner_${suffix}.sh
fi

echo "Template file ${template_dir}/DataPrep_${suffix}.conf created. You can edit it to modify any non default parameter."
echo "Runner file ${template_dir}/DataPrepRunner_${suffix}.sh created. You can edit it to modify any non default parameter."


