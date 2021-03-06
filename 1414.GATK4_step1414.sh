#!/usr/bin/env bash
set -e

echo
echo "> pipeline: Η Σκύλλα και η Χάρυβδη"
dt1=$(date '+%Y/%m/%d %H:%M:%S')
echo "$dt1"
echo

### - SOURCEs - ###
param_file=$2
echo ${param_file}
source ${param_file}
mkdir -p ${tmp}
#source functions file
own_folder=`dirname $0`
source ${hs}/pipeline_functions.sh
### - VARIABILI FISSE - ###
f1=$1                   #interval file
f2=`basename ${f1}`
# f2="all_intervals"     				#interval file
# f2=$2					#interval file
### - CODE - ###

case ${joint_mode} in
    DB )
        case ${pool_mode} in
            CHROM)
                echo "> GenomicsDBImport"
                #I need a way to get the current chromosome name
                #The file name is fixed but it's better to use the ${chr_pool[@]} variable
                for current_chr in ${chr_pool[@]}
                do
                  echo "current chr to check is ${current_chr}"
                  echo "${f2}"
                  # current_chr_file=$(echo ${f2} | fgrep "_chr${current_chr}.")
                  current_chr_file=$(echo ${f2} | sed -n "/_chr${current_chr}\./p")
                  echo "${current_chr_file}"
                  if [[ ${current_chr_file} != "" ]]; then
                      chr=${current_chr}
                      #we need to specify the chunk file we are using
                      current_chunk=${current_chr_file%%_*}
                      echo "current chr is ${chr}"
                      break
                  fi
                done
                current_variant_db=${variantdb}_${chr}_${current_chunk}
                #We need to replicate the vcf list in the new location
                mkdir -p ${fol7}/${current_variant_db}
                cp ${fol7}/${variantdb}_${chr}/gVCF.list ${fol7}/${current_variant_db}/gVCF.list

                bs=`wc -l ${fol7}/${current_variant_db}/gVCF.list| cut -f 1 -d " "`
                ${GATK4} --java-options "${java_opt2x} -DGATK_STACKTRACE_ON_USER_EXCEPTION=true" GenomicsDBImport --genomicsdb-workspace-path ${fol7}/${current_variant_db}/dbImport_${chr} --batch-size ${bs} -L "${f1}" --sample-name-map ${fol7}/${current_variant_db}/gVCF.list --reader-threads ${rt} -ip ${ip2} --tmp-dir ${tmp}
                echo "- END -"

            ;;
            SAMPLE)
                #14
                echo
                # cd ${fol7}/${variantdb}/
                echo "> GenomicsDBImport"
                bs=`wc -l ${fol7}/${variantdb}/gVCF.list| cut -f 1 -d " "`
                ${GATK4} --java-options "${java_opt2x} -DGATK_STACKTRACE_ON_USER_EXCEPTION=true" GenomicsDBImport --genomicsdb-workspace-path ${fol7}/${variantdb}/dbImport_${f2} --batch-size ${bs} -L "${f1}" --sample-name-map ${fol7}/${variantdb}/gVCF.list --reader-threads ${rt} -ip ${ip2} --tmp-dir ${tmp}
                echo "- END -"
            ;;
        esac

    ;;
    GENO )
        echo
        # cd ${fol7}/${variantdb}/
        samples_list=`find ${fol6_link}/*_g.vcf.gz -type f -printf "%f\n" | awk -v base_folder=${fol6_link} '{print "-V "base_folder"/"$1}'| tr "\n" " "`
        echo "> CombineGVCFs"
        ${GATK4} --java-options "${java_opt2x} -Dsamjdk.use_async_io_write_samtools=false " CombineGVCFs -O ${fol7}/${variantdb}/${f2}_g.vcf.gz -R ${GNMhg38} -L "${f1}" ${samples_list}
        echo "- END -"
    ;;
esac

touch step14.done



