#!/usr/bin/env bash

#####################################
#function to build config template by sample

function build_template_sample(){

cat << EOF

####################### INTERVAL sets #######################

######## UNCOMMENT the desired interval set for the calling step ############################
#24 contings: Chr contings (1-22,X,Y)
# sorgILhg38Chr=/shared/resources/gatk4hg38db/interval_list/hg38_Chr_ID.intervals
# sorgILhg38ChrCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_Chr_noID.intervals

#21798 intervalli: Whole genes regions hg38 refGene 05 Aug 2018 NM and NR
#sorgILhg38wgenesCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_refGene_05_Aug_2018_NMNR_sorted_noALTnoRANDOMnoCHRUNnoCHRM_merged_noID.intervals
#sorgILhg38wgenesINTERVALS=/shared/resources/gatk4hg38db/interval_list/hg38_refGene_05_Aug_2018_NMNR_sorted_noALTnoRANDOMnoCHRUNnoCHRM_merged_noID.intervals

#232227 intervalli: Exons +5bp each exon side # 2018/07/25
# sorgILhg38exons5PlusCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged_noALTnoRANDOMnoCHRUNnoCHRM_noID.intervals
# sorgILhg38exons5PlusINTERVALS=/shared/resources/gatk4hg38db/interval_list/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged_noALTnoRANDOMnoCHRUNnoCHRM_noID.intervals

#26507 intervalli: Whole genes regions hg38 GENCODE v24 merged with hg38 RefSeqCurated Aug-2018
# sorgILhg38wgenesCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals
# sorgILhg38wgenesINTERVALS=/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals

#286723 intervalli: Exons +12bp each exon side # hg38 GENCODE v24 merged with hg38 RefSeqCurated Aug-2018
# sorgILhg38exons12PlusCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals
# sorgILhg38exons12PlusINTERVALS=/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals

#232227 intervalli: Exons +5bp each exon side # 2018/07/25
#EXONS=/shared/resources/hgRef/hg38/hg38_RefSeqCurated_ExonsPLUS5bp/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged.bed
#EXONS=/galileo/home/userexternal/mcocca00/resources/hg38/hg38_RefSeqCurated_ExonsPLUS5bp/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged.bed

#---#
#21589 intervalli: Whole genes regions (old version, dismissed); hg38RefSeqCurGenes_ID.intervals; hg38RefSeqCurGenes_noID.intervals
#WGS intervals for variant calling, from GATK bundle
WGS_GATK=/galileo/home/userexternal/mcocca00/resources/hg38/wgs_calling_regions.hg38.bed_intervals.list	#I want this to be used as a job array parameter
																									# so this will be a list of bed files for the calling step
####################### INTERVAL sets #######################


### - VARIABLEs to be used in each pipeline step - ###
#step 1
SM=$2                   #sample name
sex=${10}      #sample's sex: we need this to correctly call sex chromosomes (1:male/2:female)
val1="$5"      #fastq 1 after trimming
val2="$6"      #fastq 2 after trimming

uBAM="\${SM}_unmapped.bam"       #unmapped bam

#step 2
bBAMu="\${SM}_bwa_u.bam"            #mapped bam unsorted
bBAM="\${SM}_bwa.bam"            #mapped bam sorted by queryname

### - VARIABLEs- ###
LB=\$(basename \${val1}| cut -f 2,3 -d "_")       #libreria       # 01,02
PL=Illumina     #piattaforma        # 01,02
thr=32          #number of thread   # 02
cl=5            #compression level  # 02,03,04,05
hg=hg38         #hg version     # 05
#---#
ip1=500         #interval_padding (bp)  # HaplotypeCaller
maa=3           #max alternate alleles  # HaplotypeCaller
java_opt_all='-XX:ParallelGCThreads=1'       # All GATK steps
java_XX1='-XX:GCTimeLimit=50'           # 09-HaplotypeCaller
java_XX2='-XX:GCHeapFreeLimit=10'       # 09-HaplotypeCaller
bs=1            #batch size     # GenomicsDBImport
rt=1            #read thread        # GenomicsDBImport
ip2=200         #interval_padding (bp)  # GenomicsDBImport
############################################

######## SET THE READ MODE TO SELECT THE BEST ALIGNMENT OPTIONS ##########
# accepted values are "long" OR "short", DEFAULT set on "long" to use bwa mem
read_mode=long
#########################################################################

#step 3-5
mBAM="\${SM}_merged.bam"         #merge unmapped bam and mapped bam
mdBAM="\${SM}_markdup.bam"       #mark dupplicates of the merged bam
metfile="\${SM}_dupmetrics.txt"      #metrics file
fBAM="\${SM}_fixed.bam"          #sorted and fixed file
fCRAM="\${SM}_fixed.cram"          #sorted and fixed file
# fBAMs="\${SM}_fixedsort.bam"     #fixed sorted bam

########### SPECIFY THE INTERVAL FILE TO USE IN THE JOB ARRAY CREATION for BQSR #######
# step 6 -> select one of the intervals in the INTERVALS section above
bqsr_intervals=\${sorgILhg38exons12PlusINTERVALS}
#here we can select if we want to submit the interval file as it is or as a job array
whole_genome=1 #1:use the bed file as a single input, 0:use the bed file as a source to run job arrays
##############################################################################

# #step 7-8
bqsrrd="\${SM}_recal_data.csv"       #final_merged recalibration report
# applybqsr="\${SM}_bqsr.bam"      #final_merged apply recalibration report in bam
applybqsr="\${SM}_bqsr.cram"      #final_merged apply recalibration report in cram

########### SPECIFY THE INTERVAL FILE TO USE IN THE JOB ARRAY CREATION for CALLING #######
# #step 9
vcall_interval=\${WGS_GATK}
split_interval=0   #[0/n-split]select if you want to split the interval file in order to run multiple jobs array: mandatory with more than 30K interval file
                    # the number selected will be the splitting line number for the interval file
job_a=1             #[0/1] define if we want to work with job arrays (each task is an interval or an interval list) or just use the interval file as it is for job submission
##############################################################################

#We add a modifier to define if we are working pooling by sample o by chromosome
pool_mode="CHROM" #alternative value is "SAMPLE", to work pooling by sample
#################################################
# This section is in place if we work by sample
#
#step 10-11 (chr-wgs)
#We need to specify all the chromosomes we want to work on
chr_pool=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X_PAR X_NONPAR Y)
gVCF="\${SM}_g.vcf.gz"           #final_merged gVCF file
fixgVCF="\${SM}-g.vcf.gz"        #fixed gVCF file

