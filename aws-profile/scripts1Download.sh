sample_id=$1
timeTag=`date +%s`
WORK_DIR="/local/falcon"
ec2Type=`cat ${WORK_DIR}/log_0_instanceType`

if [[ "${sample_id}" == "TCRBOA1-N"  ]] || [[ "${sample_id}" == "TCRBOA1-T" ]];then
htcSkip="True"
echo "running mutect2 ${sample_id} pipeline, htcSkip flag is ${htcSkip}!"
fi

echo "=== Processing, ${sample_id}" >> ${WORK_DIR}/log_report_${ec2Type}

#download fastq
echo "@@ 01fastq.sh"
${WORK_DIR}/01fastq.sh $sample_id > ${WORK_DIR}/log_${sample_id}_fastq_${timeTag} 2>&1
dlFastqTime=`cat ${WORK_DIR}/log_${sample_id}_fastq_${timeTag} | grep "download fastq" | tr -dc '0-9'`
echo "download fastq, $dlFastqTime" >> ${WORK_DIR}/log_report_${ec2Type}

#first remove if any files
#Download
start_ts=$(date +%s)
aws s3 cp s3://fcs-genome-data/profileCloud/input/${sample_id}/${sample_id}.bam /local/
aws s3 cp s3://fcs-genome-data/profileCloud/input/${sample_id}/${sample_id}.bam.bai /local/
end_ts=$(date +%s)
bqsrDownTime=$((end_ts-start_ts))
echo "bqsr download, $bqsrDownTime" >> ${WORK_DIR}/log_report_${ec2Type}

#call 1bqsr.sh
echo "@@ sudofalcon.sh 1bqsr.sh"
${WORK_DIR}/sudofalcon.sh ${WORK_DIR}/1bqsr.sh $sample_id > ${WORK_DIR}/log_${sample_id}_1bqsr_${timeTag} 2>&1
bqsrTime=`cat ${WORK_DIR}/log_${sample_id}_1bqsr_${timeTag} | grep "INFO: Base Recalibration finishes in" | grep -o -P '(?<=in ).*(?=seconds)'`
bqsrUpTime=`cat ${WORK_DIR}/log_${sample_id}_1bqsr_${timeTag} | grep "bqsr upload result finishes" | grep -v "echo" | tr -dc '0-9'`
echo "bqsr, $bqsrTime" >> ${WORK_DIR}/log_report_${ec2Type}
echo "bqsr upload res, $bqsrUpTime" >> ${WORK_DIR}/log_report_${ec2Type}

#remove files
rm -rf /local/${sample_id}.recal.bam
#Download
start_ts=$(date +%s)
aws s3 cp --recursive s3://fcs-genome-data/profileCloud/input/${sample_id}/${sample_id}.recal.bam /local/${sample_id}.recal.bam
end_ts=$(date +%s)
htcDownTime=$((end_ts-start_ts))
echo "htc download, $htcDownTime" >> ${WORK_DIR}/log_report_${ec2Type}

#call 2htc.sh
echo "@@ sudofalcon.sh 2htc.sh"
if [[ ! "$htcSkip" == "True" ]];then
${WORK_DIR}/sudofalcon.sh ${WORK_DIR}/2htc.sh $sample_id > ${WORK_DIR}/log_${sample_id}_2htc_${timeTag} 2>&1
htcTime=`cat ${WORK_DIR}/log_${sample_id}_2htc_${timeTag} | grep "INFO: Haplotype Caller finishes in" | grep -o -P '(?<=in ).*(?=seconds)'`
htcUpTime=`cat ${WORK_DIR}/log_${sample_id}_2htc_${timeTag} | grep "htc upload result finishes" | grep -v "echo" | tr -dc '0-9'`
echo "htc, $htcTime" >> ${WORK_DIR}/log_report_${ec2Type}
echo "htc upload res, $htcUpTime" >> ${WORK_DIR}/log_report_${ec2Type}
else
echo "running mutect2 ${sample_id} pipeline, skip htc!"
fi
