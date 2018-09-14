#!/bin/bash
sample_id=$1

# need to setup these variables before start
local_dir=/local
fastq_dir=/local/fastq
ref_dir=/local/ref
ref_genome=$ref_dir/human_g1k_v37.fasta
db138_SNPs=$ref_dir/dbsnp_138.b37.vcf
WORK_DIR="/local/falcon"
ec2Type=`cat ${WORK_DIR}/log_0_instanceType`

start_ts=$(date +%s)
set -x 
fcs-genome bqsr \
    --gatk4 \
    -r $ref_genome \
    -i $local_dir/${sample_id}.bam \
    -o $local_dir/${sample_id}.recal.bam \
    -K $db138_SNPs -f

set +x

end_ts=$(date +%s)
echo "bqsr finishes in $((end_ts - start_ts)) seconds"
start_ts=$end_ts
aws s3 cp --recursive $local_dir/${sample_id}.recal.bam s3://fcs-genome-data/profileCloud/${ec2Type}/${sample_id}/${sample_id}.recal.bam/
end_ts=$(date +%s)
echo "bqsr upload result finishes in $((end_ts - start_ts)) seconds" 
