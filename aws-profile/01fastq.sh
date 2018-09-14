#!/bin/bash

sample_id=$1
START_SECONDS=0

case $sample_id in
"NA12878")
if [[ -s "/local/fastq/NA12878_1.fastq.gz" ]] && [[ -s "/local/fastq/NA12878_2.fastq.gz" ]]; then
   echo "/local/fastq/NA12878_1.fastq.gz already exists !"
   echo "/local/fastq/NA12878_2.fastq.gz already exists !"
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "download fastq $duration seconds elapsed."
   exit
fi

echo "==========================================================="
echo "Downloading WES NA12878 FASTQ files from aws s3 repository"
echo -e "===========================================================\n"
echo -e "aws s3 sync s3://fcs-genome-pub/fastq/WES/ /local/fastq/  --exclude \"*\" --include \"NA*\"  --no-sign-request \n"
         #aws s3 sync s3://fcs-genome-pub/fastq/WES/ /local/fastq/  --exclude  "*"  --include  "NA*"   --no-sign-request
         aws s3 cp s3://fcs-genome-data/fastq/WES/NA12878-Rep01_S1_L001_R1_001.fastq.gz /local/fastq/
         aws s3 cp s3://fcs-genome-data/fastq/WES/NA12878-Rep01_S1_L001_R2_001.fastq.gz /local/fastq/
if [[ -s "/local/fastq/NA12878-Rep01_S1_L001_R1_001.fastq.gz" ]] && [[ -s "/local/fastq/NA12878-Rep01_S1_L001_R2_001.fastq.gz" ]];then
   echo "/local/fastq/NA12878-Rep01_S1_L001_R1_001.fastq.gz  OK"
   echo -e "/local/fastq/NA12878-Rep01_S1_L001_R2_001.fastq.gz  OK\n"
else
   echo "WES NA12878 FASTQ Files failed to be downloaded"
   exit 1
fi
ln -s /local/fastq/NA12878-Rep01_S1_L001_R1_001.fastq.gz /local/fastq/NA12878_1.fastq.gz
ln -s /local/fastq/NA12878-Rep01_S1_L001_R2_001.fastq.gz /local/fastq/NA12878_2.fastq.gz
if [[ -s "/local/fastq/NA12878_1.fastq.gz" ]] && [[ -s "/local/fastq/NA12878_2.fastq.gz" ]]; then
   echo "/local/fastq/NA12878_1.fastq.gz  OK"
   echo "/local/fastq/NA12878_2.fastq.gz  OK"
fi
;;

"NA12891") 
if [[ -s "/local/fastq/NA12891_1.fastq.gz" ]] && [[ -s "/local/fastq/NA12891_2.fastq.gz" ]]; then
   echo "/local/fastq/NA12891_1.fastq.gz already exists !"
   echo "/local/fastq/NA12891_2.fastq.gz already exists !"
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "download fastq $duration seconds elapsed."
   exit
fi

echo "==========================================================="
echo "Downloading WES NA12891 FASTQ files from aws s3 repository"
echo -e "===========================================================\n"
echo -e "aws s3 sync s3://fcs-genome-data/fastq/WES/ /local/fastq/  --exclude \"*\" --include \"NA12891*\"  --no-sign-request \n"
         aws s3 cp s3://fcs-genome-data/fastq/WES/NA12891-Rep01_S5_L001_R1_001.fastq.gz /local/fastq/ 
         aws s3 cp s3://fcs-genome-data/fastq/WES/NA12891-Rep01_S5_L001_R2_001.fastq.gz /local/fastq/ 
if [[ -s "/local/fastq/NA12891-Rep01_S5_L001_R1_001.fastq.gz" ]] && [[ -s "/local/fastq/NA12891-Rep01_S5_L001_R2_001.fastq.gz" ]];then
   echo "/local/fastq/NA12891-Rep01_S5_L001_R1_001.fastq.gz  OK"
   echo -e "/local/fastq/NA12891-Rep01_S5_L001_R2_001.fastq.gz  OK\n"
else
   echo "WES NA12891 FASTQ Files failed to be downloaded"
   exit 1
fi
ln -s /local/fastq/NA12891-Rep01_S5_L001_R1_001.fastq.gz /local/fastq/NA12891_1.fastq.gz
ln -s /local/fastq/NA12891-Rep01_S5_L001_R2_001.fastq.gz /local/fastq/NA12891_2.fastq.gz
if [[ -s "/local/fastq/NA12891_1.fastq.gz" ]] && [[ -s "/local/fastq/NA12891_2.fastq.gz" ]]; then
   echo "/local/fastq/NA12891_1.fastq.gz  OK"
   echo "/local/fastq/NA12891_2.fastq.gz  OK"
fi
;;


