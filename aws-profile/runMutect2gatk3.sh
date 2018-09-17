WORK_DIR="/local/falcon"
#setup0Dir.sh  setup1instance.sh  setup2cpumem.sh  setup3AWS.sh

sudo cp ${WORK_DIR}/license.lic /usr/local/falcon/license.lic
export LM_LICENSE_FILE=/usr/local/falcon/license.lic
sudo export LM_LICENSE_FILE=/usr/local/falcon/license.lic

${WORK_DIR}/setup0Dir.sh
${WORK_DIR}/setup1instance.sh
${WORK_DIR}/setup2cpumem.sh
${WORK_DIR}/setup3AWS.sh

#get reference fastq and dbsnp vcf file
${WORK_DIR}/scripts0.sh

#
${WORK_DIR}/scripts2DownloadMutect2gatk3.sh
##gatk pipeline
#for i in NA12878 NA12891 NA12892 TCRBOA1-N TCRBOA1-T;do
#${WORK_DIR}/scripts1Download.sh $i;
#done
##mutect2
#${WORK_DIR}/scripts2Download.sh $i;
#
#${WORK_DIR}/scripts1Download.sh NA12878-Garvan; 
#

#upload log
${WORK_DIR}/scripts3.sh


