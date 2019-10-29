#!/usr/bin/env bash
#####################################################
# Original scripts from Athanasakis Emmanouil       #
# e-mail: emmanouil.athanasakis[at]burlo.trieste.it #
#                                                   #
# Mods by Massimiliano Cocca - 24/10/2019           #
# e-mail: massimiliano.cocca[at]burlo.trieste.it    #
#                                                   #
#                                                   #
#####################################################
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
mkdir -p ${fol1} ${fol2} ${fol3} ${fol4} ${fol5} ${fol6} ${tmp} #${fol7} ${fol8} ${fol9}

#5
echo "> Sort BAM file by coordinate order and generate the CRAM file: CRAM recalculates MD and NM tags on the fly, so we don't need to calculate them."
#Use Picard for sorting and NM and MD calculation on CINECA
# java -Dsamjdk.compression_level=${cl} ${java_opt2x} -XX:+UseSerialGC -jar ${PICARD} SortSam INPUT=${fol1}/${mdBAM} O=/dev/stdout SORT_ORDER=coordinate CREATE_INDEX=false CREATE_MD5_FILE=false TMP_DIR=${tmp}/ | java -Dsamjdk.compression_level=${cl} ${java_opt2x} -jar ${PICARD} SetNmMdAndUqTags R=${GNMhg38} INPUT=/dev/stdin O=${fol1}/${fBAM} CREATE_INDEX=true CREATE_MD5_FILE=true TMP_DIR=${tmp}/

#Use SAMTOOLS for sorting and NM and MD calculation on BURLO (or cluster without time limit)
#If we convert to CRAM files, btw, CRAM recalculates MD and NM tags on the fly, so we could simply sort the bam and convert it to CRAM
# ${SAMTOOLS} calmd -r -u ${fol1}/${mdBAM} ${GNMhg38} | ${SAMTOOLS} sort -T ${tmp}/ | ${SAMTOOLS} view -h -T ${GNMhg38} -C -o ${fol1}/${fCRAM}
${SAMTOOLS} sort -T ${tmp}/ ${fol1}/${mdBAM} | ${SAMTOOLS} view -h -T ${GNMhg38} -C -o ${fol1}/${fCRAM}

fCRAM_idx=${fCRAM%.*}
${SAMTOOLS} index ${fol1}/${fCRAM} ${fol1}/${fCRAM_idx}.bai

md5sum ${fol1}/${fCRAM} > ${fol1}/${fCRAM}.md5

echo "- END -"

# #Validation
# # We can validate only sam files, so we need to skip this step for CRAM

# # call the sam_validate function
# echo "> Validation fBAM"
# # sam_validate ${fol1}/${fBAM}
# sam_validate ${fol1}/${fCRAM}

# #Stat
# # call the sam_stats function
# # sam_stats ${fol1}/${fBAM}
# sam_stats ${fol1}/${fCRAM}


# if [[ -z ${EXONS} ]]; then
# 	#Coverage check in WGS mode
# 	echo "> Coverage - counting also the base coverage at 0 "
# 	# ${SAMTOOLS} depth -aa -b ${EXONS} ${fol2}/${fBAMs} | xz > ${fol2}/${SM}_${hg}_WITH_0x_EXONSxBaseCov.bed.xz
# 	# ${SAMTOOLS} depth -aa -b ${EXONS} ${fol1}/${fBAM} | xz > ${fol2}/${SM}_${hg}_WITH_0x_EXONSxBaseCov.bed.xz
# 	${SAMTOOLS} depth -aa ${fol1}/${fCRAM} | xz > ${fol2}/${SM}_${hg}_WITH_0x_WGSxBaseCov.bed.xz

# 	echo "- END -"

# 	#Cov - WITHOUT counting 0 -
# 	echo
# 	# ${SAMTOOLS} depth -a -b ${EXONS} ${fol2}/${fBAMs}| xz > ${fol2}/${SM}_${hg}_WITHOUT_0x_EXONSxBaseCov.bed.xz
# 	# ${SAMTOOLS} depth -a -b ${EXONS} ${fol1}/${fBAM}| xz > ${fol2}/${SM}_${hg}_WITHOUT_0x_EXONSxBaseCov.bed.xz
# 	echo "> Coverage - without counting the base coverage at 0"
# 	${SAMTOOLS} depth -a ${fol1}/${fCRAM}| xz > ${fol2}/${SM}_${hg}_WITHOUT_0x_WGSxBaseCov.bed.xz

# else
# 	#Coverage check in WES mode
# 	echo "> Coverage - counting also the base coverage at 0 "
# 	# ${SAMTOOLS} depth -aa -b ${EXONS} ${fol2}/${fBAMs} | xz > ${fol2}/${SM}_${hg}_WITH_0x_EXONSxBaseCov.bed.xz
# 	# ${SAMTOOLS} depth -aa -b ${EXONS} ${fol1}/${fBAM} | xz > ${fol2}/${SM}_${hg}_WITH_0x_EXONSxBaseCov.bed.xz
# 	${SAMTOOLS} depth -aa -b ${EXONS} ${fol1}/${fCRAM} | xz > ${fol2}/${SM}_${hg}_WITH_0x_EXONSxBaseCov.bed.xz

# 	echo "- END -"

# 	#Cov - WITHOUT counting 0 -
# 	echo
# 	# ${SAMTOOLS} depth -a -b ${EXONS} ${fol2}/${fBAMs}| xz > ${fol2}/${SM}_${hg}_WITHOUT_0x_EXONSxBaseCov.bed.xz
# 	# ${SAMTOOLS} depth -a -b ${EXONS} ${fol1}/${fBAM}| xz > ${fol2}/${SM}_${hg}_WITHOUT_0x_EXONSxBaseCov.bed.xz
# 	echo "> Coverage - without counting the base coverage at 0"
# 	${SAMTOOLS} depth -a -b ${EXONS} ${fol1}/${fCRAM}| xz > ${fol2}/${SM}_${hg}_WITHOUT_0x_EXONSxBaseCov.bed.xz
# fi
	
# echo "- END -"
# #del
# echo "Cleaning some files..."
# #Remove unmapped bam
# # rm -v ${fol1}/"${SM}_unmapped.bam"
# rm -v ${fol1}/${uBAM}
# # rm -v ${fol1}/${bBAM}
# #Remove merged bam
# # rm -v ${fol1}/"${SM}_merged.bam"
# rm -v ${fol1}/${mBAM}
# # rm -v ${fol1}/"${SM}_dupmetrics.txt"
# #Remove dup marked bam
# # rm -v ${fol1}/"${SM}_markdup.bam"
# rm -v ${fol1}/${mdBAM}
# # rm -v ${fol1}/"${SM}_markdup.bam.md5"
# # rm -v ${fol2}/"${SM}_fixedsort.bam"

#generate a file that will tell us if the step is completed
touch step0505_${SM}.done
# exit



