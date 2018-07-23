unmappedFlag=$1
lineNum=$2
if [ "$unmappedFlag" == "0" ]; then
	tsvFile="sequence_grouping.txt"
else
	tsvFile="sequence_grouping_with_unmapped.txt"
fi

#echo $tsvFile

listStr=""
for i in `head -${lineNum} $tsvFile | tail -1`; do
#echo $i;
listStr="${listStr}-L $i "
done
echo "${listStr::-1}"



