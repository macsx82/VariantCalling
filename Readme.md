# Variant Calling pipeline for WES data

GitHub repo: https://github.com/macsx82/VariantCalling

This pipeline is adapted to run variant calling on WES data using GATK4 and WGS data using GATK4 and samtools/bcftools in order to limit the java footprint on the cluster

The complete pipeline is structured as follow:
There is a pre-pipeline step, which involves the creation of a config files with variables and informations useful to the pipeline

Then a pre-calling step with some preprocessing of raw data (fastq and bam files)
Finally the implementation of GATK4 best practices for variant calling.
Alternative calling option will involve samtools as the main caller.


---------------------------------------------------------------------------
## Steps:

0. Config files template generation
1. Align
2. BQSR
3. VarCall
4. PostVarCall
5. GDBIMP
6. VQSR
7. LastSSel


---------------------------------------------------------------------------
## Config file template generation

**File name:** 

**Description:**

**Input:**

**Output:**

**Example:**

```bash

for sample in A B C
do 

base_template= <base_folder>/${sample}
base_out= <base_out_path>/pipe_run
bash config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -v -m <(email)> -i <fastq_file path>

done

bash config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -b -m <(email)> -i <fastq_file path>
bash config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -w -m <(email)> -i <fastq_file path>
bash config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -p -m <(email)> -i <fastq_file path>
bash config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -g -m <(email)> -i <fastq_file path>
bash config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -q -m <(email)> -i <fastq_file path>
bash config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -l -m <(email)> -i <fastq_file path>


```

---------------------------------------------------------------------------
## Align

---------------------------------------------------------------------------
## BQSR

---------------------------------------------------------------------------
## VarCall

---------------------------------------------------------------------------
## PostVarCall
---------------------------------------------------------------------------
## GDBIMP

---------------------------------------------------------------------------
## VQSR

---------------------------------------------------------------------------
## LastSSel


---------------------------------------------------------------------------
## Sample command