"NA12892") 
if [[ -s "/local/fastq/NA12892_1.fastq.gz" ]] && [[ -s "/local/fastq/NA12892_2.fastq.gz" ]]; then
   echo "/local/fastq/NA12892_1.fastq.gz already exists !"
   echo "/local/fastq/NA12892_2.fastq.gz already exists !"
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "download fastq $duration seconds elapsed."
   exit
fi


echo "==========================================================="
echo "Downloading WES NA12892 FASTQ files from aws s3 repository"
echo -e "===========================================================\n"
echo -e "aws s3 sync s3://fcs-genome-data/fastq/WES/ /local/fastq/  --exclude \"*\" --include \"NA12892*\"  --no-sign-request \n"
         aws s3 cp s3://fcs-genome-data/fastq/WES/NA12892-Rep01_S9_L001_R1_001.fastq.gz /local/fastq/ 
         aws s3 cp s3://fcs-genome-data/fastq/WES/NA12892-Rep01_S9_L001_R2_001.fastq.gz /local/fastq/ 
if [[ -s "/local/fastq/NA12892-Rep01_S9_L001_R1_001.fastq.gz" ]] && [[ -s "/local/fastq/NA12892-Rep01_S9_L001_R2_001.fastq.gz" ]];then
   echo "/local/fastq/NA12892-Rep01_S9_L001_R1_001.fastq.gz  OK"
   echo -e "/local/fastq/NA12892-Rep01_S9_L001_R2_001.fastq.gz  OK\n"
else
   echo "WES NA12892 FASTQ Files failed to be downloaded"
   exit 1
fi
ln -s /local/fastq/NA12892-Rep01_S9_L001_R1_001.fastq.gz /local/fastq/NA12892_1.fastq.gz
ln -s /local/fastq/NA12892-Rep01_S9_L001_R2_001.fastq.gz /local/fastq/NA12892_2.fastq.gz
if [[ -s "/local/fastq/NA12892_1.fastq.gz" ]] && [[ -s "/local/fastq/NA12892_2.fastq.gz" ]]; then
   echo "/local/fastq/NA12892_1.fastq.gz  OK"
   echo "/local/fastq/NA12892_2.fastq.gz  OK"
fi
;;
 
"NA12878-Garvan") 
if [[ -s "/local/fastq/NA12878-Garvan_1.fastq.gz" ]] && [[ -s "/local/fastq/NA12878-Garvan_2.fastq.gz" ]]; then
   echo "/local/fastq/NA12878-Garvan_1.fastq.gz already exists !"
   echo "/local/fastq/NA12878-Garvan_2.fastq.gz already exists !"
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "download fastq $duration seconds elapsed."
   exit
fi


echo "==========================================================="
echo "Downloading WGS NA12878-Garvan FASTQ files from aws s3 repository"
echo -e "===========================================================\n"
echo -e "aws s3 sync s3://fcs-genome-data/fastq/WGS/ /local/fastq/  --exclude \"*\" --include \"NA12878-Garvan*\"  --no-sign-request \n"
         aws s3 cp s3://fcs-genome-data/fastq/WGS/NA12878-Garvan-Vial1_R1.fastq.gz /local/fastq/ 
         aws s3 cp s3://fcs-genome-data/fastq/WGS/NA12878-Garvan-Vial1_R2.fastq.gz /local/fastq/ 
if [[ -s "/local/fastq/NA12878-Garvan-Vial1_R1.fastq.gz" ]] && [[ -s "/local/fastq/NA12878-Garvan-Vial1_R2.fastq.gz" ]];then
   echo "/local/fastq/NA12878-Garvan-Vial1_R1.fastq.gz  OK"
   echo -e "/local/fastq/NA12878-Garvan-Vial1_R2.fastq.gz  OK\n"
else
   echo "WGS NA12878-Garvan FASTQ Files failed to be downloaded"
   exit 1
fi
ln -s /local/fastq/NA12878-Garvan-Vial1_R1.fastq.gz /local/fastq/NA12878-Garvan_1.fastq.gz
ln -s /local/fastq/NA12878-Garvan-Vial1_R2.fastq.gz /local/fastq/NA12878-Garvan_2.fastq.gz
if [[ -s "/local/fastq/NA12878-Garvan_1.fastq.gz" ]] && [[ -s "/local/fastq/NA12878-Garvan_2.fastq.gz" ]]; then
   echo "/local/fastq/NA12878-Garvan_1.fastq.gz  OK"
   echo "/local/fastq/NA12878-Garvan_2.fastq.gz  OK"
fi
;;
 
