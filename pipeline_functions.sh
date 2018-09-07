#!/usr/bin/env bash

#function file for the pipeline, to include in the header, after the CONFIG FILE

#extract stats from the file
function sam_stats(){
    infile=$1

    ${SAMTOOLS} flagstat ${infile}
    echo
    ${SAMTOOLS} view -H ${infile} | grep -e '@RG' -e '@PG'
    # echo
    # ${SAMTOOLS} view -H ${fol1}/${uBAM} | grep '@PG'
    echo "- END -"

}

#validate the bam file
function sam_validate(){
    in_bam=$1
    java -jar ${PICARD} ValidateSamFile I=${in_bam} MODE=SUMMARY TMP_DIR=${tmp}/
    echo "- END -"
}