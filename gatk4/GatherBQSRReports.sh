source ./global.sh

export _JAVA_OPTIONS=-Djava.io.tmpdir="$tmpDir"
export TMPDIR="$tmpDir"

rptStr=""
for lineNum in `seq 1 18`;do
bqsrDir="${outDir}/bqsr/${lineNum}"
rptStr="${rptStr}-I ${bqsrDir}/NA12878_falcon.recal_data.csv "
done 
echo $rptStr

$gatk4Tool --java-options "-Xms3000m" \
  GatherBQSRReports \
  $rptStr \
  -O ${outDir}/NA12878_falcon.recal_data.csv
