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
sorgILhg38Chr=/shared/resources/gatk4hg38db/interval_list/hg38_Chr_ID.intervals
sorgILhg38ChrCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_Chr_noID.intervals

#21798 intervalli: Whole genes regions hg38 refGene 05 Aug 2018 NM and NR
#sorgILhg38wgenesCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_refGene_05_Aug_2018_NMNR_sorted_noALTnoRANDOMnoCHRUNnoCHRM_merged_noID.intervals
#sorgILhg38wgenesINTERVALS=/shared/resources/gatk4hg38db/interval_list/hg38_refGene_05_Aug_2018_NMNR_sorted_noALTnoRANDOMnoCHRUNnoCHRM_merged_noID.intervals

#232227 intervalli: Exons +5bp each exon side # 2018/07/25
# sorgILhg38exons5PlusCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged_noALTnoRANDOMnoCHRUNnoCHRM_noID.intervals
# sorgILhg38exons5PlusINTERVALS=/shared/resources/gatk4hg38db/interval_list/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged_noALTnoRANDOMnoCHRUNnoCHRM_noID.intervals

#26507 intervalli: Whole genes regions hg38 GENCODE v24 merged with hg38 RefSeqCurated Aug-2018
sorgILhg38wgenesCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals
sorgILhg38wgenesINTERVALS=/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals

#286723 intervalli: Exons +12bp each exon side # hg38 GENCODE v24 merged with hg38 RefSeqCurated Aug-2018
sorgILhg38exons12PlusCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals
sorgILhg38exons12PlusINTERVALS=/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals

#232227 intervalli: Exons +5bp each exon side # 2018/07/25
EXONS=/shared/resources/hgRef/hg38/hg38_RefSeqCurated_ExonsPLUS5bp/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged.bed
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
#here we can select if we want to submit the interval file as it is or as a job array
whole_genome=1 #1:use the bed file as a single input, 0:use the bed file as a source to run job arrays
##############################################################################

# #step 7-8
bqsrrd="\${SM}_recal_data.csv"       #final_merged recalibration report
applybqsr="\${SM}_bqsr.bam"      #final_merged apply recalibration report in bam

########### SPECIFY THE INTERVAL FILE TO USE IN THE JOB ARRAY CREATION for CALLING #######
# #step 9
vcall_interval=\${sorgILhg38wgenes}
split_interval=0   #[0/n-split]select if you want to split the interval file in order to run multiple jobs array: mandatory with more tha 30K interval file
                    # the number selected will be the splitting line number for the interval file
job_a=1             #[0/1] define if we want to work with job arrays (each task is an interval) or just use the interval file as it is for job submission
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
joint_mode="DB"  #Specify "GENO" if not using the GenomicDBimport feature but the CombineGvcf feature
vdb_interval=\${sorgILhg38Chr}

#step 14 - 15 are job array based, working with intervals from the previous step

#step 16

#step 17-18
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
vqsr_thr_s="....."  #select vqsr threshold for SNPs
vqsr_thr_i="....."  #select vqsr threshold for INDELs
final="\${variantdb}_VQSR_output.vcf"    # -O
inout="\${variantdb}_tmp.indel.recalibrated.vcf"

#step 22-24-25(-26)
passed="\${variantdb}_CohortOnlyPASS_Variants_PostVQSR.vcf"
filter_interval=\${sorgILhg38wgenesINTERVALS}

#########SET UP YOUR EMAIL HERE ##############
mail=$3
#########SET UP YOUR EMAIL HERE ##############

#########SET UP SGE PARAMETERS HERE ##########
# New variables with different values can be added as long as
# they are also added to the corresponding runner file.
exec_host=apollo1.lan10gb #we can specify here the exec host to use in tmp mode var calling step to store the most of the data
sge_q=all.q #in var caller tmp mode, here we should need only the queue name, without host spec
sge_q_vcall=\${sge_q} #in var caller tmp mode, here we should need only the queue name, without host spec
sge_m_j1=8G #this mem requirement will work with java mem selection 1
sge_m=15G #this mem requirement will work with java mem selection 2
sge_m_j3=30G #this mem requirement will work with java mem selection 3 
sge_m_j4=120G #this mem requirement will work with java mem selection 4
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
GNMhg38=/shared/resources/hgRef/hg38/Homo_sapiens_assembly38.fasta
DBSNP138=/shared/resources/gatk4hg38db/Homo_sapiens_assembly38.dbsnp138.vcf
INDELS=/shared/resources/gatk4hg38db/Homo_sapiens_assembly38.known_indels.vcf.gz
OTGindels=/shared/resources/gatk4hg38db/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
AXIOM=/shared/resources/gatk4hg38db/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz
HAPMAP=/shared/resources/gatk4hg38db/hapmap_3.3.hg38.vcf.gz
OMNI=/shared/resources/gatk4hg38db/1000G_omni2.5.hg38.vcf.gz
OTGsnps=/shared/resources/gatk4hg38db/1000G_phase1.snps.high_confidence.hg38.vcf.gz


### - PATH TOOLs - ###
PICARD=/share/apps/bio/picard-2.17.3/picard.jar # v2.17.3
BWA=/share/apps/bio/bin/bwa             # v0.7.17-r1188
SAMTOOLS=/share/apps/bio/samtools/samtools  # v1.9-2-g02d93a1
GATK4=/share/apps/bio/gatk-4.0.8.1/gatk     # v4.0.8.1
BCFTOOLS=/share/apps/bio/bcftools/bcftools  # v1.9-18-gbab2aad

### - PATH FOLDERs - ###
# To use the  
base_out=$1
fol0=$4
fol1=\${base_out}/germlineVariants/1.BAM
fol2=\${base_out}/germlineVariants/1.BAM/infostorage
fol3=\${base_out}/germlineVariants/1.BAM/processing
fol4=\${base_out}/germlineVariants/1.BAM/storage

#########################SETUP TO EXPLOIT THE TEMP FOLDER ON VAR CALLING###############
#tmp setup imply that all the input files in fol4 are duplicated for each node in the fol4_tmp folder
#the data will be then processed and output will be written in the fol5_tmp folder in each node
#at the end of each job task the results will be moved to the fol5_host folder
#this setup is needed if we want to exploit the maximum CPU number
# Uncomment the lines below only if using the tmp setup!
#
# fol4_tmp=/tmp/\${base_out}/germlineVariants/1.BAM/storage
# fol5_tmp=/tmp/\${base_out}/germlineVariants/2.gVCF/processing
# fol5_host=\${base_out}/germlineVariants/2.gVCF
#########################SETUP TO EXPLOIT THE TEMP FOLDER ON VAR CALLING###############

fol5=\${base_out}/germlineVariants/2.gVCF/processing

#This folder should be the same for all processed samples, in order to get the correct list for GVCF merge on DBImport
fol6=\${base_out}/germlineVariants/2.gVCF/storage


######################### DBImport/CombineGVCF folder###############
#To generate a combined gvcf, we need to have 
fol7=\${base_out}/germlineVariants/3.genomicsDB

######################### DBImport/CombineGVCF folder###############

fol8=\${base_out}/germlineVariants/4.VCF/processing
fol9=\${base_out}/germlineVariants/4.VCF/storage

### - Path / Log / Tmp - ###
hs=/home/${USER}/scripts/pipelines/VariantCalling
lg=\${base_out}/Log
tmp=/home/${USER}/localtemp
EOF
}
