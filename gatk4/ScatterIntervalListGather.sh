source ./global.sh

if [ "$#" -ne 1 ]; then
    echo "./ScatterIntervalListGather.sh #haplotype_scatter_count"
    exit
fi

scatterCount=$1
scatterListDir=${outDir}/scatterList_${scatterCount}
echo $scatterListDir
scatterListGatherDir=${scatterListDir}_Gather
mkdir $scatterListGatherDir

for i in `ls ${scatterListDir}/*/*interval_list`;do
echo $i;
cp $i $scatterListGatherDir
done
