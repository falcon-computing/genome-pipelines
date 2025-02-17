base_file_name="NA12892_falcon"
#tool
#picardJar="/curr/peipei/falcon/tools/package/picard.jar"
#Picard version: 2.15.0-SNAPSHOT
picardJar="/curr/peipei/firecloudReference/tools/picard.jar"
#0.7.13-r1126
#bwa="/curr/peipei/falcon/tools/bin/bwa-org"
#0.7.15-r1140
bwa="/curr/peipei/firecloudReference/tools/bwa"

#1.1.3
VerifyBamID="/curr/peipei/firecloudReference/tools/Griffan-VerifyBamID-c679778/bin/VerifyBamID"

#4.0.6.0
gatk4Tool="/curr/peipei/local/gatk/gatk"

#Dir
bamDir="/genome/ssd2/peipei/0inputUnmappedBAM"
refDir="/genome/ssd2/peipei/1reference"
outDir="/genome/ssd2/peipei/output"

#tmpDir
tmpDir="/genome/ssd2/peipei/output/tmp"
export _JAVA_OPTIONS=-Djava.io.tmpdir="$tmpDir"
export TMPDIR="$tmpDir"
