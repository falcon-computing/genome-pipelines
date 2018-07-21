source ./global.sh

outDir="/genome/ssd2/peipei/output"
tmpDir="/genome/ssd2/peipei/output/tmp"

java -Dsamjdk.compression_level=2 -Xms4000m -jar $picardJar \
  SortSam \
  INPUT=${outDir}/${base_file_name}.aligned.unsorted.duplicates_marked.bam \
  OUTPUT=${outDir}/${base_file_name}.aligned.duplicate_marked.sorted.bam \
  TMP_DIR=$tmpDir \
  SORT_ORDER="coordinate" \
  CREATE_INDEX=true \
  CREATE_MD5_FILE=true \
  MAX_RECORDS_IN_RAM=300000
