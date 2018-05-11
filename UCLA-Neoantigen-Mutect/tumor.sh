#!/bin/bash
CURR_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source $CURR_DIR/globals.sh
source $FALCON_DIR/setup.sh

if [ $# -ne 3 ]; then
  echo "USAGE: $0 sample_id input_dir output_dir"
  exit 1
fi

sample_id=$1
input_dir=$2
output_dir=$3
log_file=$output_dir/${sample_id}.log

platform=Illumina
library=$sample_id

echo "Processing sample $sample_id"

mkdir -p $output_dir

echo "STEP 1: Alignment to reference"

fastq1=$(ls $input_dir/${sample_id}*_R1.fastq.gz)
fastq2=$(ls $input_dir/${sample_id}*_R2.fastq.gz)

if [ -z "$fastq1" -o -z "$fastq2" ]; then
  echo "cannot find fastq files"
  exit 1
fi

echo "FASTQ1: $fastq1"
echo "FASTQ2: $fastq2"

if [ \( ! -f "$fastq1" \) -o \( ! -f "$fastq2" \) ]; then
  echo "cannot find fastq files"
  exit 1
fi

start_ts=$(date +%s)
#
##Alignment to Reference
fcs-genome align \
        -r $ref_genome \
        -1 $fastq1 \
        -2 $fastq2 \
        -o $output_dir/${sample_id}_marked.bam \
        --rg $sample_id \
        --sp $sample_id \
        --pl $platform \
        --lb $library -f

if [ $? -ne 0 ];then
  echo "Failed alignment to reference"
  exit 1
fi

end_ts=$(date +%s)

echo "STEP 1 finishes in $((end_ts - start_ts)) s"
echo ""

echo "STEP 2: Collect Alignment & Insert Size Metrics"
start_ts=$(date +%s)
#
## Collect Alignment & Insert Size Metrics
java -jar $PICARD CollectAlignmentSummaryMetrics \
    R=$ref_genome \
    I=$output_dir/${sample_id}_marked.bam \
    O=$output_dir/${sample_id}_align_metrics.txt &> $log_file
#
if [ $? -ne 0 ]; then
  echo "failed picard CollectAlignmentSummaryMetrics"
  exit 1
fi
#
java -jar $PICARD CollectInsertSizeMetrics \
    INPUT=${output_dir}/${sample_id}_marked.bam \
    OUTPUT=${output_dir}/${sample_id}_insert_metrics.txt \
    HISTOGRAM_FILE=${output_dir}/${sample_id}_insert_size_histogram.pdf &> $log_file
#
if [ $? -ne 0 ]; then
  echo "failed picard CollectInsertSizeMetrics"
  exit 1
fi

# TODO: change to gatk version
#$SAMTOOLS depth -a ${output_dir}/${id}_marked.bam > ${output_dir}/depth_out.txt

end_ts=$(date +%s)
echo "STEP 2 finishes in $((end_ts - start_ts)) s"
echo ""

echo "STEP 3: Indel Realignment"
start_ts=$(date +%s)

#Indel Realignment 
fcs-genome indel \
    -r $ref_genome \
    -i ${output_dir}/${sample_id}_marked.bam \
    -o ${output_dir}/${sample_id}_realn.bam \
    -f 

if [ $? -ne 0 ]; then
   echo "Failed indel realignment"
   exit 1
fi 

end_ts=$(date +%s)
echo "STEP 3 finishes in $((end_ts - start_ts)) s"
echo ""

