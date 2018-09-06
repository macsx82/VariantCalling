#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt1"
echo

### - VARIABILI FISSE - ###
SM=$1					#sample name
uBAM="${SM}_unmapped.bam"		#unmapped bam
bBAM="${SM}_bwa.bam"			#mapped bam
mBAM="${SM}_merged.bam"			#merge unmapped bam and mapped bam
mdBAM="${SM}_markdup.bam"		#mark dupplicates of the merged bam
metfile="${SM}_dupmetrics.txt"		#metrics file
fBAM="${SM}_fixed.bam"			#sorted and fixed file
fBAMs="${SM}_fixedsort.bam"		#fixed sorted bam
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - CODE - ###

#3
echo
cd ${fol1}/
echo "> Merge original input uBAM file with BWA-aligned BAM file"
java -Dsamjdk.compression_level=${cl} ${java_opt2x} -jar ${PICARD} MergeBamAlignment VALIDATION_STRINGENCY=SILENT ORIENTATIONS=FR ATTRIBUTES_TO_RETAIN=X0 UNMAPPED=${uBAM} ALIGNED=${bBAM} O=${mBAM} R=${GNMhg38} PE=true SO=unsorted IS_BISULFITE_SEQUENCE=false ALIGNED_READS_ONLY=false CLIP_ADAPTERS=false MAX_RECORDS_IN_RAM=2000000 MC=true MAX_GAPS=-1 PRIMARY_ALIGNMENT_STRATEGY=MostDistant UNMAPPED_READ_STRATEGY=COPY_TO_TAG ALIGNER_PROPER_PAIR_FLAGS=true UNMAP_CONTAM=true TMP_DIR=${tmp}/
echo "- END -"

#Stat
echo
cd ${fol1}/
${SAMTOOLS} flagstat ${mBAM}
echo
${SAMTOOLS} view -H ${mBAM} | grep '@RG'
echo
${SAMTOOLS} view -H ${mBAM} | grep '@PG'
echo "- END -"

#4
echo
cd ${fol1}/
echo "> Mark duplicate reads to avoid counting non-independent observations"
java -Dsamjdk.compression_level=${cl} ${java_opt2x} -jar ${PICARD} MarkDuplicates INPUT=${mBAM} OUTPUT=${mdBAM} METRICS_FILE=${metfile} VALIDATION_STRINGENCY=SILENT OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 ASSUME_SORT_ORDER=queryname CREATE_MD5_FILE=true TMP_DIR=${tmp}/
echo "- END -"

#Stat
echo
cd ${fol1}/
${SAMTOOLS} flagstat ${mdBAM}
echo
${SAMTOOLS} view -H ${mdBAM} | grep '@RG'
echo
${SAMTOOLS} view -H ${mdBAM} | grep '@PG'
echo "- END -"

#5
echo
cd ${fol1}/
echo "> Sort BAM file by coordinate order and fix tag values for NM, MD and UQ"
java -Dsamjdk.compression_level=${cl} ${java_opt2x} -jar ${PICARD} SortSam INPUT=${mdBAM} O=/dev/stdout SORT_ORDER=coordinate CREATE_INDEX=false CREATE_MD5_FILE=false TMP_DIR=${tmp}/ | java -Dsamjdk.compression_level=${cl} ${java_opt2x} -jar ${PICARD} SetNmMdAndUqTags R=${GNMhg38} INPUT=/dev/stdin O=${fBAM} CREATE_INDEX=true CREATE_MD5_FILE=true TMP_DIR=${tmp}/
echo "- END -"

#Validation
echo
cd ${fol1}/
echo "> Validation fBAM"
java -jar ${PICARD} ValidateSamFile I=${fBAM} MODE=SUMMARY TMP_DIR=${tmp}/
echo "- END -"

#Stat
echo
cd ${fol1}/
${SAMTOOLS} flagstat ${fBAM}
echo
${SAMTOOLS} view -H ${fBAM} | grep '@RG'
echo
${SAMTOOLS} view -H ${fBAM} | grep '@PG'
echo "- END -"

#Sort BAM
echo
cd ${fol1}/
echo "> Sort BAM file"
${SAMTOOLS} sort ${fBAM} -o ${fol2}/${fBAMs} -@ 4
echo "- END -"

#Cov - counting 0 -
echo
cd ${fol2}/
echo "> Coverage - counting also the base coverage at 0 "
${SAMTOOLS} depth -aa -b ${EXONS} ${fBAMs} > "${SM}_${hg}_WITH_0x_EXONSxBaseCov.bed"
for chr in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y; do echo "-- chr$chr --"; bases=`(grep chr$chr "${SM}_${hg}_WITH_0x_EXONSxBaseCov.bed" | wc -l)`; echo "EXONS target length=$bases"; cov=`(grep chr$chr "${SM}_${hg}_WITH_0x_EXONSxBaseCov.bed" | awk '{sum+=$3} END {print sum}')`; echo "sum EXONS bases coverage WITH 0x=$cov"; avercov=$(($cov/$bases)); echo "EXONS average coverage=$avercov"; done >> ${SM}_${hg}_WITH_0x_EXONScovstats.txt
echo "- END -"

#Compress - counting 0 -
cd ${fol2}/
echo "> gzip files"
gzip ${SM}_${hg}_WITH_0x_EXONSxBaseCov.bed
gzip ${SM}_${hg}_WITH_0x_EXONScovstats.txt
echo "- END -"

#Cov - WITHOUT counting 0 -
echo
cd ${fol2}/
echo "> Coverage - without counting also the base coverage at 0"
${SAMTOOLS} depth -a -b ${EXONS} ${fBAMs} > "${SM}_${hg}_WITHOUT_0x_EXONSxBaseCov.bed"
for chr in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y; do echo "-- chr$chr --"; bases=`(grep chr$chr "${SM}_${hg}_WITHOUT_0x_EXONSxBaseCov.bed" | wc -l)`; echo "EXONS target length=$bases"; cov=`(grep chr$chr "${SM}_${hg}_WITHOUT_0x_EXONSxBaseCov.bed" | awk '{sum+=$3} END {print sum}')`; echo "sum EXONS bases coverage WITHOUT 0x=$cov"; avercov=$(($cov/$bases)); echo "EXONS average coverage=$avercov"; done >> ${SM}_${hg}_WITHOUT_0x_EXONScovstats.txt
echo "- END -"

#Compress - WITHOUT counting 0 -
cd ${fol2}/
echo "> gzip files"
gzip ${SM}_${hg}_WITHOUT_0x_EXONSxBaseCov.bed
gzip ${SM}_${hg}_WITHOUT_0x_EXONScovstats.txt
echo "- END -"

#del
echo
rm -v ${fol1}/"${SM}_bwa.bam"
rm -v ${fol1}/"${SM}_dupmetrics.txt"
rm -v ${fol1}/"${SM}_markdup.bam"
rm -v ${fol1}/"${SM}_markdup.bam.md5"
rm -v ${fol1}/"${SM}_merged.bam"
rm -v ${fol1}/"${SM}_unmapped.bam"
rm -v ${fol2}/"${SM}_fixedsort.bam"

exit



