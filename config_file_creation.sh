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

# #step 6
# f1=$1                   #interval contings
# f2=$2                   #interval qsubID
# c_bqsrrd="\${SM}_\${f2}_recaldata.csv"    #conting recalibration report

# #step 7-8
# f1=$2                   #interval contings
# f2=$3                   #interval qsubID
# fBAM="\${SM}_fixed.bam"          #sorted and fixed file
# c_bqsrrd="\${SM}_\${f2}_recaldata.csv"    #conting recalibration report
# bqsrrd="\${SM}_recal_data.csv"       #final_merged recalibration report
# applybqsr="\${SM}_bqsr.bam"      #final_merged apply recalibration report in bam

# #step 9
# f1=$1                   #interval file
# f2=$2                   #interval file
# applybqsr="\${SM}_bqsr.bam"      #final_merged apply recalibration report in bam
# c_gv="\${SM}_\${f2}_g.vcf.gz"     #conting gVCF file

#step 10-11 (chr-wgs)
gVCF="\${SM}_g.vcf.gz"           #final_merged gVCF file
fixgVCF="\${SM}-g.vcf.gz"        #fixed gVCF file

#step 12 (chr-wgs)
gVCF="\${SM}_g.vcf.gz"           #final_merged 

#step 13
variantdb=$1                #db name

#step 14
variantdb=$1                #db name
f1=$2                   #interval file
f2=$3                   #interval file

#step 15
variantdb=$1                #db name
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
sge_q=all
seq_m=10G
sge_pe=orte
#########SET UP SGE PARAMETERS HERE ##########

###########################################################
#---#
java_opt1x='-Xmx5g'	#meroria java		# Chr12,Wg12,21x2
java_opt2x='-Xmx10g'	#meroria java		# 02,03,04,05x2,06,07,08,09,Chr10,Wg10x3,14,15,17,18,23,24,Chr25,Chr26
java_opt3x='-Xmx25g'	#meroria java		# 19
java_opt4x='-Xmx100g'	#meroria java		# 20

### - PATH FILEs - ###

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
#sorgILhg38wgenes=/home/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_ID.intervals
#sorgILhg38wgenesCHECK=/home/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals
#sorgILhg38wgenesINTERVALS=/home/shared/resources/gatk4hg38db/interval_list/hg38_WholeGenes_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals

#286723 intervalli: Exons +12bp each exon side # hg38 GENCODE v24 merged with hg38 RefSeqCurated Aug-2018
#sorgILhg38exons12Plus=/home/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_ID.intervals
#sorgILhg38exons12PlusCHECK=/home/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals
#sorgILhg38exons12PlusINTERVALS=/home/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals

#232227 intervalli: Exons +5bp each exon side # 2018/07/25
EXONS=/home/shared/resources/hgRef/hg38/hg38_RefSeqCurated_ExonsPLUS5bp/hg38_RefSeqCurated_ExonsPLUS5bp_sorted_merged.bed
#---#
#21589 intervalli: Whole genes regions (old version, dismissed); hg38RefSeqCurGenes_ID.intervals; hg38RefSeqCurGenes_noID.intervals
#---#
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

