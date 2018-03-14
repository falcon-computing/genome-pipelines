#!/bin/bash

CURR_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source $CURR_DIR/globals.sh
source $FALCON_DIR/setup.sh

out_file="log.out"

if [[ $# -ne 3 ]];then
  echo "USAGE: $0 [Fastq_file_path] [Fastq_id] [Path_to_Output_dir]"
  exit 1
fi

fastq_file_path=$1
fastq_files=()
output_dir=$3
snpEff_db="GRCh38.86"
i=$2

id=$i
platform=Illumina
library=$i

echo "ID: $id"
mkdir -p $output_dir/$id

echo "STEP 1: Alignment to reference" >> $out_file
start_ts=$(date +%s)

#Alignment to Reference
fcs-genome align \
        --ref $ref_genome \
        --fastq1 ${fastq_file_path}/${i}_1.fastq.gz \
        --fastq2 ${fastq_file_path}/${i}_2.fastq.gz \
        --output $output_dir/${id}_aligned.bam \
        --rg $id --sp $id --pl $platform --lb $library --align-only -f

end_ts=$(date +%s)
echo "BWA-MEM finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: ${id}_aligned.bam" >> $out_file
echo "" >> $out_file

if [[ $? -ne 0 ]];then
  echo "Failed alignment to reference" >> $out_file 
  exit 1
fi

echo "STEP 2: Mark Duplicates" >> $out_file
start_ts=$(date +%s)

#Mark Duplicates
fcs-genome markDup \
        --input ${output_dir}/${id}_aligned.bam \
        --output ${output_dir}/${id}_marked.bam \
        -f

end_ts=$(date +%s)
echo "Mark Duplicates finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: ${id}_marked.bam" >> $out_file
echo "" >> $out_file

if [[ $? -ne 0 ]];then
  echo "Failed mark duplicates"
  exit 1
fi

echo "STEP 3: Collect Alignment & Insert Size Metrics" >> $out_file
start_ts=$(date +%s)

# Collect Alignment & Insert Size Metrics
java -jar $PICARD CollectAlignmentSummaryMetrics R=$ref_genome I=$output_dir/${id}_marked.bam O=${output_dir}/alignment_metics.txt

java -jar $PICARD CollectInsertSizeMetrics INPUT=${output_dir}/${id}_marked.bam OUTPUT=${output_dir}/insert_metrics.txt HISTOGRAM_FILE=${output_dir}/insert_size_histogram.pdf 

$SAMTOOLS depth -a ${output_dir}/${id}_marked.bam > ${output_dir}/depth_out.txt

end_ts=$(date +%s)
echo "Metrics Collection finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: alignment_metrics.txt AND insert_metrics.txt" >> $out_file
echo "" >> $out_file

echo "STEP 4: Indel Realignment" >> $out_file
start_ts=$(date +%s)

#Indel Realignment 
fcs-genome indel --ref $ref_genome \
  --input ${output_dir}/${id}_marked.bam \
  --output ${output_dir}/${id}_realigned.bam -f

end_ts=$(date +%s)
echo "Indel Realignment finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: ${id}_realigned.bam" >> $out_file
echo "" >> $out_file

if [[ $? -ne 0 ]];then
  echo "Failed indel realignment"
  exit 1
fi 

echo "STEP 5: Variant Calling" >> $out_file
start_ts=$(date +%s)

#Call Variants
fcs-genome htc \
        --ref $ref_genome \
        --input ${output_dir}/${id}_realigned.bam \
        --output $output_dir/${id}_raw.vcf --produce-vcf -f

if [[ $? -ne 0 ]];then
  echo "Failed haplotype caller"
fi

end_ts=$(date +%s)
echo "Variant Calling finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: ${id}_raw.vcf" >> $out_file
echo "" >> $out_file

echo "STEP 6: Extract SNP and Indels" >> $out_file
start_ts=$(date +%s)

#Extract SNP & Indels
fcs-genome gatk \
  -T SelectVariants \
  -R $ref_genome \
  -V ${output_dir}/${id}_raw.vcf.gz \
  -selectType SNP \
  -o ${output_dir}/raw_snps.vcf

fcs-genome gatk \
  -T SelectVariants \
  -R $ref_genome \
  -V ${output_dir}/${id}_raw.vcf.gz \
  -selectType INDEL \
  -selectType INDEL \
  -o ${output_dir}/raw_indels.vcf

end_ts=$(date +%s)
echo "SNP/Indel Extraction finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: raw_snps.vcf AND raw_indels.vcf" >> $out_file
echo "" >> $out_file

echo "STEP 7: SNP Filtration" >> $out_file
start_ts=$(date +%s)

#Filer SNPs
fcs-genome gatk \
  -T VariantFiltration \
  -R $ref_genome \
  -V ${output_dir}/raw_snps.vcf --filterExpression '"QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 4.0"' \
  --filterName "basic_snp_filter" -o ${output_dir}/filtered_snps.vcf

end_ts=$(date +%s)
echo "SNP Filtration finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: filtered_snps.vcf" >> $out_file
echo "" >> $out_file

echo "STEP 8: Indel Filtration" >> $out_file
start_ts=$(date +%s)

#Filter Indels
fcs-genome gatk \
  -T VariantFiltration \
  -R $ref_genome \
  -V ${output_dir}/raw_indels.vcf --filterExpression '"QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0"' \
  --filterName "basic_indel_filter" -o ${output_dir}/filtered_indels.vcf

end_ts=$(date +%s)
echo "Indel Filtration finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: filtered_indels.vcf" >> $out_file
echo "" >> $out_file

echo "STEP 9: Base Recalibration #1" >> $out_file
start_ts=$(date +%s)

#BQSR #1
fcs-genome baserecal \
        --ref $ref_genome \
        --input ${output_dir}/${id}_realigned.bam \
        --output $output_dir/${id}_recal_data.table \
        --knownSites ${output_dir}/filtered_snps.vcf \
        --knownSites ${output_dir}/filtered_indels.vcf -f

end_ts=$(date +%s)
echo "Base Recalibration #1 finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: ${id}_recal_data.table" >> $out_file
echo "" >> $out_file

echo "STEP 10: Base Recalibration #2" >> $out_file
start_ts=$(date +%s)

#BQSR 2
fcs-genome baserecal \
        --ref $ref_genome \
        --input ${output_dir}/${id}_realigned.bam \
        --output $output_dir/${id}_post_recal_data.table \
        --knownSites ${output_dir}/filtered_snps.vcf \
        --knownSites ${output_dir}/filtered_indels.vcf \
        -O --BQSR $output_dir/${id}_recal_data.table -f

end_ts=$(date +%s)
echo "Base Recalibration #2 finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: ${id}_post_recal_data.table" >> $out_file
echo "" >> $out_file

echo "STEP 11: Analyze Covariates" >> $out_file
start_ts=$(date +%s)

#Analyse Covariates
fcs-genome gatk \
  -T AnalyzeCovariates \
  -R $ref_genome \
  -before $output_dir/${id}_recal_data.table \
  -after $output_dir/${id}_post_recal_data.table \
  -plots ${output_dir}/recalibration_plots.pdf

end_ts=$(date +%s)
echo "Covariate Analysis finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: recalibration_plots.pdf" >> $out_file
echo "" >> $out_file

echo "STEP 12: Print Reads" >> $out_file
start_ts=$(date +%s)

#Print Reads
fcs-genome printreads \
        --ref $ref_genome \
        --bqsr $output_dir/${id}_recal_data.table \
        --input ${output_dir}/${id}_realigned.bam \
        --output ${output_dir}/${id}_recal_reads.bam -f

end_ts=$(date +%s)
echo "Print Reads finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: ${id}_recal_reads.bam" >> $out_file
echo "" >> $out_file

if [[ $? -ne 0 ]];then
echo "Failed print reads"
fi

echo "STEP 13: Variant Calling" >> $out_file
start_ts=$(date +%s)

#Call Variants
fcs-genome htc \
        --ref $ref_genome \
        --input ${output_dir}/${id}_recal_reads.bam \
        --output $output_dir/${id}_raw_variants_recal.vcf --produce-vcf -f

end_ts=$(date +%s)
echo "Variant Calling finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: ${id}_raw_variants_recal.vcf" >> $out_file
echo "" >> $out_file

if [[ $? -ne 0 ]];then
  echo "Failed haplotype caller"
fi

echo "STEP 14: SNP/Indel Extraction" >> $out_file
start_ts=$(date +%s)

#Extract SNPs & Indels
fcs-genome gatk \
  -T SelectVariants \
  -R $ref_genome \
  -V ${output_dir}/${id}_raw_variants_recal.vcf.gz \
  -selectType SNP \
  -o ${output_dir}/raw_snps_recal.vcf

fcs-genome gatk \
  -T SelectVariants \
  -R $ref_genome \
  -V ${output_dir}/${id}_raw_variants_recal.vcf.gz \
  -selectType INDEL \
  -o ${output_dir}/raw_indels_recal.vcf

end_ts=$(date +%s)
echo "SNP/Indel Extraction finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: raw_snps_recal.vcf AND raw_indels_recal.vcf" >> $out_file
echo "" >> $out_file

echo "STEP 15: SNP Filtration" >> $out_file
start_ts=$(date +%s)

#Filer SNPs
fcs-genome gatk \
  -T VariantFiltration \
  -R $ref_genome \
  -V ${output_dir}/raw_snps_recal.vcf \
  --filterExpression '"QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 4.0"'  \
  --filterName "basic_snp_filter" -o ${output_dir}/filtered_snps_final.vcf

end_ts=$(date +%s)
echo "SNP Filtration finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: filtered_snps_final.vcf" >> $out_file
echo "" >> $out_file

echo "STEP 16: Indel Filtration" >> $out_file
start_ts=$(date +%s)

#Filter Indels
fcs-genome gatk \
  -T VariantFiltration \
  -R $ref_genome \
  -V ${output_dir}/raw_indels_recal.vcf \
  --filterExpression '"QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0"' \
  --filterName "basic_indel_filter" -o ${output_dir}/filtered_indels_recal.vcf

end_ts=$(date +%s)
echo "Indel Filtration finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: filtered_indels_recal.vcf" >> $out_file
echo "" >> $out_file

echo "STEP 17: SNP Annotation" >> $out_file
start_ts=$(date +%s)

#Annotate SNPs and Predict Effects
java -jar $SNPEFF \
  -v -cancer $snpEff_db ${output_dir}/filtered_indels_recal.vcf > ${output_dir}/filtered_snps_final.ann.vcf

mv snpEff_genes.txt ${output_dir}
mv snpEff_summary.html ${output_dir}

end_ts=$(date +%s)
echo "SNP Annotation finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: filtered_snps_final.ann.vcf" >> $out_file
echo "" >> $out_file

echo "STEP 18: Coverage Calculation" >> $out_file
start_ts=$(date +%s)
<<com
#Compute coverage
$CURR_DIR/cov.sh ${output_dir}/${id}_recal_reads.bam ${output_dir}
com

#Store list of BAMs from path into list file
if [ -d "${output_dir}/${id}_recal_reads.bam" ];then
 for file in $(ls "${output_dir}/${id}_recal_reads.bam")
  do
    if [[ $file =~ bam$ ]];then
      echo "${output_dir}/${id}_recal_reads.bam/$file" >> ${output_dir}/${id}_bamnames.list
    fi
  done
fi

#Use list file as input for BAM coverage calculation
fcs-genome gatk \
  -T DepthOfCoverage \
  -R $ref_genome \
  -o ${output_dir}/${id}_coverage.cov \
  -I ${output_dir}/${id}_bamnames.list \
  --minMappingQuality 20 \
  --minBaseQuality 20 \
  -omitBaseOutput

end_ts=$(date +%s)
echo "Coverage Calculation finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: coverage.cov" >> $out_file
echo "" >> $out_file

