#!/bin/bash
#***************************************************************************************
# brief:
#      --start point of one test sequence
#      --usage: run_OneTestYUV.sh ${TestType}  ${TestYUVName} \
#                                 ${FinalResultDir}  ${ConfigureFile} \
#                                 ${AssignedCasesFile}
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
	echo "AssignedCasesFile is  ${AssignedCasesFile}"
	echo ""
	echo -e "\033[32m ********************************************************************** \033[0m">${TestReport}
	echo -e "\033[32m  Test report for YUV ${TestYUVName}  \033[0m">>${TestReport}
	echo "">>${TestReport}
	
	runGetYUVFullPath  ${TestYUVName}  ${ConfigureFile}
	if [ ! $? -eq 0 ]
	then
		echo ""
		echo  -e "\033[31m  can not find test yuv file ${TestYUVName} \033[0m"
		echo ""
		echo -e "\033[31m Failed!\033[0m">>${TestReport}
		echo -e "\033[31m can not find test yuv file ${TestYUVName}  under host ${HostName} \033[0m">>${TestReport}
		exit 1
	else
		echo ""
		echo  -e "\033[32m  TestYUVFullPath is ${TestYUVFullPath}  \033[0m"
		echo ""
	fi
	
	#generate SHA-1 table
	echo ""
	echo " TestYUVFullPath  is ${TestYUVFullPath}"
	./run_TestAssignedCases.sh  ${LocalWorkingDir}  ${ConfigureFile}  ${TestYUVName}  ${TestYUVFullPath}  ${AssignedCasesFile} ${AssignedCasesIndex} 
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
		
		if [ -d ${LocalWorkingDir} ]
                then
                        ./run_SafeDelete.sh  ${LocalWorkingDir}
                fi
		mkdir -p ${LocalWorkingDir}
		cp -f ./*   ${LocalWorkingDir}	
	else
		LocalWorkingDir=`pwd`
		echo ""
		echo "LocalTest local data dir is ${LocalWorkingDir}"
		echo ""
	fi	
}

runCheck()
{
	if [ ! -d ${FinalResultDir} ]
	then
		echo " finale result directory does not exist,please double check!"
		exit 1
	fi

	if [ ! -e ${ConfigureFile} ]
	then
		echo "configure file does not exist, please double check!"
		exit 1
	fi

	if [ ! -e ${AssignedCasesFile} ]
	then
		echo "assigned cases file doest not exist,please double check!"
		exit 1
	fi

}

#usage:  runMain ${TestType} ${TestYUVName}  ${FinalResultDir}  ${ConfigureFile} ${AssignedCasesFile}
 runMain()
 {
	if [ ! $# -eq 6 ]
	then
		echo "usage: runMain \${TestType}  \${TestYUVName} \${FinalResultDir}  \${ConfigureFile} \${AssignedCasesFile} \${AssignedCasesIndex} "
		echo "detected by run_OneTestYUV.sh"
		return 1
	fi
	
	TestType=$1
	TestYUVName=$2
	FinalResultDir=$3
	ConfigureFile=$4
	AssignedCasesFile=$5
	AssignedCasesIndex=$6

	HostName=`hostname`
	TestYUVFullPath=""
	CurrentDir=`pwd`
	ConfigureFile=`echo ${ConfigureFile} | awk 'BEGIN {FS="/"} {print $NF}'`
	
	runCheck
	
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
		TestReport="${FinalResultDir}/TestReport_${TestYUVName}_${AssignedCasesIndex}.report"
		cd ${LocalWorkingDir}
		runTestOneYUV
		PassedFlag=$?		
		cd ${CurrentDir}
	else
		TestReport="${FinalResultDir}/TestReport_${TestYUVName}.report"
		runTestOneYUV
		PassedFlag=$?		
	fi		
	return ${PassedFlag}
}

TestType=$1
TestYUVName=$2
FinalResultDir=$3
ConfigureFile=$4
AssignedCasesFile=$5
AssignedCasesIndex=$6
runMain  ${TestType} ${TestYUVName}  ${FinalResultDir}  ${ConfigureFile} ${AssignedCasesFile}  ${AssignedCasesIndex}
