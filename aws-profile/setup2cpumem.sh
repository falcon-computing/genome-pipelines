WORK_DIR="/local/falcon"

cpuInfo=`cat /proc/cpuinfo | head -20 | grep "model name" | cut -d':' -f2`
cpuCore=`cat /proc/cpuinfo | tail -20 | grep siblings | cut -d':' -f2`
memSize=`cat /proc/meminfo | grep "MemTotal:" | cut -d':' -f2 | tr -dc '0-9'`
memSizeGB=$((memSize/1024/1024))
ec2Type=`cat ${WORK_DIR}/log_0_instanceType`
#nvm or disk
devName=`lsblk | grep 00G | cut -d' ' -f1`

echo -n "" > ${WORK_DIR}/log_report_${ec2Type}

echo "instance, $ec2Type" >> ${WORK_DIR}/log_report_${ec2Type}
echo "cpu, $cpuInfo" >> ${WORK_DIR}/log_report_${ec2Type}
echo "cores, $cpuCore" >> ${WORK_DIR}/log_report_${ec2Type}
echo "mem, $memSizeGB" >> ${WORK_DIR}/log_report_${ec2Type}

cat /proc/cpuinfo > ${WORK_DIR}/log_cpuinfo
cat /proc/meminfo > ${WORK_DIR}/log_meminfo
echo "$devName" > ${WORK_DIR}/log_storage
