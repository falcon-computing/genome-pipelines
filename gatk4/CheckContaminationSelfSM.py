import csv
import sys

#outDir=sys.argv[1]
outDir="/genome/ssd2/peipei/output"

with open(outDir+'/NA12878_falcon.preBqsr.selfSM') as selfSM:
#with open('/genome/ssd2/peipei/output/NA12878_falcon.preBqsr.selfSM') as selfSM:
  reader = csv.DictReader(selfSM, delimiter='\t')
  i = 0
  for row in reader:
    if float(row["FREELK0"])==0 and float(row["FREELK1"])==0:
      # a zero value for the likelihoods implies no data. This usually indicates a problem rather than a real event.
      # if the bam isn't really empty, this is probably due to the use of a incompatible reference build between
      # vcf and bam.
      sys.stderr.write("Found zero likelihoods. Bam is either very-very shallow, or aligned to the wrong reference (relative to the vcf).")
      sys.exit(1)
    print(float(row["FREEMIX"])/0.75)
    i = i + 1
    # there should be exactly one row, and if this isn't the case the format of the output is unexpectedly different
    # and the results are not reliable.
    if i != 1:
      sys.stderr.write("Found %d rows in .selfSM file. Was expecting exactly 1. This is an error"%(i))
      sys.exit(2)
