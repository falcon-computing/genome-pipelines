sample_id=$1
timeTag=`date +%s`
WORK_DIR="/local/falcon"
ec2Type=`cat ${WORK_DIR}/log_0_instanceType`

#download reference
${WORK_DIR}/00Data.sh > ${WORK_DIR}/log_ref_${timeTag} 2>&1
dlRefTime=`cat ${WORK_DIR}/log_ref_${timeTag} | grep "download reference" | tr -dc '0-9'`
dlSnpTime=`cat ${WORK_DIR}/log_ref_${timeTag} | grep "download dbsnp" | tr -dc '0-9'`
echo "download reference, $dlRefTime" >> ${WORK_DIR}/log_report_${ec2Type}
echo "download dbsnp, $dlSnpTime" >> ${WORK_DIR}/log_report_${ec2Type}
##download fastq
#${WORK_DIR}/01fastq.sh $sample_id > ${WORK_DIR}/log_${sample_id}_fastq_${timeTag} 2>&1
#
##call 0bwa.sh
#${WORK_DIR}/sudofalcon.sh ${WORK_DIR}/0bwa.sh $sample_id > ${WORK_DIR}/log_${sample_id}_0bwa_${timeTag} 2>&1
#
##call 1bqsr.sh
#${WORK_DIR}/sudofalcon.sh ${WORK_DIR}/1bqsr.sh $sample_id > ${WORK_DIR}/log_${sample_id}_1bqsr_${timeTag} 2>&1
#
##call 2htc.sh
#${WORK_DIR}/sudofalcon.sh ${WORK_DIR}/2htc.sh $sample_id > ${WORK_DIR}/log_${sample_id}_2htc_${timeTag} 2>&1
#
##call 3mutect2.sh
#${WORK_DIR}/sudofalcon.sh ${WORK_DIR}/3mutect2.sh $sample_id > ${WORK_DIR}/log_${sample_id}_3mutect2_${timeTag} 2>&1
#
##tar log files
#tar zcvf ${WORK_DIR}/tarlog_${timeTag} ${WORK_DIR}/log `ls ${WORK_DIR}/log_*`
#aws s3 cp ${WORK_DIR}/tarlog_${timeTag} s3://fcs-genome-data/profileCloud/ 
