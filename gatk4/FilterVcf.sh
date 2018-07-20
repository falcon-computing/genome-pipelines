source ./global.sh

if [ "$#" -ne 2 ]; then
    echo "./FilterVcf.sh #totalScatterCount #currentCount"
    exit
fi


export _JAVA_OPTIONS=-Djava.io.tmpdir="$tmpDir"
export TMPDIR="$tmpDir"

scatterCount=$1 
scatterListDir=${outDir}/scatterList_${scatterCount} 
scatterListGatherDir=${scatterListDir}_Gather 
currentCount=$2

htcDir=${outDir}/htc/${currentCount}

$gatk4Tool --java-options "-Xms3000m" \
 VariantFiltration \
 -V ${htcDir}/NA12878_falcon.vcf.gz \
 -L ${scatterListGatherDir}/${currentCount}scattered.interval_list \
 --filter-expression "QD < 2.0 || FS > 30.0 || SOR > 3.0 || MQ < 40.0 || MQRankSum < -3.0 || ReadPosRankSum < -3.0" \
 --filter-name "HardFiltered" \
 -O ${htcDir}/NA12878_falcon.filtered.vcf.gz

