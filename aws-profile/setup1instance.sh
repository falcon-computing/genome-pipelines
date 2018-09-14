WORK_DIR="/local/falcon"

#get the instance information
wget -q - "http://169.254.169.254/latest/dynamic/instance-identity/document" -O ${WORK_DIR}/log_0_instance_document
#grep instanceType, remove "" in the string
cat ${WORK_DIR}/log_0_instance_document | grep instanceType | cut -d':' -f2 | grep -o -P '(?<=").*(?=")' > ${WORK_DIR}/log_0_instanceType
