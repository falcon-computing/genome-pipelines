source ./global.sh

if [ "$#" -ne 1 ]; then
    echo "./ApplyBQSR.sh #shardNum"
    exit
fi

lineNum=$1
# read from sequence_grouping_with_unmapped.txt
listStr=`./getListFromLine.sh 1 $lineNum`
echo $listStr

export _JAVA_OPTIONS=-Djava.io.tmpdir="$tmpDir"
export TMPDIR="$tmpDir"

applybqsrDir="${outDir}/applybqsr/${lineNum}"
mkdir -p $applybqsrDir

$gatk4Tool --java-options "-XX:+PrintFlagsFinal -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps \
  -XX:+PrintGCDetails -Xloggc:gc_log.log \
  -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -Dsamjdk.compression_level=2 -Xms3000m" \
  ApplyBQSR \
  --create-output-bam-md5 \
  --add-output-sam-program-record \
  -R ${refDir}/Homo_sapiens_assembly38.fasta \
  -I ${outDir}/${base_file_name}.aligned.duplicate_marked.sorted.bam \
  --use-original-qualities \
  -O ${applybqsrDir}/${base_file_name}.aligned.duplicates_marked.recalibrated.bam \
  -bqsr ${outDir}/${base_file_name}.recal_data.csv \
  --static-quantized-quals 10 --static-quantized-quals 20 --static-quantized-quals 30 \
  $listStr
