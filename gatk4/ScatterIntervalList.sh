source ./global.sh

if [ "$#" -ne 1 ]; then
    echo "./ScatterIntervalList.sh #haplotype_scatter_count"
    exit
fi

outDirFC="/genome/ssd2/peipei/output/copyFromFireCloud"
outDir="/genome/ssd2/peipei/output"
refDir="/genome/ssd2/peipei/1reference"
outDirFC=$outDir

scatterCount=$1
scatterListDir=${outDir}/scatterList_${scatterCount}

tmpDir="/genome/ssd2/peipei/output/tmp"
set -e
mkdir $scatterListDir
java -Xms1g -jar $picardJar \
  IntervalListTools \
  SCATTER_COUNT=$scatterCount \
  SUBDIVISION_MODE=BALANCING_WITHOUT_INTERVAL_SUBDIVISION_WITH_OVERFLOW \
  UNIQUE=true \
  SORT=true \
  BREAK_BANDS_AT_MULTIPLES_OF=1000000 \
  INPUT=${refDir}/wgs_calling_regions.hg38.interval_list \
  OUTPUT=$scatterListDir