#step 12 (chr-wgs)
validate_interval=\${vcall_interval}
gVCF="\${SM}_g.vcf.gz"           #final_merged 
#
#################################################

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

#########SET UP SGE/QUEUE MANAGER PARAMETERS HERE ##########
# New variables with different values can be added as long as
# they are also added to the corresponding runner file.
cluster_man="CINECA" #Specify the cluster manager:BURLO or CINECA
exec_host=$7 #we can specify here the exec host to use in tmp mode var calling step to store the most of the data
sge_q=$8 #in var caller tmp mode, here we should need only the queue name, without host spec
sge_q_vcall=\${sge_q} #in var caller tmp mode, here we should need only the queue name, without host spec
sge_m_j1=8G #this mem requirement will work with java mem selection 1
sge_m_u=3G #this mem requirement is for the mem-per-cpu option in slurm
sge_m=15G #this mem requirement will work with java mem selection 2
sge_m_j2=20G #this mem requirement will work with other java mem selection
sge_m_j3=30G #this mem requirement will work with java mem selection 3 
sge_m_j4=120G #this mem requirement will work with java mem selection 4
sge_m_j5=40G #this mem requirement will work with other java mem selection
sge_m_dbi=15G #mem requirement to work with geneticDB import (it has to be a little higher than the correspondig mem assigned to the jvm in this step)
sge_pe=orte

#########SET UP SGE/QUEUE MANAGER PARAMETERS HERE ##########

