#!/usr/bin/env bash

#####################################
#This script is going to be used to create param file with custom variables and path that will be used by all the pipeline scripts


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
sge_m=10G
sge_m_dbi=15G #mem requirement to work with geneticDB import (it has to be a little higher than the correspondig mem assigned to the jvm in this step)
sge_pe=orte

#########SET UP SGE PARAMETERS HERE ##########

###########################################################
#---#
java_opt1x='-Xmx5g'	#meroria java		# Chr12,Wg12,21x2
java_opt2x='-Xmx10g'	#meroria java		# 02,03,04,05x2,06,07,08,09,Chr10,Wg10x3,14,15,17,18,23,24,Chr25,Chr26
java_opt3x='-Xmx25g'	#meroria java		# 19
java_opt4x='-Xmx100g'	#meroria java		# 20

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

function build_runner_alignment(){
param_file=$1

cat << EOF
#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=\$(date '+%Y/%m/%d %H:%M:%S')
echo "\$dt1"
echo

### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1
source ${param_file}
#source functions file
source \${hs}/pipeline_functions.sh

#log folders creation
mkdir -p \${lg}

### - CODE - ###

echo " --- START PIPELINE ---"
echo

#Pre-processing
#pipe step 1
#IN val OUT uBAM /// FastqToSam, ValidateSamFile, flagsta, view

echo "bash \${hs}/0101.GATK4_step0101.sh \${param_file}" | qsub -N G4s0101_\${SM} -cwd -l h_vmem=\${sge_m} -o \${lg}/\\\$JOB_ID_g0101_\${SM}.log -e \${lg}/\\\$JOB_ID_g0101_\${SM}.error -m a -M \${mail} -q \${sge_q}

#Pre-processing
#pipe step 2
#IN uBAM OUT bBAM /// SamToFastq, ValidateSamFile, flagstat, view

echo "bash \${hs}/0202.GATK4_step0202.sh \${param_file}" | qsub -N G4s0202_\${SM} -cwd -l h_vmem=\${sge_m} -pe \${sge_pe} \${thr} -hold_jid G4s0101_\${SM} -o \${lg}/\\\$JOB_ID_g0202_\${SM}.log -e \${lg}/\\\$JOB_ID_g0202_\${SM}.error -m a -M \${mail} -q \${sge_q}

#Pre-processing
#pipe step 3-5
#IN uBAM+bBAM OUT mBAM /// MergeBamAlignment, ValidateSamFile, flagstat, view
#IN mBAM OUT mdBAM /// MarkDuplicates, ValidateSamFile, flagstat, view
#IN mdBAM OUT fBAM /// SortSam, SetNmAndUqTags, ValidateSamFile, flagstat, view, sort, depth

echo "bash \${hs}/0305.GATK4_step0305.sh \${param_file}" | qsub -N G4s0305_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0202_\${SM} -o \${lg}/\\\$JOB_ID_g0305_\${SM}.log -e \${lg}/\\\$JOB_ID_g0305_\${SM}.error -m ea -M \${mail} -q \${sge_q}

echo
echo " --- END PIPELINE ---"

exit

EOF

}


function build_runner_BQSR(){
param_file=$1

cat << EOF
#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=\$(date '+%Y/%m/%d %H:%M:%S')
echo "\$dt1"
echo

### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1
source ${param_file}
#source functions file
source \${hs}/pipeline_functions.sh

#log folders creation
mkdir -p \${lg}

### - CODE - ###

echo " --- START PIPELINE ---"
echo

#BQSR
#pipe step 6, job-array
#IN fBAM OUT conting-bqsrrd /// BaseRecalibrator

a_size=`wc -l \${bqsr_intervals} | cut -f 1 -d " "`; echo "\${hs}/runner_job_array.sh -d \${hs}/0606.GATK4_step0606.sh \${bqsr_intervals} \${param_file}" | qsub -t 1-\${a_size} -N G4s0606_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0305_\${SM} -o \${lg}/g0606_\${SM}_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/g0606_\${SM}_\\\$JOB_ID.\\\$TASK_ID.error -m a -M \${mail} -q \${sge_q}

#BQSR
#pipe step 7-8
#IN conting-bqsrrd OUT bqsrrd /// GatherBQSRReports
#IN fBAM+bqsrrd OUT conting-bqsrrd /// ApplyBQSR, ValidateSamFile, flagstat, view

echo "bash \${hs}/0708.GATK4_step0708.sh \${param_file}" | qsub -N G4s0708_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0606_\${SM} -o \${lg}/g0708_\\\$JOB_ID_\${SM}.log -e \${lg}/g0708_\\\$JOB_ID_\${SM}.error -m a -M \${mail} -q \${sge_q}

echo
echo " --- END PIPELINE ---"

exit

EOF
}


