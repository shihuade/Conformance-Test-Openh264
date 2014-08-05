#!/bin/bash
#***************************************************************************************
# brief:
#      --start point of one test sequence
#      --usage: run_OneBitStream.sh ${TestYUVName}  ${FinalResultDir}  ${ConfigureFile}
#
#
#date:  5/08/2014 Created
#***************************************************************************************
#usage: runGetYUVFullPath  ${TestYUVName}  ${ConfigureFile}
runGetYUVFullPath()
{
	if [ ! $# -eq 2  ]
	then
		echo "usage: runGetYUVFullPath  \${TestYUVName}  \${ConfigureFile} "
		return 1
	fi
	local TestYUVName=$1
	local ConfigureFile=$2
	local YUVDir=""
	while read line 
	do
		if [[  $line =~ ^TestYUVDir  ]]
		then
			 YUVDir=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
			 break
		fi 
	done <${ConfigureFile}
	if [  ! -d ${YUVDir} ]
	then
		echo "YUV directory setting is not correct,${YUVDir} does not exist! "
		exit 1
	fi
	TestYUVFullPath=`./run_GetYUVPath.sh  ${TestYUVName}  ${YUVDir}`
	return $?
}
#usage:  runMain ${TestYUVName}  ${FinalResultDir}  ${ConfigureFile}
 runMain()
 {
	if [ ! $# -eq 3 ]
	then
		echo "usage: runMain \${TestYUVName}  \${FinalResultDir}  \${ConfigureFile} "
		echo "detected by run_TestYUV.sh"
		return 1
	fi
	local TestYUVName=$1
	local FinalResultDir=$2
	local ConfigureFile=$3
	
	TestYUVFullPath=""
	local CurrentDir=`pwd` 
	local OutPutCaseFile=""
	ConfigureFile=`echo ${ConfigureFile} | awk 'BEGIN {FS="/"} {print $NF}'`
	OutPutCaseFile=${TestYUVName}_AllCase.csv
	echo ""
	echo  "TestYUVName is ${TestYUVName}" 
	echo "OutPutCaseFile is  ${OutPutCaseFile}"
	
	
	runGetYUVFullPath  ${TestYUVName}  ${ConfigureFile}
	if [ ! $? -eq 0 ]
	then
		echo ""
		echo  -e "\033[31m  can not find test yuv file ${TestYUVName} \033[0m"
		echo ""
		exit 1
	else
		echo ""
		echo  -e "\033[32m  TestYUVFullPath is ${TestYUVFullPath}  \033[0m"
		echo ""
	fi
	#Case generation
	echo ""
	echo "CurrentDir is ${CurrentDir}"
	echo "${ConfigureFile}   ${TestYUVName}   ${OutputCaseFile}"
	./run_GenerateCase.sh  ${ConfigureFile}   ${TestYUVName}   ${OutPutCaseFile}
	if [  ! $? -eq 0 ]
	then
		echo ""
		echo  -e "\033[31m  failed to generate cases ! \033[0m"
		echo ""
		exit 1
	fi
	#generate SHA-1 table
	echo ""
	echo " TestYUVFullPath  is ${TestYUVFullPath}"
	./run_TestAllCases.sh  ${ConfigureFile}  ${TestYUVName}  ${TestYUVFullPath}  ${OutPutCaseFile}
	if [  ! $? -eq 0 ]
	then
		cp  ./result/*    ${FinalResultDir}
		exit 1
	else
		cp  ./result/*    ${FinalResultDir}
		exit 0
	fi
}
TestYUVName=$1
FinalResultDir=$2
ConfigureFile=$3
runMain ${TestYUVName}  ${FinalResultDir}  ${ConfigureFile}


