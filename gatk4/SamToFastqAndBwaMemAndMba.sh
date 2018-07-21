source ./global.sh
set -o pipefail
set -e




outDir="/genome/ssd2/peipei/output"
#input_bam="${bamDir}/NA12878_falcon.query.sorted.unmapped.bam"
input_bam="${bamDir}/${base_file_name}.query.sorted.unmapped.bam"
unmapped_bam_basename=`basename $input_bam .unmapped.bam` 
#or unmapped_bam_basename="${base_file_name}.query.sorted"
output_bam_basename="${unmapped_bam_basename}.aligned.unsorted"
#or output_bam_basename="${base_file_name}.query.sorted.aligned.unsorted"

# set the bash variable needed for the command-line
ref_fasta="${refDir}/Homo_sapiens_assembly38.fasta"
bash_ref_fasta=${ref_fasta}
ref_alt="${refDir}/Homo_sapiens_assembly38.fasta.64.alt"
# if ref_alt has data in it,
if [ -s $ref_alt ]; then
  java -Xms5000m -jar $picardJar \
    SamToFastq \
    INPUT=${input_bam} \
    FASTQ=/dev/stdout \
    INTERLEAVE=true \
    NON_PF=true | \
  $bwa mem -K 100000000 -p -v 3 -t 16 -Y $bash_ref_fasta /dev/stdin - 2> >(tee ${output_bam_basename}.bwa.stderr.log >&2) | \
  java -Dsamjdk.compression_level=2 -Xms3000m -jar $picardJar \
    MergeBamAlignment \
    VALIDATION_STRINGENCY=SILENT \
    EXPECTED_ORIENTATIONS=FR \
    ATTRIBUTES_TO_RETAIN=X0 \
    ATTRIBUTES_TO_REMOVE=NM \
    ATTRIBUTES_TO_REMOVE=MD \
    ALIGNED_BAM=/dev/stdin \
    UNMAPPED_BAM=${input_bam} \
    OUTPUT=${outDir}/${output_bam_basename}.bam \
    REFERENCE_SEQUENCE=${ref_fasta} \
    PAIRED_RUN=true \
    SORT_ORDER="unsorted" \
    IS_BISULFITE_SEQUENCE=false \
    ALIGNED_READS_ONLY=false \
    CLIP_ADAPTERS=false \
    MAX_RECORDS_IN_RAM=2000000 \
    ADD_MATE_CIGAR=true \
    MAX_INSERTIONS_OR_DELETIONS=-1 \
    PRIMARY_ALIGNMENT_STRATEGY=MostDistant \
    PROGRAM_RECORD_ID="bwamem" \
    PROGRAM_GROUP_VERSION="0.7.15-r1140" \
    PROGRAM_GROUP_COMMAND_LINE="bwa mem -K 100000000 -p -v 3 -t 16 -Y $bash_ref_fasta" \
    PROGRAM_GROUP_NAME="bwamem" \
    UNMAPPED_READ_STRATEGY=COPY_TO_TAG \
    ALIGNER_PROPER_PAIR_FLAGS=true \
    UNMAP_CONTAMINANT_READS=true \
    ADD_PG_TAG_TO_READS=false

  #grep -m1 "read .* ALT contigs" ${output_bam_basename}.bwa.stderr.log | \
  #grep -v "read 0 ALT contigs"

# else ref_alt is empty or could not be found
else
  exit 1;
fi