"TCRBOA1-N") 
if [[ -s "/local/fastq/TCRBOA1-N_1.fastq.gz" ]] && [[ -s "/local/fastq/TCRBOA1-N_2.fastq.gz" ]]; then
   echo "/local/fastq/TCRBOA1-N_1.fastq.gz already exists !"
   echo "/local/fastq/TCRBOA1-N_2.fastq.gz already exists !"
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "download fastq $duration seconds elapsed."
   exit
fi


echo "==========================================================="
echo "Downloading WES mutect2 TCRBOA1-N FASTQ files from aws s3 repository"
echo -e "===========================================================\n"
echo -e "aws s3 sync s3://fcs-genome-data/fastq/mutect2/Baylor/ /local/fastq/  --exclude \"*\" --include \"TCRBOA1-N*\"  --no-sign-request \n"
         aws s3 cp s3://fcs-genome-data/fastq/mutect2/Baylor/TCRBOA1-N-WEX.read1.fastq.gz /local/fastq/ 
         aws s3 cp s3://fcs-genome-data/fastq/mutect2/Baylor/TCRBOA1-N-WEX.read2.fastq.gz /local/fastq/ 
if [[ -s "/local/fastq/TCRBOA1-N-WEX.read1.fastq.gz" ]] && [[ -s "/local/fastq/TCRBOA1-N-WEX.read2.fastq.gz" ]];then
   echo "/local/fastq/TCRBOA1-N-WEX.read1.fastq.gz  OK"
   echo -e "/local/fastq/TCRBOA1-N-WEX.read2.fastq.gz  OK\n"
else
   echo "WES mutect2 TCRBOA1-N FASTQ Files failed to be downloaded"
   exit 1
fi
ln -s /local/fastq/TCRBOA1-N-WEX.read1.fastq.gz /local/fastq/TCRBOA1-N_1.fastq.gz
ln -s /local/fastq/TCRBOA1-N-WEX.read2.fastq.gz /local/fastq/TCRBOA1-N_2.fastq.gz
if [[ -s "/local/fastq/TCRBOA1-N_1.fastq.gz" ]] && [[ -s "/local/fastq/TCRBOA1-N_2.fastq.gz" ]]; then
   echo "/local/fastq/TCRBOA1-N_1.fastq.gz  OK"
   echo "/local/fastq/TCRBOA1-N_2.fastq.gz  OK"
fi
;;
 
"TCRBOA1-T") 
if [[ -s "/local/fastq/TCRBOA1-T_1.fastq.gz" ]] && [[ -s "/local/fastq/TCRBOA1-T_2.fastq.gz" ]]; then
   echo "/local/fastq/TCRBOA1-T_1.fastq.gz already exists !"
   echo "/local/fastq/TCRBOA1-T_2.fastq.gz already exists !"
END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "download fastq $duration seconds elapsed."
   exit
fi


echo "==========================================================="
echo "Downloading WES mutect2 TCRBOA1-T FASTQ files from aws s3 repository"
echo -e "===========================================================\n"
echo -e "aws s3 sync s3://fcs-genome-data/fastq/mutect2/Baylor/ /local/fastq/  --exclude \"*\" --include \"TCRBOA1-T*\"  --no-sign-request \n"
         aws s3 cp s3://fcs-genome-data/fastq/mutect2/Baylor/TCRBOA1-T-WEX.read1.fastq.gz /local/fastq/ 
         aws s3 cp s3://fcs-genome-data/fastq/mutect2/Baylor/TCRBOA1-T-WEX.read2.fastq.gz /local/fastq/ 
if [[ -s "/local/fastq/TCRBOA1-T-WEX.read1.fastq.gz" ]] && [[ -s "/local/fastq/TCRBOA1-T-WEX.read2.fastq.gz" ]];then
   echo "/local/fastq/TCRBOA1-T-WEX.read1.fastq.gz  OK"
   echo -e "/local/fastq/TCRBOA1-T-WEX.read2.fastq.gz  OK\n"
else
   echo "WES mutect2 TCRBOA1-T FASTQ Files failed to be downloaded"
   exit 1
fi
ln -s /local/fastq/TCRBOA1-T-WEX.read1.fastq.gz /local/fastq/TCRBOA1-T_1.fastq.gz
ln -s /local/fastq/TCRBOA1-T-WEX.read2.fastq.gz /local/fastq/TCRBOA1-T_2.fastq.gz
if [[ -s "/local/fastq/TCRBOA1-T_1.fastq.gz" ]] && [[ -s "/local/fastq/TCRBOA1-T_2.fastq.gz" ]]; then
   echo "/local/fastq/TCRBOA1-T_1.fastq.gz  OK"
   echo "/local/fastq/TCRBOA1-T_2.fastq.gz  OK"
fi
;;
 
*) echo "Sorry, no matching input!";;
esac

END_SECONDS=$SECONDS
duration=$((END_SECONDS-START_SECONDS))
echo "download fastq $duration seconds elapsed."