function build_runner_VarCall(){
param_file=$1

cat << EOF
#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=\$(date '+%Y/%m/%d %H:%M:%S')
echo "\$dt1"
echo

### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1
source ${param_file}
#source functions file
source \${hs}/pipeline_functions.sh

#log folders creation
mkdir -p \${lg}

### - CODE - ###

echo " --- START PIPELINE ---"
echo

#HC
#pipe step 9, job-array
#IN bqsrrd OUT interval bqsrrd /// HaplotypeCaller

a_size=`wc -l \${vcall_interval} | cut -f 1 -d " "`; echo "\${hs}/runner_job_array.sh -d \${hs}/0909.GATK4_step0909.sh \${vcall_interval} \${param_file}" | qsub -t 1-\${a_size} -N G4s0909_\${SM} -cwd -l h_vmem=${sge_m} -hold_jid G4s0708_\${SM} -o \${lg}/g0909_\${SM}_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/g0909_\${SM}_\\\$JOB_ID.\\\$TASK_ID.error -m a -M \${mail} -q \${sge_q}

echo
echo " --- END PIPELINE ---"

exit


EOF

}

function build_runner_post_VarCall(){
param_file=$1

cat << EOF
#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=\$(date '+%Y/%m/%d %H:%M:%S')
echo "\$dt1"
echo

### - SOURCEs - ###
#We will provide a different param file for each user, with variables and softwares paths as needed
param_file=$1
source ${param_file}
#source functions file
source \${hs}/pipeline_functions.sh

#log folders creation
mkdir -p \${lg}

### - CODE - ###

echo " --- START PIPELINE ---"
echo

#HC
#pipe step 10-11
#IN conting-bqsrrd OUT gVCF /// MergeVcfs
#IN gVCF OUT fixed gVCF /// bcftools

echo "bash \${hs}/Chr1011.GATK4_step1011.sh \${param_file}" | qsub -N G4s1011_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s0909_\${SM} -o \${lg}/g1011_\\\$JOB_ID_\${SM}.log -e \${lg}/g1011_\\\$JOB_ID_\${SM}.error -m a -M \${mail} -q \${sge_q}

#gVCF check
#pipe step 12
#IN fixed gVCF OUT checked gVCF /// ValidateVariants

echo "\${hs}/Chr1212.GATK4_step1212.sh \${param_file}" | qsub -N G4s1212_\${SM} -cwd -l h_vmem=\${sge_m} -hold_jid G4s1011_\${SM} -o \${lg}/g1212_\\\$JOB_ID_\${SM}.log -e \${lg}/g1212_\\\$JOB_ID_\${SM}.error -m ea -M \${mail} -q \${sge_q}

echo
echo " --- END PIPELINE ---"

exit

EOF

}

