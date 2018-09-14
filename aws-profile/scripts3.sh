#sample_id=$1
timeTag=`date +%s`
WORK_DIR="/local/falcon"
ec2Type=`cat ${WORK_DIR}/log_0_instanceType`

#log out usage of storage
#storagePercent=`df -h | grep local | grep -o '[^ ]*%' | tr -dc '0-9'`
totalStorage=`lsblk | grep local | grep -o '[^ ]*G'| tr -dc '0-9'`
totalAvailableStorage=`df -h | grep local | grep -o '[^ ]*G' | tail -3 | head -1 | tr -dc '0-9'`
usedAvailableStorage=`df -h | grep local | grep -o '[^ ]*G' | tail -2 | head -1| tr -dc '0-9'`
stillAvailableStorage=`df -h | grep local | grep -o '[^ ]*G' | tail -1 | head -1| tr -dc '0-9'`
echo "total Storage: $totalStorage GB" >> ${WORK_DIR}/log_storage
echo "total avaiable Storage: $totalAvailableStorage GB" >> ${WORK_DIR}/log_storage
echo "used  avaiable Storage: $usedAvailableStorage GB" >> ${WORK_DIR}/log_storage
echo "still avaiable Storage: $stillAvailableStorage GB" >> ${WORK_DIR}/log_storage


#tar log files
echo "@@ tar log files and upload"
#tar zcvf ${WORK_DIR}/tarlog_${ec2Type}_${timeTag} ${WORK_DIR}/log `ls ${WORK_DIR}/log_*`
tar zcvf ${WORK_DIR}/tarlog_${ec2Type}_${timeTag} /home/centos/log `ls ${WORK_DIR}/log_*`
aws s3 cp ${WORK_DIR}/tarlog_${ec2Type}_${timeTag} s3://fcs-genome-data/profileCloud/ 
