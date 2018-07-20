source ./global.sh

if [ "$#" -ne 2 ]; then
    echo "./HaplotypeCaller.sh #totalScatterCount #currentCount"
    exit
fi


export _JAVA_OPTIONS=-Djava.io.tmpdir="$tmpDir"
export TMPDIR="$tmpDir"

scatterCount=$1 
scatterListDir=${outDir}/scatterList_${scatterCount} 
scatterListGatherDir=${scatterListDir}_Gather 
currentCount=$2

htcDir=${outDir}/htc/${currentCount}

mkdir -p $htcDir

contaminationValue=`python CheckContaminationSelfSM.py`
echo $contaminationValue

$gatk4Tool --java-options "-Dfile.encoding=UTF-8 -Xms6000m -XX:GCTimeLimit=50 -XX:GCHeapFreeLimit=10" \
  HaplotypeCaller \
  -R ${refDir}/Homo_sapiens_assembly38.fasta \
  -I ${outDir}/NA12878_falcon.bam \
  -L ${scatterListGatherDir}/${currentCount}scattered.interval_list \
  -O ${htcDir}/NA12878_falcon.vcf.gz \
  -contamination $contaminationValue
