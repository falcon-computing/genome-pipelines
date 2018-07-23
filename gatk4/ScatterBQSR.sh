source ./global.sh

for i in `seq 1 18`; do
    ./BaseRecalibrator.sh $i > debug/debug_bqsr_${base_file_name}_line${i}.stdout.log 2> debug/debug_bqsr_${base_file_name}_line${i}.stderr.log &
    pids[${i}]=$!
done

# wait for all pids
#for pid in ${pids[*]}; do
for i in `seq 1 18`;do
  pid=${pids[$i]}
  wait $pid
  if [ "$?" -gt 0 ]; then
    #is_error=1
    echo "Failed on line $i"
  fi
done

