#first download data
START_SECONDS=0
mutect2gatk3Dir="/local/mutect2gatk3/"
local_dir="/local"
WORK_DIR="/local/falcon"
ec2Type=`cat ${WORK_DIR}/log_0_instanceType`

set -x

END_SECONDS=$SECONDS
START_SECONDS=$END_SECONDS

#check bam files

if [[ -s "${local_dir}/TCRBOA1-N.recal.bam"  ]] && [[ -s "${local_dir}/TCRBOA1-T.recal.bam"  ]];then
echo "${local_dir}/TCRBOA1-N.recal.bam OK"
echo "${local_dir}/TCRBOA1-T.recal.bam OK"
else
echo "TCRBOA2 Files failed to be downloaded"
exit 1
fi 



#execute mutect2
fcs-genome mutect2 \
 -r /local/ref/human_g1k_v37.fasta \
 -n /local/TCRBOA1-N.recal.bam \
 -t /local/TCRBOA1-T.recal.bam \
 --dbsnp /local/ref/dbsnp_138.b37.vcf \
 --cosmic /local/ref/b37_cosmic_v54_120711.vcf \
 -o ${mutect2gatk3Dir}/TCRBOA1.vcf 

END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS)) 
echo "mutect2 run $duration seconds elapsed." 
START_SECONDS=$END_SECONDS

#upload results
aws s3 cp --recursive ${mutect2gatk3Dir}/TCRBOA1.vcf s3://fcs-genome-data/profileCloud/${ec2Type}/TCRBOA1_gatk3/TCRBOA1.vcf/
aws s3 cp ${mutect2gatk3Dir}/TCRBOA1.vcf.gz s3://fcs-genome-data/profileCloud/${ec2Type}/TCRBOA1_gatk3/
aws s3 cp ${mutect2gatk3Dir}/TCRBOA1.vcf.gz.tbi s3://fcs-genome-data/profileCloud/${ec2Type}/TCRBOA1_gatk3/
END_SECONDS=$SECONDS 
duration=$((END_SECONDS-START_SECONDS)) 
echo "mutect2 upload result finishes in $duration seconds"
