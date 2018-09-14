#first download data
START_SECONDS=0
mutect2Dir="/local/mutect2/"
local_dir="/local"
WORK_DIR="/local/falcon"
ec2Type=`cat ${WORK_DIR}/log_0_instanceType`

set -x
#download mutect2 vcf files
if [[ ! -s "${mutect2Dir}/af-only-gnomad.raw.sites.b37.vcf.gz" ]];then
aws s3 sync s3://fcs-genome-data/gnomad/ ${mutect2Dir} --exclude "*" --include "af-only-gnomad.raw.sites.b37.vcf.gz*"
else
echo "${mutect2Dir}/af-only-gnomad.raw.sites.b37.vcf.gz exists, skip downloading"
fi

if [[ ! -s "${mutect2Dir}/mutect_gatk4_pon.vcf" ]];then
aws s3 sync s3://fcs-genome-data/panels_of_normals/ ${mutect2Dir} --exclude "*" --include "mutect_gatk4_pon*"
else
echo "${mutect2Dir}/mutect_gatk4_pon.vcf exists, skip downloading"
fi

if [[ -s "${mutect2Dir}/af-only-gnomad.raw.sites.b37.vcf.gz" ]]  && [[ -s "${mutect2Dir}/mutect_gatk4_pon.vcf" ]];then
echo "${mutect2Dir}/af-only-gnomad.raw.sites.b37.vcf.gz OK";
echo "${mutect2Dir}/mutect_gatk4_pon.vcf OK";
else
echo "mutect2 vcf Files failed to be downloaded"
exit 1
fi 

END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS)) 
echo "mutect2 download vcf Files $duration seconds elapsed." 
START_SECONDS=$END_SECONDS

#check bam files

if [[ -s "${local_dir}/TCRBOA1-N.recal.bam"  ]] && [[ -s "${local_dir}/TCRBOA1-T.recal.bam"  ]];then
echo "${local_dir}/TCRBOA1-N.recal.bam OK"
echo "${local_dir}/TCRBOA1-T.recal.bam OK"
else
echo "TCRBOA2 Files failed to be downloaded"
exit 1
fi 

#END_SECONDS=$SECONDS
#duration=$((END_SECONDS-START_SECONDS)) 
#echo "mutect2 download bam Files $duration seconds elapsed." 
#START_SECONDS=$END_SECONDS


#execute mutect2
fcs-genome mutect2 \
 --gatk4 \
 -r /local/ref/human_g1k_v37.fasta \
 -n /local/TCRBOA1-N.recal.bam \
 -t /local/TCRBOA1-T.recal.bam \
 --normal_name TCRBOA1-N \
 --tumor_name TCRBOA1-T \
 --germline /local/mutect2/af-only-gnomad.raw.sites.b37.vcf.gz \
 --panels_of_normals /local/mutect2/mutect_gatk4_pon.vcf \
 -o ${mutect2Dir}/TCRBOA1.vcf 

END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS)) 
echo "mutect2 run $duration seconds elapsed." 
START_SECONDS=$END_SECONDS

#upload results
aws s3 cp --recursive ${mutect2Dir}/TCRBOA1.vcf s3://fcs-genome-data/profileCloud/${ec2Type}/TCRBOA1/TCRBOA1.vcf/
aws s3 cp ${mutect2Dir}/TCRBOA1.vcf.gz s3://fcs-genome-data/profileCloud/${ec2Type}/TCRBOA1/
aws s3 cp ${mutect2Dir}/TCRBOA1.vcf.gz.tbi s3://fcs-genome-data/profileCloud/${ec2Type}/TCRBOA1/
END_SECONDS=$SECONDS 
duration=$((END_SECONDS-START_SECONDS)) 
echo "mutect2 upload result finishes in $duration seconds"
