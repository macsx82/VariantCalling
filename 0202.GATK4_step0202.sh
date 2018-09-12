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
source ${own_folder}/pipeline_functions.sh
### - CODE - ###

#2a
echo
# cd ${fol1}/
echo "> RGI ID data"
zcat ${fol0}/${val1} | head -n1 | sed 's/ /:/g' | sed 's/@//g' > "${fol1}/${SM}_header"; cat "${fol1}/${SM}_header"
PU1=$(cat "${fol1}/${SM}_header" | cut -d":" -f1); echo ${PU1}
PU2=$(cat "${fol1}/${SM}_header" | cut -d":" -f2); echo ${PU2}

echo "- END -"

#2b
echo
# cd ${fol1}/
case ${read_mode} in
    long )
        echo "> Read unmapped BAM, convert on-the-fly to FASTQ and stream to BWA MEM for alignment"
        java -Dsamjdk.compression_level=${cl} ${java_opt2x} -jar ${PICARD} SamToFastq INPUT=${fol1}/${uBAM} FASTQ=/dev/stdout INTERLEAVE=true NON_PF=true TMP_DIR=${tmp}/ | ${BWA} mem -R "@RG\tID:${PU1}.${PU2}\tSM:${SM}\tLB:${LB}\tPL:${PL}" -K 100000000 -p -v 3 -t ${thr} -Y ${GNMhg38} /dev/stdin | ${SAMTOOLS} view -1 - > ${fol1}/${bBAM}
    ;;
    short )
        echo "> Read unmapped BAM, convert on-the-fly to FASTQ and stream to BWA MEM for alignment"
        java -Dsamjdk.compression_level=${cl} ${java_opt2x} -jar ${PICARD} SamToFastq INPUT=${fol1}/${uBAM} FASTQ=/dev/stdout INTERLEAVE=true NON_PF=true TMP_DIR=${tmp}/ | ${BWA} mem -R "@RG\tID:${PU1}.${PU2}\tSM:${SM}\tLB:${LB}\tPL:${PL}" -K 100000000 -p -v 3 -t ${thr} -Y ${GNMhg38} /dev/stdin | ${SAMTOOLS} view -1 - > ${fol1}/${bBAM}
    ;;
    *)
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
echo
# call the sam_stats function
sam_stats ${fol1}/${bBAM}

#del
echo
rm -v ${fol1}/"${SM}_header"

#generate a file that will tell us if the step is completed
touch step0202.done
# exit



