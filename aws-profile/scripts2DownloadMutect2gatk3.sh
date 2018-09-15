#sample_id=$1
timeTag=`date +%s`
WORK_DIR="/local/falcon"
ec2Type=`cat ${WORK_DIR}/log_0_instanceType`

#remove files
if [ -d /local/TCRBOA1-N.recal.bam ];then
rm -rf /local/TCRBOA1-N.recal.bam
fi
if [ -d /local/TCRBOA1-T.recal.bam ];then
rm -rf /local/TCRBOA1-T.recal.bam
fi
#Download
start_ts=$(date +%s)
aws s3 cp --recursive s3://fcs-genome-data/profileCloud/input/TCRBOA1-N/TCRBOA1-N.recal.bam/ /local/TCRBOA1-N.recal.bam/
aws s3 cp --recursive s3://fcs-genome-data/profileCloud/input/TCRBOA1-T/TCRBOA1-T.recal.bam/ /local/TCRBOA1-T.recal.bam/
end_ts=$(date +%s)
mutectDownTime=$((end_ts-start_ts))
echo "mutect2gatk3 download bam, $mutectDownTime" >> ${WORK_DIR}/log_report_${ec2Type}

start_ts=$end_ts
aws s3 cp s3://fcs-genome-pub/ref/b37_cosmic_v54_120711.vcf /local/ref/
aws s3 cp s3://fcs-genome-pub/ref/b37_cosmic_v54_120711.vcf.idx /local/ref/
end_ts=$(date +%s)
mutectDownTime=$((end_ts-start_ts))
echo "mutect2gatk3 download vcf, $mutectDownTime" >> ${WORK_DIR}/log_report_${ec2Type}


echo "=============== Processing, mutect2" >> ${WORK_DIR}/log_report_${ec2Type}
#call 3mutect2.sh
echo "@@ sudofalcon.sh 3mutect2gatk3.sh"
${WORK_DIR}/sudofalcon.sh ${WORK_DIR}/3mutect2gatk3.sh > ${WORK_DIR}/log_3mutect2_${timeTag} 2>&1
#mutect2dataTime=`cat ${WORK_DIR}/log_3mutect2_${timeTag} | grep "mutect2 download vcf " | grep -v "echo" | grep -o -P '(?<=Files ).*(?=seconds)'`
mutect2runTime=`cat ${WORK_DIR}/log_3mutect2_${timeTag} | grep "mutect2 run " | grep -v "echo" | grep -o -P '(?<=run ).*(?=seconds)'`
mutect2UpTime=`cat ${WORK_DIR}/log_3mutect2_${timeTag} | grep "mutect2 upload result finishes" | grep -v "echo" | grep -o -P '(?<=in ).*(?=seconds)'`
#echo "mutect2gatk3 download vcf, $mutect2dataTime" >> ${WORK_DIR}/log_report_${ec2Type}
echo "mutect2gatk3 run, $mutect2runTime" >> ${WORK_DIR}/log_report_${ec2Type}
echo "mutect2gatk3 upload res, $mutect2UpTime" >> ${WORK_DIR}/log_report_${ec2Type}

