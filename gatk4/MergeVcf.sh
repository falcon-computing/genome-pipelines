source ./global.sh

if [ "$#" -ne 1 ]; then
    echo "./MergeVcf.sh #totalScatterCount "

    exit
fi


export _JAVA_OPTIONS=-Djava.io.tmpdir="$tmpDir"
export TMPDIR="$tmpDir"

scatterCount=$1 
scatterListDir=${outDir}/scatterList_${scatterCount} 
scatterListGatherDir=${scatterListDir}_Gather 

filterVcfStr=""
for currentCount in `seq 1 $scatterCount`;do
htcDir=${outDir}/htc/${currentCount}
filterVcfStr="${filterVcfStr}INPUT=${htcDir}/NA12878_falcon.filtered.vcf.gz "
done

echo $filterVcfStr
java -Xms2000m -jar $picardJar \
  MergeVcfs \
  $filterVcfStr \
  OUTPUT=${outDir}/NA12878_falcon.filtered.vcf.gz
