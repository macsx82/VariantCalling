#!/usr/bin/env bash

#function file for the pipeline, to include in the header, after the CONFIG FILE
echo ${cluster_man}

if [[ ${cluster_man} == "CINECA" ]]; then
    echo "We're at CINECA"
    source ${HOME}/.startup_modules 
    # conda init bash
    # conda activate py37
    source activate py37
fi

echo "We're going on"

if [[ ${cluster_man} == "BURLO" ]]; then
    echo "We're at BURLO"
    #set at gatk 4.1 @ 2020/07/17
    source activate gatk4100
fi

#extract stats from the file
function sam_stats(){
    infile=$1

    ${SAMTOOLS} flagstat ${infile}
    echo
    ${SAMTOOLS} view -H ${infile} | grep -e '@RG' -e '@PG'
    echo "- END -"
    # ${SAMTOOLS} stats -r ${GNMhg38} ${infile} > ${infile}.stats
}

#validate the bam file
function sam_validate(){
    in_bam=$1
    samtools quickcheck -v -v -v ${in_bam}
    
    # java -XX:+UseSerialGC -jar ${PICARD} ValidateSamFile I=${in_bam} MODE=VERBOSE R=${GNMhg38} TMP_DIR=${tmp}/
    #get ready for new Picard syntax: 23/10/2019
    # java -XX:+UseSerialGC -jar ${PICARD} ValidateSamFile -I ${in_bam} -MODE VERBOSE -R ${GNMhg38} -TMP_DIR ${tmp}/
    echo "- END -"
}


#extract stats from the vcf file
function vcf_stats(){
    in_vcf=$1
    out_file=$2
    ${BCFTOOLS} stats -s - -d 0,1000,10 -F ${GNMhg38} ${in_vcf} > ${out_file}

    stats_plots=`dirname ${out_file}`
    # /share/apps/bio/bin/plot-vcfstats -s -p ${stats_plots}/stats ${out_file}
    plot-vcfstats -s -p ${stats_plots}/stats ${out_file}
    echo "- END -"
}

#######################
# utilities fucntions

# function interval_header(){
#     in_file=$1
#     { head -n 1 ${in_file}; cat; } > "$FILE";
# }