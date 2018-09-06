### - VARIABLEs- ###
LB=LibXXX		#libreria		# 01,02
PL=Illumina		#piattaforma		# 01,02
thr=16			#number of thread	# 02
cl=5			#compression level	# 02,03,04,05
hg=hg38			#hg version		# 05
#---#
ip1=100			#interval_padding (bp)	# HaplotypeCaller
maa=2			#max alternate alleles	# HaplotypeCaller
java_XX1='-XX:GCTimeLimit=50' 			# 09-HaplotypeCaller
java_XX2='-XX:GCHeapFreeLimit=10'		# 09-HaplotypeCaller
bs=1			#batch size		# GenomicsDBImport
rt=1			#read thread		# GenomicsDBImport
ip2=200			#interval_padding (bp)	# GenomicsDBImport
#---#
java_opt1x='-Xmx5g'	#meroria java		# Chr12,Wg12,21x2
java_opt2x='-Xmx10g'	#meroria java		# 02,03,04,05x2,06,07,08,09,Chr10,Wg10x3,14,15,17,18,23,24,Chr25,Chr26
java_opt3x='-Xmx25g'	#meroria java		# 19
java_opt4x='-Xmx100g'	#meroria java		# 20

### - PATH FILEs - ###
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
sorgILhg38exons12Plus=/home/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_ID.intervals
sorgILhg38exons12PlusCHECK=/home/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals
sorgILhg38exons12PlusINTERVALS=/home/shared/resources/gatk4hg38db/interval_list/hg38_EXONSplus12_GENCODEv24_RefSeqCurated_noALTnoRANDOMnoCHRUNnoCHRM_sorted_merged_noID.intervals

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

### - PATH FOLDERs - ###
fol0=/home/manolis/GATK4preAnalysis/4.fastq_post
fol1=/home/manolis/GATK4/germlineVariants/1.BAM
fol2=/home/manolis/GATK4/germlineVariants/1.BAM/infostorage
fol3=/home/manolis/GATK4/germlineVariants/1.BAM/processing
fol4=/home/manolis/GATK4/germlineVariants/1.BAM/storage
fol5=/home/manolis/GATK4/germlineVariants/2.gVCF/processing
fol6=/home/manolis/GATK4/germlineVariants/2.gVCF/storage
fol7=/home/manolis/GATK4/germlineVariants/3.genomicsDB
fol8=/home/manolis/GATK4/germlineVariants/4.VCF/processing
fol9=/home/manolis/GATK4/germlineVariants/4.VCF/storage

### - PATH TOOLs - ###
PICARD=/share/apps/bio/picard-2.17.3/picard.jar	# v2.17.3
BWA=/share/apps/bio/bin/bwa 			# v0.7.17-r1188
SAMTOOLS=/share/apps/bio/samtools/samtools	# v1.9-2-g02d93a1
GATK4=/share/apps/bio/gatk-4.0.8.1/gatk		# v4.0.8.1
BCFTOOLS=/share/apps/bio/bcftools/bcftools	# v1.9-18-gbab2aad

### - Path / Log / Tmp - ###
hs=/home/manolis/GATK4/germlineVariants/0.pipe
lg=/home/manolis/GATK4/germlineVariants/Log
tmp=/home/manolis/localtemp



