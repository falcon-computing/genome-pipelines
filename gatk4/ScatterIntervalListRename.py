import glob, os
import sys

# Works around a JES limitation where multiples files with the same name overwrite each other when globbed
#outDir="/genome/ssd2/peipei/output"
scatterCount=sys.argv[1]
outDir=sys.argv[2]
scatterListDir=outDir+"/scatterList_"+scatterCount
print(scatterListDir)
intervals = sorted(glob.glob(scatterListDir+"/*/*.interval_list"))
for i, interval in enumerate(intervals):
  (directory, filename) = os.path.split(interval)
  newName = os.path.join(directory, str(i + 1) + filename)
  os.rename(interval, newName)
print(len(intervals))
