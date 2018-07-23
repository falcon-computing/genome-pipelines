for i in `seq  1 18`;do cat ./debug/debug_bqsr_line${i}.stderr.log | grep minutes | grep done;done
for i in `seq  1 18`;do cat ./debug/debug_applybqsr_line${i}.stderr.log | grep minutes | grep done;done

