#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source $PARENTDIR/globals.sh.template

# global settings

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
temp_dir=${tmp_dir}/$id
mkdir -p $temp_dir

dir=/curr/diwu/release/

# check versions
suite_version=v1.1.2
bwa_version=v0.4.0-dev
gatk_version=3.8
release_version=v1.1.1

# build folder
mkdir -p falcon/bin
cp -r $dir/tools falcon/tools
cp $dir/common/* falcon/

cp $dir/fcs-genome/fcs-genome-${suite_version} falcon/bin/fcs-genome
cp $dir/bwa/bwa-${bwa_version} falcon/tools/bin/bwa-bin
cp $dir/gatk/GATK-${gatk_version}.jar falcon/tools/package/GenomeAnalysisTK.jar

tar zcfh $dir/falcon-genome-${release_version}.tgz falcon/

source falcon/setup.sh

fastq_file_path=$1
fastq_files=()
output_dir=$2

echo "release version ${release_version}"
echo "fcs-genome version ${suite_version}"
echo "bwa version ${bwa_version}"
echo "gatk version ${gatk_version}"

echo "STEP 1: Alignment to reference" >> $out_file
start_ts=$(date +%s)

#Alignment to Reference
fcs-genome align \
        --ref $ref_genome \
        --fastq1 ${fastq_file_path}/${i}_1.fastq.gz \
        --fastq2 ${fastq_file_path}/${i}_2.fastq.gz \
        --output $temp_dir/${id}_aligned.bam \
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
        --input ${temp_dir}/${id}_aligned.bam \
        --output ${temp_dir}/${id}_marked.bam \
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
java -jar $PICARD CollectAlignmentSummaryMetrics R=$ref_genome I=$temp_dir/${id}_marked.bam O=${temp_dir}/alignment_metics.txt

java -jar $PICARD CollectInsertSizeMetrics INPUT=${temp_dir}/${id}_marked.bam OUTPUT=${temp_dir}/insert_metrics.txt HISTOGRAM_FILE=${temp_dir}/insert_size_histogram.pdf 

$SAMTOOLS depth -a ${temp_dir}/${id}_marked.bam > ${temp_dir}/depth_out.txt

end_ts=$(date +%s)
echo "Metrics Collection finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: alignment_metrics.txt AND insert_metrics.txt" >> $out_file
echo "" >> $out_file

echo "STEP 4: Indel Realignment" >> $out_file
start_ts=$(date +%s)

#Indel Realignment 
fcs-genome indel --ref $ref_genome \
  --input ${temp_dir}/${id}_marked.bam \
  --output ${temp_dir}/${id}_realigned.bam -f

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
        --input ${temp_dir}/${id}_realigned.bam \
        --output $temp_dir/${id}_raw.vcf --produce-vcf -f

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
  -V ${temp_dir}/${id}_raw.vcf.gz \
  -selectType SNP \
  -o ${temp_dir}/raw_snps.vcf

fcs-genome gatk \
  -T SelectVariants \
  -R $ref_genome \
  -V ${temp_dir}/${id}_raw.vcf.gz \
  -selectType INDEL \
  -selectType INDEL \
  -o ${temp_dir}/raw_indels.vcf

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
  -V ${temp_dir}/raw_snps.vcf --filterExpression '"QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 4.0"' \
  --filterName "basic_snp_filter" -o ${temp_dir}/filtered_snps.vcf

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
  -V ${temp_dir}/raw_indels.vcf --filterExpression '"QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0"' \
  --filterName "basic_indel_filter" -o ${temp_dir}/filtered_indels.vcf

end_ts=$(date +%s)
echo "Indel Filtration finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: filtered_indels.vcf" >> $out_file
echo "" >> $out_file

echo "STEP 9: Base Recalibration #1" >> $out_file
start_ts=$(date +%s)

#BQSR #1
fcs-genome baserecal \
        --ref $ref_genome \
        --input ${temp_dir}/${id}_realigned.bam \
        --output $temp_dir/${id}_recal_data.table \
        --knownSites ${temp_dir}/filtered_snps.vcf \
        --knownSites ${temp_dir}/filtered_indels.vcf -f

end_ts=$(date +%s)
echo "Base Recalibration #1 finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: ${id}_recal_data.table" >> $out_file
echo "" >> $out_file

echo "STEP 10: Base Recalibration #2" >> $out_file
start_ts=$(date +%s)

#BQSR 2
fcs-genome baserecal \
        --ref $ref_genome \
        --input ${temp_dir}/${id}_realigned.bam \
        --output $temp_dir/${id}_post_recal_data.table \
        --knownSites ${temp_dir}/filtered_snps.vcf \
        --knownSites ${temp_dir}/filtered_indels.vcf \
        -O --BQSR $temp_dir/${id}_recal_data.table -f

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
  -before $temp_dir/${id}_recal_data.table \
  -after $temp_dir/${id}_post_recal_data.table \
  -plots ${temp_dir}/recalibration_plots.pdf

end_ts=$(date +%s)
echo "Covariate Analysis finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: recalibration_plots.pdf" >> $out_file
echo "" >> $out_file

echo "STEP 12: Print Reads" >> $out_file
start_ts=$(date +%s)

#Print Reads
fcs-genome printreads \
        --ref $ref_genome \
        --bqsr $temp_dir/${id}_recal_data.table \
        --input ${temp_dir}/${id}_realigned.bam \
        --output ${temp_dir}/${id}_recal_reads.bam -f

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
        --input ${temp_dir}/${id}_recal_reads.bam \
        --output $temp_dir/${id}_raw_variants_recal.vcf --produce-vcf -f

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
  -V ${temp_dir}/${id}_raw_variants_recal.vcf.gz \
  -selectType SNP \
  -o ${temp_dir}/raw_snps_recal.vcf

fcs-genome gatk \
  -T SelectVariants \
  -R $ref_genome \
  -V ${temp_dir}/${id}_raw_variants_recal.vcf.gz \
  -selectType INDEL \
  -o ${temp_dir}/raw_indels_recal.vcf

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
  -V ${temp_dir}/raw_snps_recal.vcf \
  --filterExpression '"QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 4.0"'  \
  --filterName "basic_snp_filter" -o ${temp_dir}/filtered_snps_final.vcf

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
  -V ${temp_dir}/raw_indels_recal.vcf \
  --filterExpression '"QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0"' \
  --filterName "basic_indel_filter" -o ${temp_dir}/filtered_indels_recal.vcf

end_ts=$(date +%s)
echo "Indel Filtration finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: filtered_indels_recal.vcf" >> $out_file
echo "" >> $out_file

echo "STEP 17: SNP Annotation" >> $out_file
start_ts=$(date +%s)

#Annotate SNPs and Predict Effects
java -jar $SNPEFF \
  -v -cancer $snpEff_db ${temp_dir}/filtered_indels_recal.vcf > ${temp_dir}/filtered_snps_final.ann.vcf

end_ts=$(date +%s)
echo "SNP Annotation finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: filtered_snps_final.ann.vcf" >> $out_file
echo "" >> $out_file

echo "STEP 18: Coverage Calculation" >> $out_file
start_ts=$(date +%s)

#Compute coverage
./cov.sh ${temp_dir}/${id}_recal_reads.bam ${output_dir}

end_ts=$(date +%s)
echo "Coverage Calculation finishes in $((end_ts - start_ts))s" >> $out_file
echo "Output_file: coverage.bed" >> $out_file
echo "" >> $out_file




