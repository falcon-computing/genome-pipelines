source ./global.sh

set -e
# this number is provided in five-dollar-genome-analysis-pipeline reference flow on FireCloud
scatterCount=50

# htcParallelism is the htc caller parallelism, 10 works, 50 does not work, optimal needs to be explored
htcParallelism=10

./SamToFastqAndBwaMemAndMba.sh
./MarkDuplicates.sh
./SortSampleBam.sh

#createSequenceGroupTSV only needs 1 time, and it is the same for different inputs
#it creates two files: sequence_grouping.txt, sequence_grouping_with_unmapped.txt
python ./createSequenceGroupTSV.py

# CheckContamination.sh can be launched together with ScatterBQSR.sh + ScatterApplyBQSR.sh
./CheckContamination.sh &

# BaseRecalibrator
# Scatter
./ScatterBQSR.sh

# GatherBqsrReports
./GatherBQSRReports.sh

#wait CheckContamination.sh and ScatterBQSR + GatherBQSRReports
wait

# ApplyBQSR
# Scatter
./ScatterApplyBQSR.sh

# GatherBamFiles
./GatherBamFiles.sh

# HTC

# ScatterIntervalList.sh only needs run 1 time
./ScatterIntervalList.sh $scatterCount
python ./ScatterIntervalListRename.py $scatterCount $outDir
./ScatterIntervalListGather.sh $scatterCount

# Scatter on HTC
./ScatterHTC_smart.sh $scatterCount $htcParallelism

#Filter is turned off as requested by Di
#./ScatterFilter_smart.sh $scatterCount $htcParallelism

# MergeVCF, second argument is 0, indicating filterVCF is not called
./MergeVcf.sh $scatterCount 0
