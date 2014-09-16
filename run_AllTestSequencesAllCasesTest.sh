

#!/bin/bash
#***************************************************************************************
# brief:
#      --test all cases of all sequences 
#      --usage:  run_AllBitStreamALlCasesTest  ${AllTestDataDir} \
#                                              ${FinalResultDir} \
#                                              ${ConfigureFile}
#
#
#date: 05/08/2014 Created
#***************************************************************************************

#usage: runGetTestYUVList  ${ConfigureFile}
runGetTestYUVList()
{
	if [ ! $# -eq 1  ]
	then
	echo "usage: runGetTestYUVList  \${ConfigureFile}"
	return 1
	fi
	local ConfigureFile=$1
	local TestSet0=""
	local TestSet1=""
	local TestSet2=""
	local TestSet3=""
	local TestSet4=""
	local TestSet5=""
	local TestSet6=""
	local TestSet7=""
	local TestSet8=""
	while read line
	do
	if [[ "$line" =~ ^TestSet0  ]]
	then
		TestSet0=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
	elif  [[ "$line" =~ ^TestSet1  ]]
	then
		TestSet1=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
	elif  [[ "$line" =~ ^TestSet2  ]]
	then
		TestSet2=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
	elif  [[ "$line" =~ ^TestSet3  ]]
	then
		TestSet3=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
	elif  [[ "$line" =~ ^TestSet4  ]]
	then
		TestSet4=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
	elif  [[ "$line" =~ ^TestSet5  ]]
	then
		TestSet5=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
	elif  [[ "$line" =~ ^TestSet6  ]]
	then
		TestSet6=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
	elif  [[ "$line" =~ ^TestSet7  ]]
	then
		TestSet7=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
	elif  [[ "$line" =~ ^TestSet8  ]]
	then
		TestSet8=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
	fi
	done <${ConfigureFile}
	echo "${TestSet0}  ${TestSet1}  ${TestSet2}  ${TestSet3}  ${TestSet4}  ${TestSet5}  ${TestSet6}  ${TestSet7} ${TestSet8}   "
}
#usage: runAllTestBitstream   ${BitstreamDir} ${AllTestDataDir}  ${FinalResultDir}
runAllTestBitstream()
{
	#parameter check!
	if [ ! $# -eq 3  ]
	then
		echo "usage: runAllTestBitstream  \${AllTestDataDir}  \${FinalResultDir}  \${ConfigureFile}"
		return 1
	fi
	local AllTestDataDir=$1
	local FinalResultDir=$2
	local ConfigureFile=$3
	local CurrentDir=`pwd`
	let   "Flag=0"
	local TestFlagFile=""
	declare -a aTestYUVList
	#get full path info
	cd ${FinalResultDir}
	FinalResultDir=`pwd`
	cd  ${CurrentDir}
	let "Flag=0"
	aTestYUVList=(`runGetTestYUVList  ${ConfigureFile}`)
	for TestYUV in ${aTestYUVList[@]}
	do
		SubFolder="${AllTestDataDir}/${TestYUV}"
		TestFlagFile="${TestYUV}_Tested.flag"
		if [ -e   ${SubFolder}/${TestFlagFile} ]
		then
			continue
		fi
		cd  ${SubFolder}
		echo ""
		echo "test YUV is ${TestYUV}"
		echo ""
		./run_OneTestYUV.sh  ${TestYUV}  ${FinalResultDir}  ${ConfigureFile}
		if [  ! $? -eq 0 ]
		then
			echo -e "\033[31m not all test cases have been passed! \033[0m"
			let "Flag=1"
		fi
		#when test completed, generate flag file to avoid repeating test
		touch ${TestFlagFile}
		cd  ${CurrentDir}
	done
	if [ ! ${Flag} -eq 0  ]
	then
	return 1
	else
	return 0
	fi
}
AllTestDataDir=$1
FinalResultDir=$2
ConfigureFile=$3
runAllTestBitstream   ${AllTestDataDir}  ${FinalResultDir} ${ConfigureFile}


