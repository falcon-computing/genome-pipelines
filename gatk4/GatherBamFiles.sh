source ./global.sh

export _JAVA_OPTIONS=-Djava.io.tmpdir="$tmpDir"
export TMPDIR="$tmpDir"

totalLineNum=19
bamStr=""
for lineNum in `seq 1 $totalLineNum`;do
applybqsrDir="${outDir}/applybqsr/${lineNum}"
bamStr="${bamStr}INPUT=${applybqsrDir}/${base_file_name}.aligned.duplicates_marked.recalibrated.bam "
done

#echo $bamStr

java -Dsamjdk.compression_level=2 -Xms2000m -jar $picardJar \
  GatherBamFiles \
  $bamStr \
  OUTPUT=${outDir}/${base_file_name}.bam \
  CREATE_INDEX=true \
  CREATE_MD5_FILE=true
