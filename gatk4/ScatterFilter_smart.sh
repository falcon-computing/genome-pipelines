if [ "$#" -ne 2 ]; then
    echo "./ScatterFilter_smart.sh #totalScatterCount #parallelCount"
    exit
fi
#
scatterCount=$1
parallelCount=$2
start=1
end=$((start+parallelCount-1))
while [ $start -lt $scatterCount ]
do

echo $start $end
for i in `seq $start $end`; do
    ./FilterVcf.sh $scatterCount $i > debug/debug_filtervcf_smart_line${i}.stdout.log 2> debug/debug_filtervcf_smart_line${i}.stderr.log &
    pids[${i}]=$!
done

# wait for all pids
#for pid in ${pids[*]}; do
for i in `seq $start $end`;do
  pid=${pids[$i]}
  wait $pid
  if [ "$?" -gt 0 ]; then
   #is_error=1
    echo "Failed on shard $i"
  fi
done

start=$((start+parallelCount))
end=$((start+parallelCount-1))

if [ $end -gt $scatterCount  ]
then
end=$scatterCount
fi
done

