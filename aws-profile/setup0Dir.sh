#
curUser="centos"

refDir="/local/ref"
fastqDir="/local/fastq"
mutect2Dir="/local/mutect2"
falconScriptsDir="/local/falcon"

if [ -d "$refDir" ];then
echo "$refDir exists"
else
echo "$refDir does not exist!"
sudo mkdir -p $refDir
sudo chmod a+w $refDir
sudo chown $curUser $refDir
echo "mkdir $refDir"
fi

if [ -d "$fastqDir" ];then
echo "$fastqDir exists"
else
echo "$fastqDir does not exist!"
sudo mkdir -p $fastqDir
sudo chmod a+w $fastqDir
sudo chown $curUser $fastqDir
echo "mkdir $fastqDir"
fi

if [ -d "$mutect2Dir" ];then
echo "$mutect2Dir exists"
else
echo "$mutect2Dir does not exist!"
sudo mkdir -p $mutect2Dir
sudo chmod a+w $mutect2Dir
sudo chown $curUser $mutect2Dir
echo "mkdir $mutect2Dir"
fi

if [ -d "$falconScriptsDir" ];then
echo "$falconScriptsDir exists"
else
echo "$falconScriptsDir does not exist!"
sudo mkdir -p $falconScriptsDir
sudo chmod a+w $falconScriptsDir
sudo chown $curUser $falconScriptsDir
echo "mkdir $falconScriptsDir"
fi
          
