source ./global.sh

if [ "$#" -ne 1 ]; then
    echo "./BaseRecalibrator.sh #shardNum"
    exit
fi

lineNum=$1
# read from sequence_grouping.txt
listStr=`./getListFromLine.sh 0 $lineNum`
#echo $listStr

export _JAVA_OPTIONS=-Djava.io.tmpdir="$tmpDir"
export TMPDIR="$tmpDir"

bqsrDir="${outDir}/bqsr/${lineNum}"
mkdir -p $bqsrDir

$gatk4Tool --java-options "-XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10 -XX:+PrintFlagsFinal \
  -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintGCDetails \
  -Xloggc:gc_log.log -Xms4000m" \
  BaseRecalibrator \
  -R ${refDir}/Homo_sapiens_assembly38.fasta \
  -I ${outDir}/${base_file_name}.aligned.duplicate_marked.sorted.bam \
  --use-original-qualities \
  -O ${bqsrDir}/${base_file_name}.recal_data.csv \
  -known-sites ${refDir}/Homo_sapiens_assembly38.dbsnp138.vcf \
  -known-sites ${refDir}/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz -known-sites ${refDir}/Homo_sapiens_assembly38.known_indels.vcf.gz \
  $listStr
