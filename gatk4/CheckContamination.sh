source ./global.sh
outDirFC="/genome/ssd2/peipei/output/copyFromFireCloud"
outDir="/genome/ssd2/peipei/output"
refDir="/genome/disk2/peipei/1reference"

$VerifyBamID \
--Verbose \
--NumPC 4 \
--Output ${outDir}/NA12878_falcon.preBqsr \
--BamFile ${outDirFC}/NA12878_falcon.aligned.duplicate_marked.sorted.bam \
--Reference ${refDir}/Homo_sapiens_assembly38.fasta \
--UDPath ${refDir}/Homo_sapiens_assembly38.contam.UD \
--MeanPath ${refDir}/Homo_sapiens_assembly38.contam.mu \
--BedPath ${refDir}/Homo_sapiens_assembly38.contam.bed \
1>/dev/null
