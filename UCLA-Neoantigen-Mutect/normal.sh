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
log_file=${sample_id}.log

mkdir -p $output_dir

$CURR_DIR/tumor.sh $sample_id $input_dir $output_dir

if [ $? -ne 0 ]; then
  exit 1	
fi

echo "STEP 4: Raw variant calling"
start_ts=$(date +%s)
#Call Variants
fcs-genome htc \
        -r $ref_genome \
        -i $output_dir/${sample_id}_realn.bam \
        -o $output_dir/${sample_id}_raw.vcf \
	--extra-options "-minPruning 6" \
	--produce-vcf -f

if [ $? -ne 0 ];then
  echo "Failed haplotype caller"
  exit 1
fi

end_ts=$(date +%s)
echo "STEP 4 finishes in $((end_ts - start_ts)) s"
echo ""

echo "STEP 5: Extract SNP and IND from raw VCF"
start_ts=$(date +%s)

# Extract SNP & Indels
fcs-genome gatk \
    -T SelectVariants \
    -R $ref_genome \
    -V ${output_dir}/${sample_id}_raw.vcf.gz \
    -selectType SNP \
    -o ${output_dir}/${sample_id}_raw_snps.vcf

if [ $? -ne 0 ];then
  echo "Failed SelectVariants"
  exit 1
fi

fcs-genome gatk \
    -T SelectVariants \
    -R $ref_genome \
    -V ${output_dir}/${sample_id}_raw.vcf.gz \
    -selectType INDEL \
    -o ${output_dir}/${sample_id}_raw_indels.vcf

if [ $? -ne 0 ];then
    echo "Failed SelectVariants"
    exit 1
fi

end_ts=$(date +%s)
echo "STEP 5 finishes in $((end_ts - start_ts)) s"
echo ""

echo "STEP 6: Base Recalibration"
start_ts=$(date +%s)

#BQSR #1
fcs-genome bqsr \
    -r $ref_genome \
    -i $output_dir/${sample_id}_realn.bam \
    -o $output_dir/${sample_id}_recal.bam \
    --knownSites ${output_dir}/${sample_id}_raw_snps.vcf \
    --knownSites ${output_dir}/${sample_id}_raw_indels.vcf -f

if [ $? -ne 0 ]; then
    echo "Failed BQSR"
    exit 1
fi

end_ts=$(date +%s)
echo "STEP 6 finishes in $((end_ts - start_ts)) s"
echo ""

echo "STEP 7: Final variant calling"
start_ts=$(date +%s)

#Call Variants
fcs-genome htc \
        -r $ref_genome \
        -i $output_dir/${sample_id}_recal.bam \
        -o $output_dir/${sample_id}_raw_variants_recal.vcf \
	--produce-vcf -f

if [ $? -ne 0 ]; then
    echo "Failed haplotype caller"
    exit 1
fi

end_ts=$(date +%s)
echo "STEP 7 finishes in $((end_ts - start_ts)) s"


