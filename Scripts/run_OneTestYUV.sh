#!/bin/bash
#***************************************************************************************
# brief:
#      --start point of one test sequence
#      --usage: run_OneTestYUV.sh ${TestType}  ${TestYUVName} \${TestYUVFullPath}
#                                 ${FinalResultDir}  ${ConfigureFile}
#
#
#date:  5/08/2014 Created
#***************************************************************************************
#usage: runGetYUVFullPath  ${TestYUVName}  ${ConfigureFile}
runDeleteYUV()
{
	for YUVFile  in ${LocalWorkingDir}/*.yuv
	do
		./run_SafeDelete.sh ${YUVFile} 
	done
	
}
runTestOneYUV()
{
	echo ""
	echo  "TestYUVName is ${TestYUVName}"
	echo "OutPutCaseFile is  ${OutPutCaseFile}"
	echo ""
	echo -e "\033[32m ********************************************************************** \033[0m">${TestReport}
	echo -e "\033[32m  Test report for YUV ${TestYUVName}  \033[0m">>${TestReport}
	echo "">>${TestReport}
	
	if [ ! -e ${TestYUVFullPath} ]
	then
		echo ""
		echo  -e "\033[31m  can not find test yuv file ${TestYUVFullPath} \033[0m"
		echo  -e "\033[31m    it may caused by decode failed when transform bit stream to YUV \033[0m"
		echo ""
		echo -e "\033[31m Failed!\033[0m">>${TestReport}
		echo -e "\033[31m can not find test yuv file ${TestYUVName}  under host ${HostName} \033[0m">>${TestReport}
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
		echo -e "\033[31m Failed! \033[0m">>${TestReport}
		echo -e "\033[31m failed to generate cases ! \033[0m">>${TestReport}
		return 1
	fi
	
	#generate SHA-1 table
	echo ""
	echo " TestYUVFullPath  is ${TestYUVFullPath}"
	./run_TestAllCases.sh  ${LocalWorkingDir}  ${ConfigureFile}  ${TestYUVName}  ${TestYUVFullPath}  ${OutPutCaseFile}
	if [  ! $? -eq 0 ]
	then
		echo -e "\033[31m Failed! \033[0m">>${TestReport}
		echo -e "\033[31m Not all Cases passed the test! \033[0m">>${TestReport}
		cat  ${LocalWorkingDir}/result/${TestYUVName}.Summary >>${TestReport}
		
		cp   ${LocalWorkingDir}/result/*.csv    ${FinalResultDir}
		
		runDeleteYUV
		return 1
	else
		echo -e "\033[32m Succeed! \033[0m">>${TestReport}
		echo -e "\033[32m All Cases passed the test! \033[0m">>${TestReport}
		cat  ${LocalWorkingDir}/result/${TestYUVName}.Summary >>${TestReport}
		
		cp   ${LocalWorkingDir}/result/*.csv    ${FinalResultDir}
		
		runDeleteYUV
		return 0
	fi
}
#create local test space
runSetLocalWorkingDir()
{
	TempDataDir="/home"
	
	if [ ${TestType} = "SGETest" ]
	then
		SGEJobID=$JOB_ID
		LocalWorkingDir="${TempDataDir}/${HostName}/SGEJobID_${SGEJobID}"
		echo ""
		echo "SGETest local data dir is ${LocalWorkingDir}"
		echo ""
		mkdir -p ${LocalWorkingDir}
		cp -f ./*   ${LocalWorkingDir}	
	else
		LocalWorkingDir=`pwd`
		echo ""
		echo "LocalTest local data dir is ${LocalWorkingDir}"
		echo ""
	fi	
}
#usage:  runMain ${TestType} ${TestYUVName} \${TestYUVFullPath} ${FinalResultDir}  ${ConfigureFile}
 runMain()
 {
	if [ ! $# -eq 5 ]
	then
		echo "usage: runMain \${TestType}  \${TestYUVName} \${TestYUVFullPath} \${FinalResultDir}  \${ConfigureFile} \${TestYUVFullPath}"
		echo "detected by run_OneTestYUV.sh"
		return 1
	fi
	
	TestType=$1
	TestYUVName=$2
	TestYUVFullPath=$3
	FinalResultDir=$4
	ConfigureFile=$5
	
	
	HostName=`hostname`
	
	TestReport="${FinalResultDir}/TestReport_${TestYUVName}.report"
	CurrentDir=`pwd`
	OutPutCaseFile=""
	ConfigureFile=`echo ${ConfigureFile} | awk 'BEGIN {FS="/"} {print $NF}'`
	OutPutCaseFile=${TestYUVName}_AllCase.csv
	
	
	
	#for both SGE data and local test, in order to decrease tho sge-master's workload,
	#need local data folder for each job/testYUV
	LocalWorkingDir=""
	runSetLocalWorkingDir
	
	echo ""
	echo "test ${TestYUVName}  under ${HostName}"
	echo "test type is ${TestType}"
	echo "local host test directory is ${LocalWorkingDir} "
	echo ""
	
	if [ ${TestType} = "SGETest" ]
	then
		cd ${LocalWorkingDir}
		runTestOneYUV
		PassedFlag=$?		
		cd ${CurrentDir}
	else
		runTestOneYUV
		PassedFlag=$?		
	fi		
	return ${PassedFlag}
}
TestType=$1
TestYUVName=$2
TestYUVFullPath=$3
FinalResultDir=$4
ConfigureFile=$5
runMain  ${TestType} ${TestYUVName} ${TestYUVFullPath} ${FinalResultDir}  ${ConfigureFile}

