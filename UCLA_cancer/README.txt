#REQUIREMENTS

#snpEFF

wget http://sourceforge.net/projects/snpeff/files/snpEff_latest_core.zip
unzip snpEff_latest_core.zip
java -jar snpEff.jar download GRCh38.86

#R and its packages

sudo yum install R
install.packages(“gsalib”)
install.packages(“ggplot2”)
install.packages(“gplots”)
install.packages(“reshape”)


