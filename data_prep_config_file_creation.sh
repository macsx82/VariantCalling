#!/usr/bin/env bash

#####################################
#This script is going to be used to create param file with custom variables and path that will be used by all the pipeline scripts


function build_template_all(){

cat << EOF
### - VARIABILI FISSE - ###
#step1
SM=$2         #sample name
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
cR1=14        #cut 5'
cR2=14        #cut 5'
tpcR1=3       #cut 3'
tpcR2=3       #cut 3'
#-#-#
java_opt1x=-Xmx10g    #java memory requirement

#########SET UP YOUR EMAIL HERE ##############
mail=$3
#########SET UP YOUR EMAIL HERE ##############

### - PATH FILE - ###
base_out=$1
tmp=/home/${USER}/localtemp

### - PATH FOLDER - ###
fol1=\${base_out}/1.bam
fol2=\${base_out}/2.fastq_pre
fol3=\${base_out}/3.fastqc
fol4=\${base_out}/4.fastq_post
fol5=\${base_out}/Storage

### - PATH TOOL - ###
PICARD=/share/apps/bio/picard-2.17.3/picard.jar    #
SAMTOOLS=/share/apps/bio/samtools/samtools     #
ph3=/share/apps/bio/bin/bedtools      #
ph4=/share/apps/bio/miniconda2/bin/fastqc   #
ph5=/share/apps/bio/miniconda2/bin/trim_galore    #

### - PATH SCRIPT / Log - ###
lg=\${base_out}/Log
hs=\${base_out}/0.pipe

EOF

}