function build_runner_GDBIMP() {
param_file=$1

cat << EOF
#!/usr/bin/env bash

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - VARIABILI FISSE - ###
variantdb=$1        #db name
### - SOURCEs - ###
source /home/manolis/GATK4/gatk4path.sh
### - mkdir FOLDER / make FILE - ###
mkdir ${lg}/${variantdb}
mkdir ${fol7}/${variantdb}
mkdir ${fol8}/${variantdb}
mkdir ${fol9}/${variantdb}
mkdir ${fol9}/${variantdb}/xSamplePassedVariantsVCFs
### - CODE - ###

echo " --- START PIPELINE ---"
echo

#GenomicsDBImport
#pipe step 13
#IN gCVF OUT gVCF-list /// find

echo "bash ${hs}/1313.GATK4_step1313.sh ${variantdb}" | qsub -N G4s1313_${variantdb} -cwd -l h_vmem=2G -q all.q -hold_jid G4s1212_* -o ${lg}/${variantdb}/g1313_${variantdb}.log -e ${lg}/${variantdb}/g1313_${variantdb}.error -m a -M emmanouil.a@gmail.com 

#GenomicsDBImport
#pipe step 14, job-array
#IN gCVF (gVCF-list) OUT gVCFDB /// GenomicsDBImport

a_size=`wc -l \${vdb_interval} | cut -f 1 -d " "`; echo "\${hs}/runner_job_array.sh -d \${hs}/1414.GATK4_step1414.sh \${vdb_interval} \${param_file}" | qsub -t 1-\${a_size} -N G4s1414_\${variantdb}_ -cwd -l h_vmem=${sge_m_dbi} -hold_jid G4s1313_\${variantdb} -o \${lg}/\${variantdb}/g1414_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/\${variantdb}/g1414_\\\$JOB_ID.\\\$TASK_ID.error -m ea -M \${mail} -q \${sge_q}


#GenotypeGVCFs
#pipe step 15, job-array
#IN gVCFDB OUT raw-VCFs /// GenotypeGVCFs
a_size=`wc -l \${vdb_interval} | cut -f 1 -d " "`; echo "\${hs}/runner_job_array.sh -d \${hs}/1515.GATK4_step1515.sh \${vdb_interval} \${param_file}" | qsub -t 1-\${a_size} -N G4s1414_\${variantdb}_ -cwd -l h_vmem=${sge_m_dbi} -hold_jid G4s1414_\${variantdb} -o \${lg}/\${variantdb}/g1515_\\\$JOB_ID.\\\$TASK_ID.log -e \${lg}/\${variantdb}/g1515_\\\$JOB_ID.\\\$TASK_ID.error -m ea -M \${mail} -q \${sge_q}


#GenotypeGVCFs
#pipe step 16
#IN raw-VCFs OUT cohort raw-VCF /// GatherVcfs

echo "bash ${hs}/1616.GATK4_step1616.sh ${variantdb}" | qsub -N G4s1616_${variantdb} -cwd -l h_vmem=20G -q all.q -hold_jid G4s1515_${variantdb}_* -o ${lg}/${variantdb}/g1616_${variantdb}.log -e ${lg}/${variantdb}/g1616_${variantdb}.error -m ea -M emmanouil.a@gmail.com

#Pre-VQSR
#pipe step 17-18
#IN cohort raw-VCF OUT cohort Hard Filtered raw-VCF /// VariantFiltration
#IN cohort Hard Filtered raw-VCF OUT cohort Site Only raw-VCF /// MakeSitesOnlyVcf

echo "bash ${hs}/1718.GATK4_step1718.sh ${variantdb}" | qsub -N G4s1718_${variantdb} -cwd -l h_vmem=20G -q all.q -hold_jid G4s1616_${variantdb} -o ${lg}/${variantdb}/g1718_${variantdb}.log -e ${lg}/${variantdb}/g1718_${variantdb}.error -m a -M emmanouil.a@gmail.com

#VQSR
#pipe step 19
#IN Site cohort Site Only raw-VCF OUT indel tranches, indel recal /// VariantRecalibrator

echo "bash ${hs}/1919.GATK4_step1919.sh ${variantdb}" | qsub -N G4s1919_${variantdb} -cwd -l h_vmem=40G -q all.q -hold_jid G4s1718_${variantdb} -o ${lg}/${variantdb}/g1919_${variantdb}.log -e ${lg}/${variantdb}/g1919_${variantdb}.error -m a -M emmanouil.a@gmail.com

#VQSR
#pipe step 20
#IN Site cohort Site Only raw-VCF OUT snp tranches, snp recal /// VariantRecalibrator

echo "bash ${hs}/2020.GATK4_step2020.sh ${variantdb}" | qsub -N G4s2020_${variantdb} -cwd -l h_vmem=120G -q all.q -hold_jid G4s1718_${variantdb} -o ${lg}/${variantdb}/g2020_${variantdb}.log -e ${lg}/${variantdb}/g2020_${variantdb}.error -m a -M emmanouil.a@gmail.com

#VQSR
#pipe step 21
#IN Site cohort Site Only raw-VCF, tranche file, recal file OUT cohort VQSR vcf /// ApplyVQSR

echo "bash ${hs}/2121.GATK4_step2121.sh ${variantdb}" | qsub -N G4s2121_${variantdb} -cwd -l h_vmem=20G -q all.q -hold_jid G4s1919_${variantdb} -hold_jid G4s2020_${variantdb} -o ${lg}/${variantdb}/g2121_${variantdb}.log -e ${lg}/${variantdb}/g2121_${variantdb}.error -m ea -M emmanouil.a@gmail.com

#PASS variants selection
#pipe step 22-24
#IN cohort VQSR.vcf, cohort raw.vcf OUT pass.list, sample.list /// grep
#IN cohort raw.vcf, pass.list OUT cohort-PASS-variants postVQSR /// SelectVariants
#IN cohort-PASS-variants postVQSR, sample.list OUT per sample-PASS-variants postVQSR /// SelectVariants

echo "bash ${hs}/2224.GATK4_step2224.sh ${variantdb}" | qsub -N G4s2224_${variantdb} -cwd -l h_vmem=25G -q all.q -hold_jid G4s2121_${variantdb} -o ${lg}/${variantdb}/g2224_${variantdb}.log -e ${lg}/${variantdb}/g2224_${variantdb}.error -m ea -M emmanouil.a@gmail.com

echo
echo " --- END PIPELINE ---"

exit




EOF

}



