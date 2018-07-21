source ./global.sh
#ApplyBQSR has one more line as unmapped
totalLineNum=19
for i in `seq 1 $totalLineNum`; do
    ./ApplyBQSR.sh $i > debug/debug_applybqsr_${base_file_name}_line${i}.stdout.log 2> debug/debug_applybqsr_${base_file_name}_line${i}.stderr.log &
    pids[${i}]=$!
done

# wait for all pids
#for pid in ${pids[*]}; do
for i in `seq 1 $totalLineNum`;do
  pid=${pids[$i]}
  wait $pid
  if [ "$?" -gt 0 ]; then
    #is_error=1
    echo "Failed on line $i"
  fi
done

