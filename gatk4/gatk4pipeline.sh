source ./global.sh

#set -e
# bwa thread
bwaThread=32

# this number is provided in five-dollar-genome-analysis-pipeline reference flow on FireCloud
scatterCount=50


# htcParallelism is the htc caller parallelism, 10 works, 50 does not work, optimal needs to be explored
htcParallelism=10

#
START_SECONDS=0
./SamToFastqAndBwaMemAndMba.sh $bwaThread
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "SamToFastqAndBwaMemAndMba.sh $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
START_SECONDS=$END_SECONDS

#
./MarkDuplicates.sh
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "MarkDuplicates.sh $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
START_SECONDS=$END_SECONDS

./SortSampleBam.sh
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "SortSampleBam.sh $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
START_SECONDS=$END_SECONDS

#createSequenceGroupTSV only needs 1 time, and it is the same for different inputs
#it creates two files: sequence_grouping.txt, sequence_grouping_with_unmapped.txt
python ./CreateSequenceGroupingTSV.py

# CheckContamination.sh can be launched together with ScatterBQSR.sh + ScatterApplyBQSR.sh
##./CheckContamination.sh &

# BaseRecalibrator
# Scatter
./ScatterBQSR.sh

# GatherBqsrReports
./GatherBQSRReports.sh

#wait CheckContamination.sh and ScatterBQSR + GatherBQSRReports
#wait
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "BQSR $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
START_SECONDS=$END_SECONDS

# ApplyBQSR
# Scatter
./ScatterApplyBQSR.sh

# GatherBamFiles
./GatherBamFiles.sh
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "ApplyBQSR $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
START_SECONDS=$END_SECONDS

# HTC

# ScatterIntervalList.sh only needs run 1 time
./ScatterIntervalList.sh $scatterCount
python ./ScatterIntervalListRename.py $scatterCount $outDir
./ScatterIntervalListGather.sh $scatterCount

# Scatter on HTC
./ScatterHTC_smart.sh $scatterCount $htcParallelism
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "HTC $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
START_SECONDS=$END_SECONDS

#Filter is turned off as requested by Di
#./ScatterFilter_smart.sh $scatterCount $htcParallelism

# MergeVCF, second argument is 0, indicating filterVCF is not called
./MergeVcf.sh $scatterCount 0
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "MergeVcf $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
START_SECONDS=$END_SECONDS