if [ $# -lt 1 ]
then
    echo "#########################"
    echo "WRONG argument number!"
    echo "Usage:"
    echo "config_file_creation.sh -i <input_file_folder> -t <template_folder> -o <output_folder> -s <sample_name> [-m <mail_address>] [-f (toggle fastq format only pipeline)]"
    echo "#########################"
    exit 1
fi

#ARGS
# template_dir=$1
# out_dir=$2

suffix=`date +"%d%m%Y%H%M%S"`

echo "${@}"
while getopts ":t:o:s:h:m:i:abvp" opt ${@}; do
  case $opt in
    t)
      echo ${OPTARG}
      template_dir=${OPTARG}
      ;;
    o)
      echo ${OPTARG}
      out_dir=${OPTARG}
      ;;
    s)
      echo ${OPTARG}
      sample_name=${OPTARG}
      ;;
    h)
        echo "#########################"
        echo "WRONG argument number!"
        echo "Usage:"
        echo "config_file_creation.sh -i <input_file_folder> -t <template_folder> -o <output_folder> -s <sample_name> [-m <mail_address>] [-f (toggle fastq format only pipeline)]"
        echo "#########################"
        exit 1
        ;;
    i)
      echo ${OPTARG}
      input_file_folder=${OPTARG}
    ;;
    a)
      echo "Alignment only"
      runner_mode=1
      ;;  
    b)
      echo "BQSR only"
      runner_mode=2
    ;;
    v)
      echo "Variant calling only"
      runner_mode=3
    ;;
    p)
      echo "Post Var calling only"
      runner_mode=4
    ;;
    
    m)
    echo ${OPTARG}
    mail_to=${OPTARG}
    ;;
    *)
      echo $opt
    ;;
  esac

done

mkdir -p ${out_dir}
mkdir -p ${template_dir}


build_template ${out_dir} ${sample_name} ${mail_to} > ${template_dir}/VarCall_${suffix}.conf

case ${runner_mode} in
  1 )
    build_runner_alignment ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_AlignRunner_${suffix}.sh
  ;;
  2 )
    build_runner_BQSR ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_BQSRRunner_${suffix}.sh
  ;;
  3 )
    build_runner_VarCall ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_VarCallRunner_${suffix}.sh
  ;;
  4 )
    build_runner_post_VarCall ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCall_PostVarCallRunner_${suffix}.sh
  ;;

esac

# if [[ ${runner_mode} -eq 1 ]]; then
#   #statements
#   # build_template_fastq ${out_dir} ${sample_name} ${mail_to} ${input_file_folder} > ${template_dir}/DataPrep_${suffix}.conf
# else
#   # build_template_all ${out_dir} ${sample_name} ${mail_to} ${input_file_folder} > ${template_dir}/DataPrep_${suffix}.conf
#   build_runner_all ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCallRunner_${suffix}.sh
# fi

echo "Template file ${template_dir}/VarCall_${suffix}.conf created. You can edit it to modify any non default parameter."
echo "Runner file ${template_dir}/VarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
