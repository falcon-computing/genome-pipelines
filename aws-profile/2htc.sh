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
#fcs-genome align \
#    -r $ref_genome \
#    -1 $fastq_dir/${sample_id}_1.fastq.gz \
#    -2 $fastq_dir/${sample_id}_2.fastq.gz \
#    -o $local_dir/${sample_id}.bam \
#    -R $sample_id -S $sample_id -L $sample_id -P illumina -f
#
#fcs-genome bqsr \
#    --gatk4 \
#    -r $ref_genome \
#    -i $local_dir/${sample_id}.bam \
#    -o $local_dir/${sample_id}.recal.bam \
#    -K $db138_SNPs -f

fcs-genome htc \
    --gatk4 \
    -r $ref_genome \
    -i $local_dir/${sample_id}.recal.bam \
    -o $local_dir/${sample_id}.vcf -v -f
set +x

end_ts=$(date +%s)
echo "htc finishes in $((end_ts - start_ts)) seconds"
start_ts=$end_ts
aws s3 cp $local_dir/${sample_id}.vcf.gz s3://fcs-genome-data/profileCloud/${ec2Type}/${sample_id}/
aws s3 cp $local_dir/${sample_id}.vcf.gz.tbi s3://fcs-genome-data/profileCloud/${ec2Type}/${sample_id}/
end_ts=$(date +%s)
echo "htc upload result finishes in $((end_ts - start_ts)) seconds" 
