#!/usr/bin/env bash
set -e


echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt1"
echo

### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1
source ${param_file}
#source functions file
own_folder=`dirname $0`
source ${hs}/pipeline_functions.sh
### - CODE - ###
mkdir -p ${fol1} ${fol2} ${fol3} ${fol4} ${fol5} ${fol6} #${fol7} ${fol8} ${fol9}

#2a
echo
# cd ${fol1}/
echo "> RGI ID data"
zcat ${fol0}/${val1} | head -n1 | sed 's/ /:/g' | sed 's/@//g'
PU1=$(zcat ${fol0}/${val1} | head -n1 | sed 's/ /:/g' | sed 's/@//g'| cut -d":" -f1)
PU2=$(zcat ${fol0}/${val1} | head -n1 | sed 's/ /:/g' | sed 's/@//g'| cut -d":" -f2)
echo ${PU1}
echo ${PU2}

echo "- END -"


#2b
echo
# cd ${fol1}/
case ${read_mode} in
    long )
        # echo "> Read unmapped BAM, convert on-the-fly to FASTQ and stream to BWA MEM for alignment"
        # java -Dsamjdk.compression_level=${cl} ${java_opt2x} -XX:+UseSerialGC -jar ${PICARD} SamToFastq INPUT=${fol1}/${uBAM} FASTQ=/dev/stdout INTERLEAVE=true NON_PF=true TMP_DIR=${tmp}/ | ${BWA} mem -R "@RG\tID:${PU1}.${PU2}\tSM:${SM}\tLB:${LB}\tPL:${PL}" -K 10000000 -p -v 3 -t ${thr} -Y ${GNMhg38} /dev/stdin | ${SAMTOOLS} view -1 - > ${fol1}/${bBAM}
        echo "> Align FASTQ files with BWA MEM"
        # -@ $[thr - 1] we will adjust the number of threads used for compression 
        ${BWA} mem -R "@RG\tID:${PU1}.${PU2}\tSM:${SM}\tLB:${LB}\tPL:${PL}" -K 10000000 -v 3 -t ${thr} -Y ${GNMhg38} ${fol0}/${val1} ${fol0}/${val2} | ${SAMTOOLS} view -1 -o ${fol1}/${bBAMu}
        #need to add a sorting step
        ${SAMTOOLS} sort -@ ${thr} -o ${fol1}/${bBAM} ${fol1}/${bBAMu}
    ;;  
    short )
        echo "> Align short reads with bwa-backtrack starting from FASTQ"
        # bwa aln ref.fa -b1 reads.bam > 1.sa
        # bwa aln ref.fa -b2 reads.bam > 2.sai
        # bwa sampe ref.fa 1.sai 2.sai reads.bam reads.bam > aln.sam 
        # bwa aln -t ${thr} ${GNMhg38} -b1 ${fol1}/${uBAM} > ${fol1}/${uBAM}_1.sai
        # bwa aln -t ${thr} ${GNMhg38} -b2 ${fol1}/${uBAM} > ${fol1}/${uBAM}_2.sai
        bwa aln -t ${thr} ${GNMhg38} ${fol0}/${val1} > ${fol1}/${uBAM}_1.sai
        bwa aln -t ${thr} ${GNMhg38} ${fol0}/${val2} > ${fol1}/${uBAM}_2.sai
        bwa sampe -r "@RG\tID:${PU1}.${PU2}\tSM:${SM}\tLB:${LB}\tPL:${PL}" ${GNMhg38} ${fol1}/${uBAM}_1.sai ${fol1}/${uBAM}_2.sai ${fol1}/${uBAM} ${fol1}/${uBAM} | ${SAMTOOLS} view -1 -o ${fol1}/${bBAM}
    ;;
    * )
    echo "The read mode selected ${read_mode} is not one of the allowed options: specify long or short read alignment method to be used"
    exit 1
    ;;
esac

echo "- END -"

#Validation
echo
# call the sam_validate function
echo "> Validation bBAM"
sam_validate ${fol1}/${bBAM}

#Stat
echo "> Calculate stats"
# call the sam_stats function
sam_stats ${fol1}/${bBAM}

#generate a file that will tell us if the step is completed
touch step0202.done
# exit



