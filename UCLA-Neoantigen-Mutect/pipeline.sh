#!/bin/bash
CURR_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source $CURR_DIR/globals.sh
source $FALCON_DIR/setup.sh

if [ $# -ne 1 ]; then
  echo "USAGE: $0 sample_id"
  exit 1
fi

work_dir=$(pwd)
input_dir=$work_dir/input
output_dir=$work_dir/output

sample_id=$1

failed=0

# download data from s3
aws s3 sync --exclude "*" --include "${sample_id}-baseline*.fastq.gz" s3://$input_s3_bucket/ $input_dir/ 1> /dev/null
if [ $? -ne 0 ]; then
    echo "failed to download tumor sample from s3"
    exit
fi

aws s3 sync --exclude "*" --include "${sample_id}-normal*.fastq.gz" s3://$input_s3_bucket/ $input_dir/ 1> /dev/null &
pid=$!

# run tumor sample
$CURR_DIR/tumor.sh $sample_id-baseline $input_dir $output_dir/tumor
ret=$?

wait $pid
if [ $? -ne 0 ]; then
    echo "Failed to download normal sample from s3"
    exit
fi

# if tumor sample fails, still proceed to normal sample, but 
# do not proceed to mutect
if [ $ret -ne 0 ]; then
    echo "Tumor sample run failed"
    failed=1
fi

# run normal sample
$CURR_DIR/normal.sh $sample_id-normal $input_dir $output_dir/normal

if [ $? -ne 0 ]; then
    echo "Normal sample run failed"
    failed=1
fi

if [ $failed -ne 0 ]; then
    echo "Per-sample analysis failed"
    echo "Please fix the problem and then run:"
    echo "$CURR_DIR/mutect.sh $output_dir/normal/recal.bam $output_dir/tumor/realn.bam $output_dir"
    exit 1
fi

# delete input files
echo "Removing input dir: $input_dir"
rm -rf $input_dir

function wait_check {
  local pid=$1;
  local msg=$2;
  wait $pid;
  if [ $? -eq 0 ]; then
    echo "$msg succeeded"
  else
    echo "$msg failed" 
  fi;
}

# run depth of coverage
$CURR_DIR/dc.sh $output_dir/tumor/$sample_id-baseline_realn.bam $output_dir/tumor &
dc_tumor_pid=$!
$CURR_DIR/dt.sh $output_dir/tumor/$sample_id-baseline_realn.bam $output_dir/tumor &
dt_tumor_pid=$!
$CURR_DIR/dc.sh $output_dir/normal/$sample_id-normal_recal.bam $output_dir/normal &
dc_normal_pid=$!
$CURR_DIR/dt.sh $output_dir/normal/$sample_id-normal_recal.bam $output_dir/normal &
dt_normal_pid=$!

wait_check $dc_tumor_pid "DepthOfCoverage for Tumor sample"
wait_check $dt_tumor_pid "DiagnoseTargets for Tumor sample"
wait_check $dc_tumor_pid "DepthOfCoverage for Normal sample"
wait_check $dt_normal_pid "DiagnoseTargets for Normal sample"

# run mutect
$CURR_DIR/mutect.sh \
    $output_dir/normal/$sample_id-normal_recal.bam \
    $output_dir/tumor/$sample_id-baseline_realn.bam \
    $output_dir

if [ $? -ne 0 ]; then
    echo "Mutect2 run failed"
    exit 1
fi

# upload data to s3
aws s3 sync $output_dir s3://$output_s3_bucket/$sample_id 1> /dev/nulll
aws s3 cp --recursive $work_dir/log s3://$output_s3_bucket/$sample_id/log/ 1> /dev/null

if [ $? -ne 0 ]; then
  echo "failed to upload $output_dir to s3"
  exit 1
fi

rm -rf $output_dir
rm -rf $work_dir/log
