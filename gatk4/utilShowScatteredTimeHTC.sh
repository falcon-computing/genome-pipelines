for i in `seq  1 50`;do cat ./debug/debug_htc_smart_line${i}.stderr.log | grep minutes | grep done;done

