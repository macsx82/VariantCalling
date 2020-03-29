#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - SOURCEs - ###
param_file=$2
source ${param_file}
mkdir -p ${tmp}
#source functions file
own_folder=`dirname $0`
source ${hs}/pipeline_functions.sh
### - VARIABILI FISSE - ###
f1=$1					#interval file
# f2=$2                    #interval file
f2=`basename ${f1}`					#interval file
int_vcf="${variantdb}_${f2}.vcf.gz"	#interval vcf
### - CODE - ###


case ${joint_mode} in
    DB )
        case ${pool_mode} in
            CHROM)
                echo "> GenotypeGVCFs"
                #I need a way to get the current chromosome name
                #The file name is fixed but it's better to use the ${chr_pool[@]} variable
                for current_chr in ${chr_pool[@]}
                do
                  current_chr_file=$(echo ${f2} | fgrep "_chr${current_chr}.")
                  if [[ ${current_chr_file} != "" ]]; then
                      chr=${current_chr}
                      break
                  fi
                done
                current_variant_db=${variantdb}_${chr}
                int_vcf="${current_variant_db}.vcf.gz"

                bs=`wc -l ${fol7}/${current_variant_db}/gVCF.list| cut -f 1 -d " "`
                # ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC -DGATK_STACKTRACE_ON_USER_EXCEPTION=true" GenomicsDBImport --genomicsdb-workspace-path ${fol7}/${current_variant_db}/dbImport_${chr} --batch-size ${bs} -L "${f1}" --sample-name-map ${fol7}/${current_variant_db}/gVCF.list --reader-threads ${rt} -ip ${ip2} --tmp-dir ${tmp}
                # ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" GenotypeGVCFs -R ${GNMhg38} -O ${fol8}/${current_variant_db}/${int_vcf} -G StandardAnnotation --include-non-variant-sites --only-output-calls-starting-in-intervals --use-new-qual-calculator -V gendb://${fol7}/${current_variant_db}/dbImport_${chr} -L "${f1}"
                ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" GenotypeGVCFs -R ${GNMhg38} -O ${fol8}/${current_variant_db}/${int_vcf} -G StandardAnnotation --include-non-variant-sites --only-output-calls-starting-in-intervals -V gendb://${fol7}/${current_variant_db}/dbImport_${chr} -L "${f1}"
                echo "- END -"

            ;;
            SAMPLE)
                #15
                echo
                # cd ${fol7}/
                echo "> GenotypeGVCFs"
                # ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" GenotypeGVCFs -R ${GNMhg38} -O ${fol8}/${variantdb}/${int_vcf} -G StandardAnnotation --only-output-calls-starting-in-intervals --use-new-qual-calculator -V gendb://${fol7}/${variantdb}/${f2} -L "${f1}"
                # ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" GenotypeGVCFs -R ${GNMhg38} -O ${fol8}/${variantdb}/${int_vcf} -G StandardAnnotation --only-output-calls-starting-in-intervals --use-new-qual-calculator -V gendb://${fol7}/${variantdb}/dbImport_${f2} -L "${f1}"
                ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" GenotypeGVCFs -R ${GNMhg38} -O ${fol8}/${variantdb}/${int_vcf} -G StandardAnnotation --only-output-calls-starting-in-intervals --include-non-variant-sites -V gendb://${fol7}/${variantdb}/dbImport_${f2} -L "${f1}"
                echo "- END -"
                
            ;;
        esac


    ;;
    GENO )
        #15
        echo
        # cd ${fol7}/
        echo "> GenotypeGVCFs"
        # ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" GenotypeGVCFs -R ${GNMhg38} -O ${fol8}/${variantdb}/${int_vcf} -G StandardAnnotation --only-output-calls-starting-in-intervals --use-new-qual-calculator -V ${fol7}/${variantdb}/${f2}_g.vcf.gz -L "${f1}"
        ${GATK4} --java-options "${java_opt2x} -XX:+UseSerialGC" GenotypeGVCFs -R ${GNMhg38} -O ${fol8}/${variantdb}/${int_vcf} -G StandardAnnotation --only-output-calls-starting-in-intervals --include-non-variant-sites -V ${fol7}/${variantdb}/${f2}_g.vcf.gz -L "${f1}"
        echo "- END -"
    ;;
esac



touch step15.done



