# Variant Calling pipeline for WES data

GitHub repo: https://github.com/macsx82/VariantCalling

This pipeline is adapted to run variant calling on WES data using GATK4

There is a pre-pipeline step, which involves the creation of a config files with variables and informations useful to the pipeline
Then a pre-calling step with some preprocessing of raw data (fastq and bam files)
Finally the implementation of GATK4 best practices for variant calling

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

```shellscript
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

```bash

for sample in CHW CHX CHY
do 

base_template=/home/cocca/analyses/hearing/F_call/19092018/${sample}
base_out=/scratch1/cocca/analyses/hearing/F_call/pipe_run
bash /home/cocca/scripts/pipelines/VariantCalling/config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -v -m massimiliano.cocca@burlo.trieste.it -i /scratch1/cocca/analyses/hearing/Ferrua_call/${sample}/4.fastq_post

done

bash /home/cocca/scripts/pipelines/VariantCalling/config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -b -m massimiliano.cocca@burlo.trieste.it -i /scratch1/cocca/analyses/hearing/Ferrua_call/${sample}/4.fastq_post
bash /home/cocca/scripts/pipelines/VariantCalling/config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -w -m massimiliano.cocca@burlo.trieste.it -i /scratch1/cocca/analyses/hearing/Ferrua_call/${sample}/4.fastq_post
bash /home/cocca/scripts/pipelines/VariantCalling/config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -p -m massimiliano.cocca@burlo.trieste.it -i /scratch1/cocca/analyses/hearing/Ferrua_call/${sample}/4.fastq_post
bash /home/cocca/scripts/pipelines/VariantCalling/config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -g -m massimiliano.cocca@burlo.trieste.it -i /scratch1/cocca/analyses/hearing/Ferrua_call/${sample}/4.fastq_post
bash /home/cocca/scripts/pipelines/VariantCalling/config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -q -m massimiliano.cocca@burlo.trieste.it -i /scratch1/cocca/analyses/hearing/Ferrua_call/${sample}/4.fastq_post
bash /home/cocca/scripts/pipelines/VariantCalling/config_file_creation.sh -t ${base_template} -o ${base_out} -s ${sample} -l -m massimiliano.cocca@burlo.trieste.it -i /scratch1/cocca/analyses/hearing/Ferrua_call/${sample}/4.fastq_post


```