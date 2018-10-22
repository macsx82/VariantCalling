#!/usr/bin/env bash
set -e

echo "> pipeline: Το χρυσόμαλλο δέρας"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt1"
echo

### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${own_folder}/pipeline_functions.sh
### - CODE - ###
mkdir -p ${fol3}
#3a
echo
echo "> from uBAM to fastq"
${ph3} bamtofastq -i ${fol2}/${ubam} -fq ${fol2}/${fastq1} -fq2 ${fol2}/${fastq2}
echo "- END -"

#Compress
echo
echo "> gzip fastq file"
gzip ${fol2}/${fastq1}
gzip ${fol2}/${fastq2}
echo "- END -"

#3b
echo
echo "> Fastq QC control"
${ph4} "${fol2}/${fastq1}.gz" -o ${fol3}/
${ph4} "${fol2}/${fastq2}.gz" -o ${fol3}/
echo "- END -"

#del
echo
# rm -v ${fol1}/"${SM}.bam"
# rm -v ${fol1}/"${SM}.bam.bai"
# rm -v ${fol2}/"${SM}_unmap.bam"
# rm -v ${fol3}/"${SM}_1_fastqc.zip"
# rm -v ${fol3}/"${SM}_2_fastqc.zip"

touch data_prep03.done



