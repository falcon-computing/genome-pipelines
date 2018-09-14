sample_id=$1
timeTag=`date +%s`
WORK_DIR="/local/falcon"
ec2Type=`cat ${WORK_DIR}/log_0_instanceType`

if [[ "${sample_id}" == "TCRBOA1-N"  ]] || [[ "${sample_id}" == "TCRBOA1-T" ]];then
htcSkip="True"
echo "running mutect2 ${sample_id} pipeline, htcSkip flag is ${htcSkip}!"
fi

##download reference
#${WORK_DIR}/00Data.sh > ${WORK_DIR}/log_ref_${timeTag} 2>&1
#dlRefTime=`cat ${WORK_DIR}/log_ref_${timeTag} | grep "download reference" | tr -dc '0-9'`
#dlSnpTime=`cat ${WORK_DIR}/log_ref_${timeTag} | grep "download dbsnp" | tr -dc '0-9'`
#echo "download reference, $dlRefTime" >> ${WORK_DIR}/log_report_${ec2Type}
#echo "download dbsnp, $dlSnpTime" >> ${WORK_DIR}/log_report_${ec2Type}

echo "=== Processing, ${sample_id}" >> ${WORK_DIR}/log_report_${ec2Type}

#download fastq
echo "@@ 01fastq.sh"
${WORK_DIR}/01fastq.sh $sample_id > ${WORK_DIR}/log_${sample_id}_fastq_${timeTag} 2>&1
dlFastqTime=`cat ${WORK_DIR}/log_${sample_id}_fastq_${timeTag} | grep "download fastq" | tr -dc '0-9'`
echo "download fastq, $dlFastqTime" >> ${WORK_DIR}/log_report_${ec2Type}

#call 0bwa.sh
echo "@@ sudofalcon.sh 0bwa.sh"
${WORK_DIR}/sudofalcon.sh ${WORK_DIR}/0bwa.sh $sample_id > ${WORK_DIR}/log_${sample_id}_0bwa_${timeTag} 2>&1
bwaTime=`cat ${WORK_DIR}/log_${sample_id}_0bwa_${timeTag} | grep "INFO: bwa mem finishes in" | grep -o -P '(?<=in ).*(?=seconds)'`
mdTime=`cat ${WORK_DIR}/log_${sample_id}_0bwa_${timeTag} | grep "INFO: Mark Duplicates finishes in" | grep -o -P '(?<=in ).*(?=seconds)'`
bwaUpTime=`cat ${WORK_DIR}/log_${sample_id}_0bwa_${timeTag} | grep "bwa upload result finishes"| grep -v "echo" | tr -dc '0-9'`
echo "bwa, $bwaTime" >> ${WORK_DIR}/log_report_${ec2Type}
echo "markduplicate, $mdTime" >> ${WORK_DIR}/log_report_${ec2Type}
echo "bwa upload res, $bwaUpTime" >> ${WORK_DIR}/log_report_${ec2Type}


#call 1bqsr.sh
echo "@@ sudofalcon.sh 1bqsr.sh"
${WORK_DIR}/sudofalcon.sh ${WORK_DIR}/1bqsr.sh $sample_id > ${WORK_DIR}/log_${sample_id}_1bqsr_${timeTag} 2>&1
bqsrTime=`cat ${WORK_DIR}/log_${sample_id}_1bqsr_${timeTag} | grep "INFO: Base Recalibration finishes in" | grep -o -P '(?<=in ).*(?=seconds)'`
bqsrUpTime=`cat ${WORK_DIR}/log_${sample_id}_1bqsr_${timeTag} | grep "bqsr upload result finishes" | grep -v "echo" | tr -dc '0-9'`
echo "bqsr, $bqsrTime" >> ${WORK_DIR}/log_report_${ec2Type}
echo "bqsr upload res, $bqsrUpTime" >> ${WORK_DIR}/log_report_${ec2Type}

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
#
##call 3mutect2.sh
#${WORK_DIR}/sudofalcon.sh ${WORK_DIR}/3mutect2.sh $sample_id > ${WORK_DIR}/log_${sample_id}_3mutect2_${timeTag} 2>&1
#
##tar log files
#tar zcvf ${WORK_DIR}/tarlog_${timeTag} ${WORK_DIR}/log `ls ${WORK_DIR}/log_*`
#aws s3 cp ${WORK_DIR}/tarlog_${timeTag} s3://fcs-genome-data/profileCloud/ 
