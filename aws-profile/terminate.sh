instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id/)
/usr/bin/aws ec2 terminate-instances --instance-ids $instanceId --region us-east-1


