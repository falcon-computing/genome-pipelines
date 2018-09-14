sleep 2
START_SECONDS=0
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "download fastq $duration seconds elapsed."
echo $SECONDS