function build_template_fastq(){

cat << EOF

############################################
#Template to pre-process fastq files
### - VARIABILI FISSE - ###
#step4
SM=$2         #sample name

#Template to pre-process fastq files
# MODIFY FASTQ PATH HERE
#
fastq1=\".......\"      #fastq 1
fastq2=\".......\"      #fastq 2

#step6
val1="\${SM}_1_val_1.fq.gz"    
val2="\${SM}_2_val_2.fq.gz"  

### - Pipeline parameters - ###
# MODIFY THESE VALUES TO WORK WITH NON DEFAULT PARAMETERS
q=20        #quality
e=0.1       #error rate
cR1=14        #cut 5'
cR2=14        #cut 5'
tpcR1=3       #cut 3'
tpcR2=3       #cut 3'
#-#-#
java_opt1x=-Xmx10g    #java memory requirement

#########SET UP YOUR EMAIL HERE ##############
mail=$3
#########SET UP YOUR EMAIL HERE ##############


### - PATH FILE - ###
base_out=$1
tmp=/home/${USER}/localtemp

### - PATH FOLDER - ###
fol1=${base_out}/1.bam
fol2=${base_out}/2.fastq_pre
fol3=${base_out}/3.fastqc
fol4=${base_out}/4.fastq_post
fol5=${base_out}/Storage

### - PATH TOOL - ###
PICARD=/share/apps/bio/picard-2.17.3/picard.jar    #
SAMTOOLS=/share/apps/bio/samtools/samtools     #
ph3=/share/apps/bio/bin/bedtools      #
ph4=/share/apps/bio/miniconda2/bin/fastqc   #
ph5=/share/apps/bio/miniconda2/bin/trim_galore    #

### - PATH SCRIPT / Log - ###
lg=\${base_out}/Log
hs=\${base_out}/0.pipe

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
own_folder=\`dirname \$0\`
source \${own_folder}/pipeline_functions.sh

#output folders creation
mkdir -p \${fol1} \${fol2} \${fol3} \${fol4} \${fol5} \${lg}

#step 1
echo "bash \${hs}/01.preGATK4_step1.sh ${param_file}" | qsub -N pGs01_\${SM} -cwd -l h_vmem=20G -o \${lg}/pG01_\${SM}.log -e \${lg}/pG01_\${SM}.error -m a -M \${mail} #IN unknow BAM OUT check and stat info /// ValidateSamFile, flagstat, view

#step 2
echo "bash \${hs}/02.preGATK4_step2.sh ${param_file}" | qsub -N pGs02_\${SM} -cwd -l h_vmem=20G -hold_jid pGs01_\${SM} -o \${lg}/pG02_\${SM}.log -e \${lg}/pG02_\${SM}.error -m a -M \${mail} #IN BAM OUT uBAM /// RevertSam, ValidateSamFile

#step 3
echo "bash \${hs}/03.preGATK4_step3.sh ${param_file}" | qsub -N pGs03_\${SM} -cwd -l h_vmem=20G -hold_jid pGs02_\${SM} -o \${lg}/pG03_\${SM}.log -e \${lg}/pG03_\${SM}.error -m ea -M \${mail} #IN uBAM OUT fastq, fastqc /// bamtofastq, gzip, fastqc

#step 4
echo "bash \${hs}/04.preGATK4_step4.sh ${param_file}" | qsub -N pGs04_\${SM} -cwd -l h_vmem=20G -hold_jid pGs03_\${SM} -o \${lg}/pG04_\${SM}.log -e \${lg}/pG04_\${SM}.error -m ea -M \${mail} #IN fastq OUT fastqc /// fastqc

#step 5
echo "bash \${hs}/05.preGATK4_step5.sh ${param_file}" | qsub -N pGs05_\${SM} -cwd -l h_vmem=20G -hold_jid pGs04_\${SM} -o \${lg}/pG05_\${SM}.log -e \${lg}/pG05_\${SM}.error -m a -M \${mail} #IN fastq OUT val /// trim_galore

#step 6
echo "bash \${hs}/06.preGATK4_step6.sh ${param_file}" | qsub -N pGs06_\${SM} -cwd -l h_vmem=20G -hold_jid pGs05_\${SM} -o \${lg}/pG06_\${SM}.log -e \${lg}/pG06_\${SM}.error -m ea -M \${mail} #IN val OUT fastqc /// fastqc

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
own_folder=\`dirname \$0\`
source \${own_folder}/pipeline_functions.sh

#output folders creation
mkdir -p \${fol1} \${fol2} \${fol3} \${fol4} \${fol5} \${lg}

#Since we work with fast files, we will skip steps 1 to 4

#step 4
echo "bash \${hs}/04.preGATK4_step4.sh ${param_file}" | qsub -N pGs04_\${SM} -cwd -l h_vmem=20G -o \${lg}/pG04_\${SM}.log -e \${lg}/pG04_\${SM}.error -m ea -M \${mail} #IN fastq OUT fastqc /// fastqc

#step 5
echo "bash \${hs}/05.preGATK4_step5.sh ${param_file}" | qsub -N pGs05_\${SM} -cwd -l h_vmem=20G -hold_jid pGs04_\${SM} -o \${lg}/pG05_\${SM}.log -e \${lg}/pG05_\${SM}.error -m a -M \${mail} #IN fastq OUT val /// trim_galore

#step 6
echo "bash \${hs}/06.preGATK4_step6.sh ${param_file}" | qsub -N pGs06_\${SM} -cwd -l h_vmem=20G -hold_jid pGs05_\${SM} -o \${lg}/pG06_\${SM}.log -e \${lg}/pG06_\${SM}.error -m ea -M \${mail} #IN val OUT fastqc /// fastqc

echo " --- END PIPELINE ---"

EOF

}


if [ $# -lt 1 ]
then
    echo "#########################"
    echo "WRONG argument number!"
    echo "Usage:"
    echo "data_prep_config_file_creation.sh -t <template_folder> -o <output_folder> -s <sample_name> [-m <mail_address>] [-f (toggle fastq format only pipeline)]"
    echo "#########################"
    exit 1
fi

#ARGS
# template_dir=$1
# out_dir=$2

suffix=`date +"%d%m%Y%H%M%S"`

echo "${@}"
while getopts ":t:o:s:h:m:f" opt ${@}; do
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
        echo "data_prep_config_file_creation.sh -t <template_folder> -o <output_folder> -s <sample_name> [-m <mail_address>] [-f (toggle fastq format only pipeline)]"
        echo "#########################"
        exit 1
        ;;
    f)
      echo "Fastq formatted data"
      fastq_mode=1
      ;;  
    m)
    echo ${OPTARG}
    mail_to=${OPTARG}
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
  build_template_fastq ${out_dir} ${sample_name} ${mail_to} > ${template_dir}/DataPrep_${suffix}.conf
  build_runner_fastq ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/DataPrepRunner_${suffix}.sh
else
  build_template_all ${out_dir} ${sample_name} ${mail_to} > ${template_dir}/DataPrep_${suffix}.conf
  build_runner_all ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/DataPrepRunner_${suffix}.sh
fi

echo "Template file ${template_dir}/VarCall_${suffix}.conf created. You can edit it to modify any non default parameter."
echo "Runner file ${template_dir}/DataPrepRunner_${suffix}.sh created. You can edit it to modify any non default parameter."


