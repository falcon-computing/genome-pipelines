#!/bin/bash
sample_id=$1

#local_dir=/genome_fs/local/temp/user
ref_dir=/genome/local/ref
ref_genome=$ref_dir/human_g1k_v37.fasta
db138_SNPs=$ref_dir/dbsnp_138.b37.vcf
g1000_indels=$ref_dir/1000G_phase1.indels.b37.vcf
g1000_gold_standard_indels=$ref_dir/Mills_and_1000G_gold_standard.indels.b37.vcf

start_ts=$(date +%s)
set -x 
fcs-genome align \
    -r $ref_genome \
    -1 /genome/disk1/fastq/${sample_id}_1.fastq.gz \
    -2 /genome/disk1/fastq/${sample_id}_2.fastq.gz \
    -o ${sample_id}.bam \
    -R $sample_id -S $sample_id -L $sample_id -P illumina -f

fcs-genome bqsr \
    -r $ref_genome \
    -i ${sample_id}.bam \
    -o ${sample_id}.recal.bam \
    -K $db138_SNPs \
    -K $g1000_indels \
    -K $g1000_gold_standard_indels -f

fcs-genome htc \
    -r $ref_genome \
    -i ${sample_id}.recal.bam \
    -o ${sample_id}.vcf -v -f
set +x

end_ts=$(date +%s)
echo "Pipeline finishes in $((end_ts - start_ts)) seconds"