###########################################################
#---#
java_opt1x='-Xms5g -Xmx5g -XX:+UseSerialGC' #memoria java       # Chr12,Wg12,21x2
java_opt2x='-Xms10g -Xmx10g -XX:+UseSerialGC'    #memoria java       # 02,03,04,05x2,06,07,08,09,Chr10,Wg10x3,14,15,17,18,23,24,Chr25,Chr26
java_opt3x='-Xms25g -Xmx25g -XX:+UseSerialGC'    #memoria java       # 19
java_opt4x='-Xms100g -Xmx100g -XX:+UseSerialGC'   #memoria java       # 20

### - PATH FILEs - ###

################### Known resources ###################
# GNMhg38=/shared/resources/hgRef/hg38/Homo_sapiens_assembly38.fasta
# DBSNP138=/shared/resources/gatk4hg38db/Homo_sapiens_assembly38.dbsnp138.vcf
# DBSNP_latest=/netapp/nfs/resources/dbSNP/human_9606_b151_GRCh38p7/All_20180418.vcf.gz
# INDELS=/shared/resources/gatk4hg38db/Homo_sapiens_assembly38.known_indels.vcf.gz
# OTGindels=/shared/resources/gatk4hg38db/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
# AXIOM=/shared/resources/gatk4hg38db/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz
# HAPMAP=/shared/resources/gatk4hg38db/hapmap_3.3.hg38.vcf.gz
# OMNI=/shared/resources/gatk4hg38db/1000G_omni2.5.hg38.vcf.gz
# OTGsnps=/shared/resources/gatk4hg38db/1000G_phase1.snps.high_confidence.hg38.vcf.gz

# ### - PATH TOOLs - ###
# PICARD=/share/apps/bio/picard-2.17.3/picard.jar # v2.17.3
# BWA=/share/apps/bio/bin/bwa             # v0.7.17-r1188
# SAMTOOLS=/share/apps/bio/samtools/samtools  # v1.9-2-g02d93a1
# GATK4=/share/apps/bio/gatk-4.1.0.0/gatk     # v4.1.0.0
# BCFTOOLS=/share/apps/bio/bcftools/bcftools  # v1.9-18-gbab2aad

### - PATH FILEs - CINECA SLURM version - ###

################### Known resources ###################
GNMhg38=/galileo/home/userexternal/mcocca00/resources/hg38/Homo_sapiens_assembly38.fasta
DBSNP138=/galileo/home/userexternal/mcocca00/resources/hg38/dbsnp_138.hg38.vcf.gz
DBSNP_latest=/galileo/home/userexternal/mcocca00/resources/hg38/dbsnp_151.hg38.vcf.gz
INDELS=/galileo/home/userexternal/mcocca00/resources/hg38/Homo_sapiens_assembly38.known_indels.vcf.gz
OTGindels=/galileo/home/userexternal/mcocca00/resources/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
OTGsnps=/galileo/home/userexternal/mcocca00/resources/hg38/1000G_phase1.snps.high_confidence.hg38.vcf.gz
HAPMAP=/galileo/home/userexternal/mcocca00/resources/hg38/hapmap_3.3.hg38.vcf.gz
OMNI=/galileo/home/userexternal/mcocca00/resources/hg38/1000G_omni2.5.hg38.vcf.gz
AXIOM=/galileo/home/userexternal/mcocca00/resources/hg38/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz

### - PATH TOOL - CINECA SLURM version - ###
# PICARD=/galileo/prod/opt/applications/picardtools/2.3.0/binary/bin/picard.jar
PICARD=/galileo/home/userexternal/mcocca00/softwares/picardtools/2.21.1/picard.jar
SAMTOOLS=/galileo/prod/opt/applications/samtools/1.9/intel--pe-xe-2018--binary/bin/samtools
BWA=/galileo/prod/opt/applications/bwa/0.7.17/gnu--6.1.0/bin/bwa
BCFTOOLS=/galileo/prod/opt/tools/bcftools/1.9/gnu--6.1.0/bin/bcftools
GATK4=/galileo/prod/opt/applications/gatk/4.1.0.0/jre--1.8.0_111--binary/bin/gatk
SAMBAMBA=/galileo/prod/opt/applications/sambamba/0.7.0/none/bin/sambamba-0.7.0-linux-static

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
fol6=\${base_out}/germlineVariants/2.gVCF/storage

