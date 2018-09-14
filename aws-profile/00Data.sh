#!/bin/bash
echo "==========================================================="
START_SECONDS=0
if [ ! -s "/local/ref/human_g1k_v37.fasta.sa" ];then
echo "==========================================================="
echo "/local/ref/human_g1k_v37.fasta.sa doesnot exist, downloading!"
echo "Populating /local/ref/ folder:"
echo "==========================================================="
echo -e "aws s3 sync s3://fcs-genome-pub/ref/ /local/ref/ --exclude \"*\" --include \"human_g1k_v37.*\"  --no-sign-request \n"
         aws s3 sync s3://fcs-genome-pub/ref/ /local/ref/ --exclude  "*"  --include  "human_g1k_v37.*"   --no-sign-request

count_ref=`ls -1 /local/ref/human* | wc -l`
if [ "$count_ref" == "8" ];then
   echo -e "/local/ref/human_g1k_v37* set OK\n"
else
   echo -e "/local/ref/human_g1k_v37* set incomplete\n"
   exit 1
fi
else
echo "/local/ref/human_g1k_v37.fasta.sa exists, skip downloading!"
fi

END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "download reference $duration seconds elapsed."
START_SECONDS=$END_SECONDS

if [ ! -s "/local/ref/dbsnp_138.b37.vcf" ];then
echo "/local/ref/dbsnp_138.b37.vcf doesnot exist, downloading!"
echo -e "aws s3 sync s3://fcs-genome-pub/ref/ /local/ref/ --exclude \"*\" --include \"dbsnp_138.b37*\"  --no-sign-request \n"
         aws s3 sync s3://fcs-genome-pub/ref/ /local/ref/ --exclude  "*"  --include  "dbsnp_138.b37*"   --no-sign-request 

if [ ! -f "/local/ref/dbsnp_138.b37.vcf" ];then
   echo "/local/ref/dbsnp_138.b37.vcf is missing"
   exit 1
else
   echo -e "/local/ref/dbsnp_138.b37.vcf OK\n"
fi

else
echo "/local/ref/dbsnp_138.b37.vcf exists, skip downloading!"
fi

END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "download dbsnp $duration seconds elapsed."
