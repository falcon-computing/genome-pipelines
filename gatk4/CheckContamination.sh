source ./global.sh

$VerifyBamID \
--Verbose \
--NumPC 4 \
--Output ${outDir}/${base_file_name}.preBqsr \
--BamFile ${outDir}/${base_file_name}.aligned.duplicate_marked.sorted.bam \
--Reference ${refDir}/Homo_sapiens_assembly38.fasta \
--UDPath ${refDir}/Homo_sapiens_assembly38.contam.UD \
--MeanPath ${refDir}/Homo_sapiens_assembly38.contam.mu \
--BedPath ${refDir}/Homo_sapiens_assembly38.contam.bed \
1>/dev/null
