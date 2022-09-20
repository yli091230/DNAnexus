#!/bin/bash

hipmulti=$(dx ls --brief HipSTR_call/workflow/hipstr_multi | grep workflow)
job_date=$(date '+%Y_%m_%d_%H')
log_folder=job_log/${hipmulti}_${job_date}_submission/
input_folder=${log_folder}/input_json/
log_file=${log_folder}/submission_log.txt
mkdir -p ${log_folder}
mkdir -p ${input_folder}
echo "Use workflow ${hipmulti}" >> ${log_file}

for file_n in $(seq -f %03g 20 154)
do
  chro_ref_id=$(dx ls --long /HipSTR_call/references/hipref_10k_per_file/ |  awk -v chr_ref="hipref_split_${file_n}" '$6==chr_ref {print $NF}' | tr '()' '""')
  echo "  Submit STR ref number ${file_n} using file ID ${chro_ref_id}" >> ${log_file}
  sed s/REF_FILE/${chro_ref_id}/g hipstr_100sample_template_input.json > ${input_folder}/hipstr_multi_hipref_${file_n}_input.json
  dx run ${hipmulti} -y -f ${input_folder}/hipstr_multi_hipref_${file_n}_input.json  --name hipref_${file_n} --destination /HipSTR_call/results/random_100_sample_cram_ab_15G/hipref_10k/hipref_${file_n}/ | awk '{print "\t\t"$0}' >> ${log_file}
  echo "Chromosome ${file_n} using file ID ${chro_ref_id} submitted."  

done
