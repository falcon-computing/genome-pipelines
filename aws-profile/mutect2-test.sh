fcs-genome mutect2 \
 --gatk4 \
 -r /local/ref/human_g1k_v37.fasta \
 -n /local/mutect2/TCRBOA1-Normal_final_BAM.bam \
 -t /local/mutect2/TCRBOA1-Tumor_final_BAM.bam \
 --normal_name TCRBOA1-Normal \
 --tumor_name TCRBOA1-Tumor \
 --germline /local/mutect2/af-only-gnomad.raw.sites.b37.vcf.gz \
 --panels_of_normals /local/mutect2/mutect_gatk4_pon.vcf \
 -o test.vcf
