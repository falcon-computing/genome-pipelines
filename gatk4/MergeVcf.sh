source ./global.sh

if [ "$#" -ne 2 ]; then
    echo "./MergeVcf.sh #totalScatterCount #filterFlag "

    exit
fi

filterFlag=$2

export _JAVA_OPTIONS=-Djava.io.tmpdir="$tmpDir"
export TMPDIR="$tmpDir"

scatterCount=$1 
scatterListDir=${outDir}/scatterList_${scatterCount} 
scatterListGatherDir=${scatterListDir}_Gather 

filterVcfStr=""
for currentCount in `seq 1 $scatterCount`;do
htcDir=${outDir}/htc/${currentCount}
if [ $filterFlag -eq "0" ];then 
filterVcfStr="${filterVcfStr}INPUT=${htcDir}/${base_file_name}.vcf.gz "
else
filterVcfStr="${filterVcfStr}INPUT=${htcDir}/${base_file_name}.filtered.vcf.gz "
fi
done

echo $filterVcfStr
java -Xms2000m -jar $picardJar \
  MergeVcfs \
  $filterVcfStr \
  OUTPUT=${outDir}/${base_file_name}.filtered_${filterFlag}.vcf.gz
