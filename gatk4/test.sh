bamDir="/genome/ssd2/peipei/0inputUnmappedBAM"
refDir="/genome/ssd2/peipei/1reference"
input_bam="${bamDir}/NA12878_falcon.query.sorted.unmapped.bam"
unmapped_bam_base=`basename $input_bam .unmapped.bam` 
echo $unmapped_bam_base