#now we need to create also the template for the script
function build_runner_all(){

param_file=$1

cat << EOF
#!/usr/bin/env bash
#

#Runner for the data preparation pipeline with default parameter file and default steps
source ${param_file}
#source functions file
source \${hs}/pipeline_functions.sh

#log folders creation
mkdir -p \${lg}

#step 1
#IN unknow BAM OUT check and stat info /// ValidateSamFile, flagstat, view
echo "bash \${hs}/01.preGATK4_step1.sh ${param_file}" | qsub -N pGs01_\${SM} -cwd -l h_vmem=\${seq_m} -o \${lg}/\\\$JOB_ID_pG01_\${SM}.log -e \${lg}/\\\$JOB_ID_pG01_\${SM}.error -m a -M \${mail} -q \${sge_q}

#step 2
#IN BAM OUT uBAM /// RevertSam, ValidateSamFile
echo "bash \${hs}/02.preGATK4_step2.sh ${param_file}" | qsub -N pGs02_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs01_\${SM} -o \${lg}/\\\$JOB_ID_pG02_\${SM}.log -e \${lg}/\\\$JOB_ID_pG02_\${SM}.error -m a -M \${mail} -q \${sge_q}

#step 3
#IN uBAM OUT fastq, fastqc /// bamtofastq, gzip, fastqc
echo "bash \${hs}/03.preGATK4_step3.sh ${param_file}" | qsub -N pGs03_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs02_\${SM} -o \${lg}/\\\$JOB_ID_pG03_\${SM}.log -e \${lg}/\\\$JOB_ID_pG03_\${SM}.error -m ea -M \${mail} -q \${sge_q}

#step 4
#IN fastq OUT fastqc /// fastqc
echo "bash \${hs}/04.preGATK4_step4.sh ${param_file}" | qsub -N pGs04_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs03_\${SM} -o \${lg}/\\\$JOB_ID_pG04_\${SM}.log -e \${lg}/\\\$JOB_ID_pG04_\${SM}.error -m ea -M \${mail} -q \${sge_q}

#step 5
#IN fastq OUT val /// trim_galore
echo "bash \${hs}/05.preGATK4_step5.sh ${param_file}" | qsub -N pGs05_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs04_\${SM} -o \${lg}/\\\$JOB_ID_pG05_\${SM}.log -e \${lg}/\\\$JOB_ID_pG05_\${SM}.error -m a -M \${mail} -q \${sge_q}

#step 6
#IN val OUT fastqc /// fastqc
echo "bash \${hs}/06.preGATK4_step6.sh ${param_file}" | qsub -N pGs06_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid pGs05_\${SM} -o \${lg}/\\\$JOB_ID_pG06_\${SM}.log -e \${lg}/\\\$JOB_ID_pG06_\${SM}.error -m ea -M \${mail} -q \${sge_q}

echo " --- END PIPELINE ---"

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

echo "bash \${hs}/0101.GATK4_step0101.sh \${param_file}" | qsub -N G4s0101_\${SM} -cwd -l h_vmem=\${seq_m} -o \${lg}/\\\$JOB_ID_g0101_\${SM}.log -e \${lg}/\\\$JOB_ID_g0101_\${SM}.error -m a -M \${mail} -q \${sge_q}

#Pre-processing
#pipe step 2
#IN uBAM OUT bBAM /// SamToFastq, ValidateSamFile, flagstat, view

echo "bash \${hs}/0202.GATK4_step0202.sh \${param_file}" | qsub -N G4s0202_\${SM} -cwd -l h_vmem=\${seq_m} -pe \${sge_pe} \${thr} -hold_jid G4s0101_\${SM} -o \${lg}/\\\$JOB_ID_g0202_\${SM}.log -e \${lg}/\\\$JOB_ID_g0202_\${SM}.error -m a -M \${mail} -q \${sge_q}

#Pre-processing
#pipe step 3-5
#IN uBAM+bBAM OUT mBAM /// MergeBamAlignment, ValidateSamFile, flagstat, view
#IN mBAM OUT mdBAM /// MarkDuplicates, ValidateSamFile, flagstat, view
#IN mdBAM OUT fBAM /// SortSam, SetNmAndUqTags, ValidateSamFile, flagstat, view, sort, depth

echo "bash \${hs}/0305.GATK4_step0305.sh \${param_file}" | qsub -N G4s0305_\${SM} -cwd -l h_vmem=\${seq_m} -hold_jid G4s0202_\${SM} -o \${lg}/\\\$JOB_ID_g0305_\${SM}.log -e \${lg}/\\\$JOB_ID_g0305_\${SM}.error -m ea -M \${mail} -q \${sge_q}

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
while getopts ":t:o:s:h:m:i:a" opt ${@}; do
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

if [[ ${runner_mode} -eq 1 ]]; then
  #statements
  # build_template_fastq ${out_dir} ${sample_name} ${mail_to} ${input_file_folder} > ${template_dir}/DataPrep_${suffix}.conf
  build_runner_alignment ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCallRunner_${suffix}.sh
else
  # build_template_all ${out_dir} ${sample_name} ${mail_to} ${input_file_folder} > ${template_dir}/DataPrep_${suffix}.conf
  build_runner_all ${template_dir}/VarCall_${suffix}.conf > ${template_dir}/VarCallRunner_${suffix}.sh
fi

echo "Template file ${template_dir}/VarCall_${suffix}.conf created. You can edit it to modify any non default parameter."
echo "Runner file ${template_dir}/VarCallRunner_${suffix}.sh created. You can edit it to modify any non default parameter."
