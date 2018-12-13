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
mkdir -p ${fol1} ${fol2} ${fol3} ${fol4} ${fol5} ${fol6} #${fol7} ${fol8} ${fol9}
#3
echo
# cd ${fol1}/
echo "> Merge original input uBAM file with BWA-aligned BAM file"
java -Dsamjdk.compression_level=${cl} ${java_opt2x} -XX:+UseSerialGC -jar ${PICARD} MergeBamAlignment VALIDATION_STRINGENCY=SILENT ORIENTATIONS=FR ATTRIBUTES_TO_RETAIN=X0 UNMAPPED=${fol1}/${uBAM} ALIGNED=${fol1}/${bBAM} O=${fol1}/${mBAM} R=${GNMhg38} PE=true SO=unsorted IS_BISULFITE_SEQUENCE=false ALIGNED_READS_ONLY=false CLIP_ADAPTERS=false MAX_RECORDS_IN_RAM=2000000 MC=true MAX_GAPS=-1 PRIMARY_ALIGNMENT_STRATEGY=MostDistant UNMAPPED_READ_STRATEGY=COPY_TO_TAG ALIGNER_PROPER_PAIR_FLAGS=true UNMAP_CONTAM=true TMP_DIR=${tmp}/
echo "- END -"

#Stat
echo
# call the sam_stats function
sam_stats ${fol1}/${mBAM}

#4
echo
# cd ${fol1}/
echo "> Mark duplicate reads to avoid counting non-independent observations"
java -Dsamjdk.compression_level=${cl} ${java_opt2x} -XX:+UseSerialGC -jar ${PICARD} MarkDuplicates INPUT=${fol1}/${mBAM} OUTPUT=${fol1}/${mdBAM} METRICS_FILE=${fol1}/${metfile} VALIDATION_STRINGENCY=SILENT OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 ASSUME_SORT_ORDER=queryname CREATE_MD5_FILE=true TMP_DIR=${tmp}/
echo "- END -"

#Stat
echo
# call the sam_stats function
sam_stats ${fol1}/${mdBAM}

#5
echo
# cd ${fol1}/
echo "> Sort BAM file by coordinate order and fix tag values for NM, MD and UQ"
java -Dsamjdk.compression_level=${cl} ${java_opt2x} -XX:+UseSerialGC -jar ${PICARD} SortSam INPUT=${fol1}/${mdBAM} O=/dev/stdout SORT_ORDER=coordinate CREATE_INDEX=false CREATE_MD5_FILE=false TMP_DIR=${tmp}/ | java -Dsamjdk.compression_level=${cl} ${java_opt2x} -jar ${PICARD} SetNmMdAndUqTags R=${GNMhg38} INPUT=/dev/stdin O=${fol1}/${fBAM} CREATE_INDEX=true CREATE_MD5_FILE=true TMP_DIR=${tmp}/
echo "- END -"

#Validation
echo
# cd ${fol1}/
# call the sam_validate function
echo "> Validation fBAM"
sam_validate ${fol1}/${fBAM}

#Stat
echo
# call the sam_stats function
sam_stats ${fol1}/${fBAM}

#Sort BAM
echo
# cd ${fol1}/
echo "> Sort BAM file"
${SAMTOOLS} sort ${fol1}/${fBAM} -o ${fol2}/${fBAMs}
echo "- END -"

#Cov - counting 0 -
echo
echo "> Coverage - counting also the base coverage at 0 "
${SAMTOOLS} depth -aa -b ${EXONS} ${fol2}/${fBAMs} | gzip -c > ${fol2}/${SM}_${hg}_WITH_0x_EXONSxBaseCov.bed.gz
(for chr in {1..22} X Y
do
    echo "-- chr$chr --";
    bases=`(zgrep chr$chr ${fol2}/${SM}_${hg}_WITH_0x_EXONSxBaseCov.bed.gz | wc -l)`;
    echo "EXONS target length=${bases}";
    cov=`(zgrep chr$chr ${fol2}/${SM}_${hg}_WITH_0x_EXONSxBaseCov.bed.gz | awk '{sum+=$3} END {print sum}')`;
    echo "sum EXONS bases coverage WITH 0x=$cov";
    avercov=$((${cov}/${bases}));
    echo "EXONS average coverage=${avercov}";
done ) | gzip -c > ${fol2}/${SM}_${hg}_WITH_0x_EXONScovstats.txt.gz

echo "- END -"

#Cov - WITHOUT counting 0 -
echo
echo "> Coverage - without counting the base coverage at 0"
${SAMTOOLS} depth -a -b ${EXONS} ${fol2}/${fBAMs}| gzip -c > ${fol2}/${SM}_${hg}_WITHOUT_0x_EXONSxBaseCov.bed.gz
(for chr in {1..22} X Y;
do
    echo "-- chr$chr --"
    bases=`(zgrep chr$chr ${fol2}/${SM}_${hg}_WITHOUT_0x_EXONSxBaseCov.bed.gz | wc -l)`
    echo "EXONS target length=$bases"
    cov=`(zgrep chr$chr ${fol2}/${SM}_${hg}_WITHOUT_0x_EXONSxBaseCov.bed.gz | awk '{sum+=$3} END {print sum}')`
    echo "sum EXONS bases coverage WITHOUT 0x=$cov"
    avercov=$(($cov/$bases))
    echo "EXONS average coverage=$avercov"

done ) | gzip -c > ${fol2}/${SM}_${hg}_WITHOUT_0x_EXONScovstats.txt.gz
echo "- END -"

#del
echo "Cleaning some files..."
# rm -v ${fol1}/"${SM}_bwa.bam"
# rm -v ${fol1}/"${SM}_dupmetrics.txt"
# rm -v ${fol1}/"${SM}_markdup.bam"
# rm -v ${fol1}/"${SM}_markdup.bam.md5"
rm -v ${fol1}/"${SM}_merged.bam"
# rm -v ${fol1}/"${SM}_unmapped.bam"
rm -v ${fol2}/"${SM}_fixedsort.bam"

#generate a file that will tell us if the step is completed
touch step0305.done
# exit



