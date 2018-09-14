WORK_DIR="/local/falcon"
ec2Type=`cat ${WORK_DIR}/log_0_instanceType`

aws configure set aws_access_key_id AKIAJYGOCWIPVH72QQAQ
aws configure set aws_secret_access_key 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
aws configure set default.region us-east-1
sudo aws configure set aws_access_key_id AKIAJYGOCWIPVH72QQAQ
sudo aws configure set aws_secret_access_key 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
sudo aws configure set default.region us-east-1

#download latest version  path in s3
aws s3 cp s3://fcs-genome-build/release/aws/latest ${WORK_DIR}
latestS3=`cat ${WORK_DIR}/latest`

#get the file name from s3 path
latestFileName=$(basename "$latestS3")

#if downloaded, skip; if not, download and then untar, write to /usr/local to update fcs-genome
if [[ -s ${WORK_DIR}/${latestFileName} ]];then
echo "${WORK_DIR}/${latestFileName} exists, skip downloading"
else
echo "${WORK_DIR}/${latestFileName} doesnot exist, downloading and write to /usr/local"
aws s3 cp $latestS3 ${WORK_DIR} 
sudo tar zxf ${WORK_DIR}/${latestFileName} -C /usr/local/
fi

#update blaze conf, with the verbose one
sudo sed -i -e 's/verbose : 0/verbose : 2/g' /usr/local/falcon/blaze/conf

#log file name
echo "fcs-genome, ${latestFileName}" >> ${WORK_DIR}/log_report_${ec2Type}

