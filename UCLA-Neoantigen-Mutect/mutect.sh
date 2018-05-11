#!/bin/bash

CURR_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source $CURR_DIR/globals.sh
source $FALCON_DIR/setup.sh

if [ $# -ne 3 ]; then
  echo "USAGE: $0 normal.bam tumor.bam output_dir"
  exit 1
fi

normal_input=$1
tumor_input=$2
output_dir=$3
output=$output_dir/mutect-parts
mkdir -p $output
             
start_ts=$(date +%s)
    
#Mutect
echo "Final STEP: Mutect2 Variant Calling"
num_cpu=$(grep -c ^processor /proc/cpuinfo)
num_cpu=$(($num_cpu / 2))
pid_table=()
failed=0
for i in $(seq 0 31); do 
  part=$(printf part-%02d $i)
  java -d64 -Xmx16g \
      -jar $FALCON_DIR/tools/package/GenomeAnalysisTK.jar \
      -T MuTect2 \
      -R $ref_genome \
      -I:tumor ${tumor_input}/${part}.bam \
      -I:normal ${normal_input}/${part}.bam \
      --dbsnp $dbsnp \
      --cosmic $cosmic \
      -minPruning 4 \
      -o $output/${part}.vcf &> $output/${part}.log &

  pid_table[$i]=$!
  if [ $(( ($i + 1) % $num_cpu )) -eq 0 ]; then
     for idx in "${!pid_table[@]}"; do
	pid=${pid_table[$idx]}
	wait $pid
	if [ $? -ne 0 ]; then
	  echo "sub-process failed"
          failed=1 
	fi
     done
     unset pid_table
  fi
done

if [ $failed -ne 0 ]; then
  echo "Failed mutect"
  exit -1
fi

bcftools concat -o $output_dir/mutect.vcf $(ls $output/*.vcf)
if [ $? -ne 0 ]; then
  echo "failed to concat mutect vcf parts"
  exit 1
fi

rm -rf $output

end_ts=$(date +%s)
echo "Mutect2 finishes in $((end_ts - start_ts)) s"

