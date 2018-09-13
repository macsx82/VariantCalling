#!/usr/bin/env bash

#####################################
#function to build config template

function build_template(){

cat << EOF
### - VARIABLEs- ###
LB=LibXXX       #libreria       # 01,02
PL=Illumina     #piattaforma        # 01,02
thr=16          #number of thread   # 02
cl=5            #compression level  # 02,03,04,05
hg=hg38         #hg version     # 05
#---#
ip1=100         #interval_padding (bp)  # HaplotypeCaller
maa=2           #max alternate alleles  # HaplotypeCaller
java_XX1='-XX:GCTimeLimit=50'           # 09-HaplotypeCaller
java_XX2='-XX:GCHeapFreeLimit=10'       # 09-HaplotypeCaller
bs=1            #batch size     # GenomicsDBImport
rt=1            #read thread        # GenomicsDBImport
ip2=200         #interval_padding (bp)  # GenomicsDBImport

####################### INTERVAL sets #######################

######## UNCOMMENT the desired interval set for the calling step ############################
#24 contings: Chr contings (1-22,X,Y)
sorgILhg38Chr=/home/shared/resources/gatk4hg38db/interval_list/hg38Chr_ID.intervals
sorgILhg38ChrCHECK=/home/shared/resources/gatk4hg38db/interval_list/hg38Chr_noID.intervals

#21798 intervalli: Whole genes regions hg38 refGene 05 Aug 2018 NM and NR
#sorgILhg38wgenes=/home/shared/resources/gatk4hg38db/interval_list/hg38_refGene_05_Aug_2018_NMNR_sorted_noALTnoRANDOMnoCHRUNnoCHRM_merged_ID.intervals
#sorgILhg38wgenesCHECK=/home/shared/resources/gatk4hg38db/interval_list/hg38_refGene_05_Aug_2018_NMNR_sorted_noALTnoRANDOMnoCHRUNnoCHRM_merged_noID.intervals
#sorgILhg38wgenesINTERVALS=/home/shared/resources/gatk4hg38db/interval_list/hg38_refGene_05_Aug_2018_NMNR_sorted_noALTnoRANDOMnoCHRUNnoCHRM_merged_noID.intervals

#232227 intervalli: Exons +5bp each exon side # 2018/07/25
#sorgILhg38exons5Plus=/home/shared/resources/gatk4hg38db/interval_list/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged_noALTnoRANDOMnoCHRUNnoCHRM_ID.intervals
#sorgILhg38exons5PlusCHECK=/home/shared/resources/gatk4hg38db/interval_list/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged_noALTnoRANDOMnoCHRUNnoCHRM_noID.intervals
#sorgILhg38exons5PlusINTERVALS=/home/shared/resources/gatk4hg38db/interval_list/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged_noALTnoRANDOMnoCHRUNnoCHRM_noID.intervals

#26507 intervalli: Whole genes regions hg38 GENCODE v24 merged with hg38 RefSeqCurated Aug-2018
sorgILhg38wgenes=/home/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_ID.intervals
sorgILhg38wgenesCHECK=/home/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals
sorgILhg38wgenesINTERVALS=/home/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals

#286723 intervalli: Exons +12bp each exon side # hg38 GENCODE v24 merged with hg38 RefSeqCurated Aug-2018
#sorgILhg38exons12Plus=/home/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_ID.intervals
#sorgILhg38exons12PlusCHECK=/home/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals
#sorgILhg38exons12PlusINTERVALS=/home/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals

#232227 intervalli: Exons +5bp each exon side # 2018/07/25
EXONS=/home/shared/resources/hgRef/hg38/hg38_RefSeqCurated_ExonsPLUS5bp/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged.bed
#---#
#21589 intervalli: Whole genes regions (old version, dismissed); hg38RefSeqCurGenes_ID.intervals; hg38RefSeqCurGenes_noID.intervals

####################### INTERVAL sets #######################


### - VARIABLEs to be used in each pipeline step - ###
#step 1
SM=$2                   #sample name
val1="\${SM}_R1_val_1.fq.gz"      #fastq 1 after trimming
val2="\${SM}_R2_val_2.fq.gz"      #fastq 2 after trimming
uBAM="\${SM}_unmapped.bam"       #unmapped bam

#step 2
bBAM="\${SM}_bwa.bam"            #mapped bam

######## SET THE READ MODE TO SELECT THE BEST ALIGNMENT OPTIONS ##########
# accepted values are "long" OR "short", DEFAULT set on "long" to use bwa mem
read_mode=long
#########################################################################

#step 3-5
mBAM="\${SM}_merged.bam"         #merge unmapped bam and mapped bam
mdBAM="\${SM}_markdup.bam"       #mark dupplicates of the merged bam
metfile="\${SM}_dupmetrics.txt"      #metrics file
fBAM="\${SM}_fixed.bam"          #sorted and fixed file
fBAMs="\${SM}_fixedsort.bam"     #fixed sorted bam

########### SPECIFY THE INTERVAL FILE TO USE IN THE JOB ARRAY CREATION for BQSR #######
# step 6 -> select one of the intervals in the INTERVALS section above
bqsr_intervals=\${sorgILhg38Chr}
##############################################################################

# #step 7-8
bqsrrd="\${SM}_recal_data.csv"       #final_merged recalibration report
applybqsr="\${SM}_bqsr.bam"      #final_merged apply recalibration report in bam

########### SPECIFY THE INTERVAL FILE TO USE IN THE JOB ARRAY CREATION for CALLING #######
# #step 9
vcall_interval=\${sorgILhg38wgenes}
##############################################################################

#step 10-11 (chr-wgs)
gVCF="\${SM}_g.vcf.gz"           #final_merged gVCF file
fixgVCF="\${SM}-g.vcf.gz"        #fixed gVCF file

#step 12 (chr-wgs)
gVCF="\${SM}_g.vcf.gz"           #final_merged 

########### Set the variant db name for GenomicDB import #######
#step 13
variantdb="VcalledDB"                #db name

########### SPECIFY THE INTERVAL FILE TO USE IN THE JOB ARRAY CREATION for DB import #######
vdb_interval=\${sorgILhg38Chr}

#step 14 - 15 
f1=$2                   #interval file
f2=$3                   #interval file

#step 15
f1=$2                   #interval file
f2=$3                   #interval file
int_vcf="${variantdb}_${f2}.vcf"    #interval vcf

#step 16
variantdb=$1                #db name
f1=$2                   #interval file
f2=$3                   #interval file
raw="${variantdb}_raw.vcf"      #cohort raw vcf

#step 17-18
variantdb=$1                #db name
raw="\${variantdb}_raw.vcf"
HF="\${variantdb}_rawHF.vcf"
SO="\${variantdb}_rawHFSO.vcf"

#step 19-20-21
SO="\${variantdb}_rawHFSO.vcf"
iVR="\${variantdb}_rawHFSO-iVR.vcf"
tri="\${variantdb}_indel.tranches"
mode_I=INDEL

#step 20
sVR="\${variantdb}_rawHFSO-sVR.vcf"
trs="\${variantdb}_snp.tranches"
mode_S=SNP

#step 21
final="\${variantdb}_VQSR_output.vcf"    # -O
#iVR="${variantdb}_rawHFSO-iVR.vcf"
#tri="${variantdb}_indel.tranches"
#mode_I=INDEL
inout="\${variantdb}_tmp.indel.recalibrated.vcf"
#sVR="${variantdb}_rawHFSO-sVR.vcf"
#trs="${variantdb}_snp.tranches"
#mode_S=SNP

#step 22-24-25-26
#variantdb=$1                #db name
#raw="${variantdb}_raw.vcf"
#final="${variantdb}_VQSR_output.vcf"
passed="\${variantdb}_CohortOnlyPASS_Variants_PostVQSR.vcf"

#step 25 (chr)
#variantdb=$1                #db name
#raw="${variantdb}_raw.vcf"
#final="${variantdb}_VQSR_output.vcf"
#passed="${variantdb}_CohortOnlyPASS_Variants_PostVQSR.vcf"

#step 26 (chr)
#variantdb=$1                #db name
#raw="${variantdb}_raw.vcf"
#final="${variantdb}_VQSR_output.vcf"
#passed="${variantdb}_CohortOnlyPASS_Variants_PostVQSR.vcf"

#########SET UP YOUR EMAIL HERE ##############
mail=$3
#########SET UP YOUR EMAIL HERE ##############

#########SET UP SGE PARAMETERS HERE ##########
# New variables with different values can be added as long as
# they are also added to the corresponding runner file.
sge_q=all
sge_m=15G #this mem requirement will work with java mem selection till 10G, set it at higher levels if working with other thresholds
sge_m_dbi=15G #mem requirement to work with geneticDB import (it has to be a little higher than the correspondig mem assigned to the jvm in this step)
sge_pe=orte

#########SET UP SGE PARAMETERS HERE ##########

###########################################################
#---#
java_opt1x='-Xmx5g' #meroria java       # Chr12,Wg12,21x2
java_opt2x='-Xmx10g'    #meroria java       # 02,03,04,05x2,06,07,08,09,Chr10,Wg10x3,14,15,17,18,23,24,Chr25,Chr26
java_opt3x='-Xmx25g'    #meroria java       # 19
java_opt4x='-Xmx100g'   #meroria java       # 20

### - PATH FILEs - ###

################### Known resources ###################
GNMhg38=/home/shared/resources/hgRef/hg38/Homo_sapiens_assembly38.fasta
DBSNP138=/home/shared/resources/gatk4hg38db/Homo_sapiens_assembly38.dbsnp138.vcf
INDELS=/home/shared/resources/gatk4hg38db/Homo_sapiens_assembly38.known_indels.vcf.gz
OTGindels=/home/shared/resources/gatk4hg38db/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
AXIOM=/home/shared/resources/gatk4hg38db/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz
HAPMAP=/home/shared/resources/gatk4hg38db/hapmap_3.3.hg38.vcf.gz
OMNI=/home/shared/resources/gatk4hg38db/1000G_omni2.5.hg38.vcf.gz
OTGsnps=/home/shared/resources/gatk4hg38db/1000G_phase1.snps.high_confidence.hg38.vcf.gz


### - PATH TOOLs - ###
PICARD=/share/apps/bio/picard-2.17.3/picard.jar # v2.17.3
BWA=/share/apps/bio/bin/bwa             # v0.7.17-r1188
SAMTOOLS=/share/apps/bio/samtools/samtools  # v1.9-2-g02d93a1
GATK4=/share/apps/bio/gatk-4.0.8.1/gatk     # v4.0.8.1
BCFTOOLS=/share/apps/bio/bcftools/bcftools  # v1.9-18-gbab2aad

### - PATH FOLDERs - ###
base_out=$1
fol0=\${base_out}/preAnalysis/4.fastq_post
fol1=\${base_out}/germlineVariants/1.BAM
fol2=\${base_out}/germlineVariants/1.BAM/infostorage
fol3=\${base_out}/germlineVariants/1.BAM/processing
fol4=\${base_out}/germlineVariants/1.BAM/storage
fol5=\${base_out}/germlineVariants/2.gVCF/processing
fol6=\${base_out}/germlineVariants/2.gVCF/storage
fol7=\${base_out}/germlineVariants/3.genomicsDB
fol8=\${base_out}/germlineVariants/4.VCF/processing
fol9=\${base_out}/germlineVariants/4.VCF/storage

### - Path / Log / Tmp - ###
hs=\${base_out}/0.pipe
lg=\${base_out}/Log
tmp=/home/${USER}/localtemp
EOF
}
