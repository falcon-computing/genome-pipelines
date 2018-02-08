#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

SAMTOOLS=samtools
BEDTOOLS=/curr/niveda/tools/bedtools2/bin/bedtools

if [[ $# -ne 2 ]];then
  echo "USAGE: $0 [Path_to_bam] [out_path]"
  exit 1
fi

path_to_bam=$1
out_path=$2

#Check if the PATH_TO_BAM is a directory containing multiple recalibrated BAM files or a single recalibrated BAM file

#If directory, then do coverage calculation for each file
if [ -d "$path_to_bam" ];then
  num_proc=16
  proc_id=0
  for file in $(ls "$path_to_bam")
  do
    if [[ $file =~ bam$ ]];then
      sample=`echo $file | sed 's/\.bam//'`
      #Ignore duplicates in BAM file | Calculate coverage values 
      $SAMTOOLS view -b -F 0x400 "$path_to_bam"/"$file" | "$BEDTOOLS" genomecov -ibam stdin -bga >> $out_path/coverage.bed &

      pid_table["$proc_id"]=$!
      proc_id=$(($proc_id + 1))
      if [ $proc_id -eq $num_proc ];then
        #Wait for current tasks
        for i in $(seq 0 $(($proc_id - 1)));do
          wait "${pid_table["$i"]}"
        done
        proc_id=0
      fi
    fi
  done
  for i in $(seq 0 $(($proc_id - 1))); do
      wait "${pid_table["$i"]}"
  done

  if [[ $? -ne 0 ]]; then
    log_error "Failed to calculate genome coverage for $file"
    exit 1
  fi

#If single file, then do coverage calculation for only that file
elif [ -f "$path_to_bam" ];then
  $SAMTOOLS view -b -F 0x400 "$path_to_bam" | "$BEDTOOLS" genomecov -ibam stdin -bga >> $out_path/"${sample}_coverage.bed"
  if [[ $? -ne 0 ]]; then
    log_error "Failed to calculate genome coverage for $path_to_bam"
    exit 1
  fi
fi

$BEDTOOLS sort -i $out_path/coverage.bed > $out_path/sort_coverage.bed