###########################################################################################
# This last section is meant to set path for the gvcf merging step, which should happen once, after all calling is done
# We need to create a folder with links to all the generated splitted steps data.
# This folder should be the same for all processed samples, in order to get the correct list for GVCF merge on DBImport
# and should be created right after the merging step for the single vcf files
common_base_out=$9
fol6_link=\${common_base_out}/all_samples/germlineVariants/2.gVCF/storage


######################### DBImport/CombineGVCF folder###############
#To generate a combined gvcf, we need to have 
fol7=\${common_base_out}/all_samples/germlineVariants/3.genomicsDB

######################### DBImport/CombineGVCF folder###############

fol8=\${common_base_out}/all_samples/germlineVariants/4.VCF/processing
fol9=\${common_base_out}/all_samples/germlineVariants/4.VCF/storage
###########################################################################################

### - Path / Log / Tmp - ###
hs=${HOME}/scripts/pipelines/VariantCalling
lg=\${base_out}/Log
rnd_tmp=\`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8|head -1\`
tmp=${CINECA_SCRATCH}/localtemp/\${rnd_tmp}
EOF
}

#####################################
#function to build config template pooled

function build_template_pooled(){

cat << EOF
### - VARIABLEs- ###
LB=LibXXX       #libreria       # 01,02
PL=Illumina     #piattaforma        # 01,02
thr=16          #number of thread   # 02
cl=5            #compression level  # 02,03,04,05
hg=hg38         #hg version     # 05
#---#
ip1=500         #interval_padding (bp)  # HaplotypeCaller
maa=3           #max alternate alleles  # HaplotypeCaller
java_opt_all='-XX:ParallelGCThreads=1'       # All GATK steps
java_XX1='-XX:GCTimeLimit=50'           # 09-HaplotypeCaller
java_XX2='-XX:GCHeapFreeLimit=10'       # 09-HaplotypeCaller
bs=1            #batch size     # GenomicsDBImport
rt=1            #read thread        # GenomicsDBImport
ip2=200         #interval_padding (bp)  # GenomicsDBImport

####################### INTERVAL sets #######################

######## UNCOMMENT the desired interval set for the calling step ############################
#24 contings: Chr contings (1-22,X,Y)
# sorgILhg38Chr=/shared/resources/gatk4hg38db/interval_list/hg38_Chr_ID.intervals
# sorgILhg38ChrCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_Chr_noID.intervals

#21798 intervalli: Whole genes regions hg38 refGene 05 Aug 2018 NM and NR
#sorgILhg38wgenesCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_refGene_05_Aug_2018_NMNR_sorted_noALTnoRANDOMnoCHRUNnoCHRM_merged_noID.intervals
#sorgILhg38wgenesINTERVALS=/shared/resources/gatk4hg38db/interval_list/hg38_refGene_05_Aug_2018_NMNR_sorted_noALTnoRANDOMnoCHRUNnoCHRM_merged_noID.intervals

#232227 intervalli: Exons +5bp each exon side # 2018/07/25
# sorgILhg38exons5PlusCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged_noALTnoRANDOMnoCHRUNnoCHRM_noID.intervals
# sorgILhg38exons5PlusINTERVALS=/shared/resources/gatk4hg38db/interval_list/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged_noALTnoRANDOMnoCHRUNnoCHRM_noID.intervals

#26507 intervalli: Whole genes regions hg38 GENCODE v24 merged with hg38 RefSeqCurated Aug-2018
# sorgILhg38wgenesCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals
# sorgILhg38wgenesINTERVALS=/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals

#286723 intervalli: Exons +12bp each exon side # hg38 GENCODE v24 merged with hg38 RefSeqCurated Aug-2018
# sorgILhg38exons12PlusCHECK=/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals
# sorgILhg38exons12PlusINTERVALS=/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals

#232227 intervalli: Exons +5bp each exon side # 2018/07/25
# EXONS=/shared/resources/hgRef/hg38/hg38_RefSeqCurated_ExonsPLUS5bp/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged.bed
#EXONS=/galileo/home/userexternal/mcocca00/resources/hg38/hg38_RefSeqCurated_ExonsPLUS5bp/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged.bed
#---#
#21589 intervalli: Whole genes regions (old version, dismissed); hg38RefSeqCurGenes_ID.intervals; hg38RefSeqCurGenes_noID.intervals
#WGS intervals fo variant calling, from GATK bundle
WGS_GATK=/galileo/home/userexternal/mcocca00/resources/hg38/wgs_calling_regions.hg38.interval_list

####################### INTERVAL sets #######################


### - VARIABLEs to be used in each pipeline step - ###

#We add a modifier to define if we are working pooling by sample o by chromosome
pool_mode="CHROM" #alternative value is "SAMPLE", to work pooling by sample
############################################################
# This section is in place if we work in pooled mode by chr
#
#step 10-11 (chr-wgs)
gVCF="\${SM}_g.vcf.gz"           #final_merged gVCF file
fixgVCF="\${SM}-g.vcf.gz"        #fixed gVCF file

#step 12 (chr-wgs)
validate_interval=\${vcall_interval}
gVCF="\${SM}_g.vcf.gz"           #final_merged 
#
#############################################################

########### Set the variant db name for GenomicDB import #######
#step 13
variantdb="VcalledDB"                #db name

########### SPECIFY THE INTERVAL FILE TO USE IN THE JOB ARRAY CREATION for DB import #######
joint_mode="DB"  #Specify "GENO" if not using the GenomicDBimport feature but the CombineGvcf feature
vdb_interval=\${sorgILhg38exons12PlusINTERVALS} #same used in calling and BQSR steps!

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
vqsr_thr_s="99.9"  #select vqsr threshold for SNPs
vqsr_thr_i="99.9"  #select vqsr threshold for INDELs
final="\${variantdb}_VQSR_output.vcf"    # -O
inout="\${variantdb}_tmp.indel.recalibrated.vcf"

#step 22-24-25(-26)
passed="\${variantdb}_CohortOnlyPASS_Variants_PostVQSR.vcf"
filter_interval=\${sorgILhg38exons12PlusINTERVALS}

#########SET UP YOUR EMAIL HERE ##############
mail=$2
#########SET UP YOUR EMAIL HERE ##############

#########SET UP SGE PARAMETERS HERE ##########
# New variables with different values can be added as long as
# they are also added to the corresponding runner file.
cluster_man="CINECA" #Specify the cluster manager:BURLO or CINECA
exec_host=$3 #we can specify here the exec host to use in tmp mode var calling step to store the most of the data
sge_q=$4 #in var caller tmp mode, here we should need only the queue name, without host spec
sge_q_vcall=\${sge_q} #in var caller tmp mode, here we should need only the queue name, without host spec
sge_m_u=3G #this mem requirement is for the mem-per-cpu option in slurm
sge_m_j1=8G #this mem requirement will work with java mem selection 1
sge_m=15G #this mem requirement will work with java mem selection 2
sge_m_j3=30G #this mem requirement will work with java mem selection 3 
sge_m_j4=120G #this mem requirement will work with java mem selection 4
sge_m_dbi=15G #mem requirement to work with geneticDB import (it has to be a little higher than the correspondig mem assigned to the jvm in this step)
sge_pe=orte

#########SET UP SGE PARAMETERS HERE ##########

###########################################################
#---#
java_opt1x='-Xmx5g -XX:+UseSerialGC' #memoria java       # Chr12,Wg12,21x2
java_opt2x='-Xmx10g -XX:+UseSerialGC'    #memoria java       # 02,03,04,05x2,06,07,08,09,Chr10,Wg10x3,14,15,17,18,23,24,Chr25,Chr26
java_opt3x='-Xmx25g -XX:+UseSerialGC'    #memoria java       # 19
java_opt4x='-Xmx100g -XX:+UseSerialGC'   #memoria java       # 20

### - PATH FILEs - ###

# ################### Known resources ###################
# GNMhg38=/shared/resources/hgRef/hg38/Homo_sapiens_assembly38.fasta
# DBSNP138=/shared/resources/gatk4hg38db/Homo_sapiens_assembly38.dbsnp138.vcf
# DBSNP_latest=/netapp/nfs/resources/dbSNP/human_9606_b151_GRCh38p7/All_20180418.vcf.gz
# INDELS=/shared/resources/gatk4hg38db/Homo_sapiens_assembly38.known_indels.vcf.gz
# OTGindels=/shared/resources/gatk4hg38db/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
# AXIOM=/shared/resources/gatk4hg38db/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz
# HAPMAP=/shared/resources/gatk4hg38db/hapmap_3.3.hg38.vcf.gz
# OMNI=/shared/resources/gatk4hg38db/1000G_omni2.5.hg38.vcf.gz
# OTGsnps=/shared/resources/gatk4hg38db/1000G_phase1.snps.high_confidence.hg38.vcf.gz


# ### - PATH TOOLs - ###
# PICARD=/share/apps/bio/picard-2.17.3/picard.jar # v2.17.3
# BWA=/share/apps/bio/bin/bwa             # v0.7.17-r1188
# SAMTOOLS=/share/apps/bio/samtools/samtools  # v1.9-2-g02d93a1
# GATK4=/share/apps/bio/gatk-4.1.0.0/gatk     # v4.1.0.0
# BCFTOOLS=/share/apps/bio/bcftools/bcftools  # v1.9-18-gbab2aad

### - PATH FILEs - CINECA SLURM version - ###

################### Known resources ###################
GNMhg38=/galileo/home/userexternal/mcocca00/resources/hg38/Homo_sapiens_assembly38.fasta
DBSNP138=/galileo/home/userexternal/mcocca00/resources/hg38/dbsnp_138.hg38.vcf.gz
DBSNP_latest=/galileo/home/userexternal/mcocca00/resources/hg38/dbsnp_151.hg38.vcf.gz
INDELS=/galileo/home/userexternal/mcocca00/resources/hg38/Homo_sapiens_assembly38.known_indels.vcf.gz
OTGindels=/galileo/home/userexternal/mcocca00/resources/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
OTGsnps=/galileo/home/userexternal/mcocca00/resources/hg38/1000G_phase1.snps.high_confidence.hg38.vcf.gz
HAPMAP=/galileo/home/userexternal/mcocca00/resources/hg38/hapmap_3.3.hg38.vcf.gz
OMNI=/galileo/home/userexternal/mcocca00/resources/hg38/1000G_omni2.5.hg38.vcf.gz
AXIOM=/galileo/home/userexternal/mcocca00/resources/hg38/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz

### - PATH TOOL - CINECA SLURM version - ###
# PICARD=/galileo/prod/opt/applications/picardtools/2.3.0/binary/bin/picard.jar
PICARD=/galileo/home/userexternal/mcocca00/softwares/picardtools/2.21.1/picard.jar
SAMTOOLS=/galileo/prod/opt/applications/samtools/1.9/intel--pe-xe-2018--binary/bin/samtools
BWA=/galileo/prod/opt/applications/bwa/0.7.17/gnu--6.1.0/bin/bwa
BCFTOOLS=/galileo/prod/opt/tools/bcftools/1.9/gnu--6.1.0/bin/bcftools
GATK4=/galileo/prod/opt/applications/gatk/4.1.0.0/jre--1.8.0_111--binary/bin/gatk

### - PATH FOLDERs - ###

###########################################################################################
# This last section is meant to set path for the gvcf merging step, which should happen once, after all calling is done
# We need to create a folder with links to all the generated splitted steps data.
# This folder should be the same for all processed samples, in order to get the correct list for GVCF merge on DBImport
# and should be created right after the merging step for the single vcf files
common_base_out=$1
fol6_link=\${common_base_out}/all_samples/germlineVariants/2.gVCF/storage


######################### DBImport/CombineGVCF folder###############
#To generate a combined gvcf, we need to have 
fol7=\${common_base_out}/all_samples/germlineVariants/3.genomicsDB

######################### DBImport/CombineGVCF folder###############

fol8=\${common_base_out}/all_samples/germlineVariants/4.VCF/processing
fol9=\${common_base_out}/all_samples/germlineVariants/4.VCF/storage
###########################################################################################

### - Path / Log / Tmp - ###
hs=${HOME}/scripts/pipelines/VariantCalling
lg=\${common_base_out}/Log
rnd_tmp=\`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8|head -1\`
tmp=${CINECA_SCRATCH}/localtemp/\${rnd_tmp}
EOF
}
