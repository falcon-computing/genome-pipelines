#!/bin/bash
CURR_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source $CURR_DIR/globals.sh
source $FALCON_DIR/setup.sh

if [ $# -ne 2 ]; then
    echo "USAGE: $0 input.bam output_dir"
    exit 1
fi

input=$1
output_dir=$2

if [ ! -d $input ]; then
    echo "cannot find $input"
    exit 1
fi

echo "Start DiagnoseTargets for $input"

set -x 
java -d64 -Xmx16g \
    -jar $FALCON_DIR/tools/package/GenomeAnalysisTK.jar \
    -T DepthOfCoverage \
    -R $ref_genome \
    `for i in $(seq 0 31); do printf -- "-I $input/part-%0.2d.bam " $i; done` \
    -L $intv \
    -o $output_dir/$(basename $input)-depth.vcf &> $output_dir/depth-of-coverage.log
set +x

