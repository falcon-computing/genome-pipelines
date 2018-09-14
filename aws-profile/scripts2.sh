#sample_id=$1
timeTag=`date +%s`
WORK_DIR="/local/falcon"
ec2Type=`cat ${WORK_DIR}/log_0_instanceType`

echo "=============== Processing, mutect2" >> ${WORK_DIR}/log_report_${ec2Type}
#call 3mutect2.sh
echo "@@ sudofalcon.sh 3mutect2.sh"
${WORK_DIR}/sudofalcon.sh ${WORK_DIR}/3mutect2.sh > ${WORK_DIR}/log_3mutect2_${timeTag} 2>&1
mutect2dataTime=`cat ${WORK_DIR}/log_3mutect2_${timeTag} | grep "mutect2 download vcf " | grep -v "echo" | grep -o -P '(?<=Files ).*(?=seconds)'`
mutect2runTime=`cat ${WORK_DIR}/log_3mutect2_${timeTag} | grep "mutect2 run " | grep -v "echo" | grep -o -P '(?<=run ).*(?=seconds)'`
mutect2UpTime=`cat ${WORK_DIR}/log_3mutect2_${timeTag} | grep "mutect2 upload result finishes" | grep -v "echo" | grep -o -P '(?<=in ).*(?=seconds)'`
echo "mutect2 download vcf, $mutect2dataTime" >> ${WORK_DIR}/log_report_${ec2Type}
echo "mutect2 run, $mutect2runTime" >> ${WORK_DIR}/log_report_${ec2Type}
echo "mutect2 upload res, $mutect2UpTime" >> ${WORK_DIR}/log_report_${ec2Type}

##tar log files
#tar zcvf ${WORK_DIR}/tarlog_${timeTag} ${WORK_DIR}/log `ls ${WORK_DIR}/log_*`
#aws s3 cp ${WORK_DIR}/tarlog_${timeTag} s3://fcs-genome-data/profileCloud/ 
