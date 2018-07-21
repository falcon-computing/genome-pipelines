source ./global.sh

outDir="/genome/ssd2/peipei/output"
input_bam="${bamDir}/${base_file_name}.query.sorted.unmapped.bam"
unmapped_bam_basename=`basename $input_bam .unmapped.bam` 
#or unmapped_bam_basename="${base_file_name}.query.sorted"
output_bam_basename="${unmapped_bam_basename}.aligned.unsorted"
#or output_bam_basename="${base_file_name}.query.sorted.aligned.unsorted"

java -Dsamjdk.compression_level=2 -Xms4000m -jar $picardJar \
  MarkDuplicates \
  INPUT=${outDir}/${output_bam_basename}.bam \
  OUTPUT=${outDir}/${base_file_name}.aligned.unsorted.duplicates_marked.bam \
  METRICS_FILE=${outDir}/${base_file_name}.duplicate_metrics \
  VALIDATION_STRINGENCY=SILENT \
   \
  OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 \
  ASSUME_SORT_ORDER="queryname" \
  CLEAR_DT="false" \
  ADD_PG_TAG_TO_READS=false
