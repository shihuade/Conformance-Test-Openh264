#!/bin/bash
#***************************************************************************************
# brief:
#      --start point of one test sequence
#      --usage: run_TestOneYUVWithAssignedCases.sh  ${TestType}        ${TestYUVName}
#                                                   ${FinalResultDir}  ${ConfigureFile}
#                                                   ${SubCaseIndex}    ${SubCaseFile}
#
#
#date:  04/23/2014 Created
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
    let "InputFormat=0"
	while read line
	do
		if [[  $line =~ ^TestYUVDir  ]]
		then
			 YUVDir=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
        elif [[  $line =~ ^InputFormat  ]]
        then
            vTemp=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
            let "InputFormat=${vTemp}"
        fi
	done <${ConfigureFile}


    if [ ! ${InputFormat} -eq 0 ]
    then
        TestYUVFullPath=`pwd`
        TestYUVFullPath=${TestYUVFullPath}/${TestYUVName}
    else
        if [  ! -d ${YUVDir} ]
        then
            echo "YUV directory setting is not correct,${YUVDir} does not exist! "
            exit 1
        fi
        TestYUVFullPath=`./run_GetYUVPath.sh  ${TestYUVName}  ${YUVDir}`
    fi
	return $?
}

runCheckInputYUV()
{

    if [ ! -s  ${TestYUVFullPath} ]
    then
        echo "YUV file size is zero,please double check! "
        return 1
    fi

    return 0

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
	echo -e "\033[32m  Test report for YUV ${TestYUVName}   \033[0m">>${TestReport}
    echo -e "\033[32m  Sub-Case Index is : ${SubCaseIndex}  \033[0m">>${TestReport}
    echo -e "\033[32m  Host name    is: ${HostName}             \033[0m">>${TestReport}
    echo -e "\033[32m  SGE job ID   is: ${SGEJobID}             \033[0m">>${TestReport}
    echo -e "\033[32m  SGE job name is: ${JOB_NAME}             \033[0m">>${TestReport}

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

    runCheckInputYUV
    if [ ! $? -eq 0 ]
    then
        echo ""
        echo  -e "\033[31m  file size of test yuv is 0; please double check! file is --${TestYUVName} \033[0m"
        echo ""
        echo -e "\033[31m Failed!\033[0m">>${TestReport}
        echo -e "\033[31m file size of test yuv is 0! --${TestYUVName}  under host ${HostName} \033[0m">>${TestReport}
        exit 1
    fi


    #generate SHA-1 table
	echo ""
	echo " TestYUVFullPath  is ${TestYUVFullPath}"
    ./run_TestAssignedCases.sh  ${LocalWorkingDir}  ${ConfigureFile}   \
                                ${TestYUVName}      ${TestYUVFullPath} \
                                ${SubCaseIndex}     ${AssignedCasesFile}
	if [  ! $? -eq 0 ]
	then
		echo -e "\033[31m Failed! \033[0m">>${TestReport}
		echo -e "\033[31m Not all Cases passed the test! \033[0m">>${TestReport}
		cat  ${LocalWorkingDir}/result/${TestSummaryFileName} >>${TestReport}
		
		cp  -f ${LocalWorkingDir}/result/*.csv       ${FinalResultDir}
		runDeleteYUV
		return 1
	else
		echo -e "\033[32m Succeed! \033[0m">>${TestReport}
		echo -e "\033[32m All Cases passed the test! \033[0m" >>${TestReport}
		cat  ${LocalWorkingDir}/result/${TestSummaryFileName} >>${TestReport}
		
		cp  -f ${LocalWorkingDir}/result/*.csv    ${FinalResultDir}

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
        echo -e "\033[32m ****************************************************************************** \033[0m"
        echo -e "\033[32m ****************************************************************************** \033[0m"
		echo -e "\033[32m    SGETest local data dir is ${LocalWorkingDir} \033[0m"
        echo -e "\033[32m ****************************************************************************** \033[0m"
        echo -e "\033[32m ****************************************************************************** \033[0m"

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
        echo -e "\033[32m ****************************************************************************** \033[0m"
        echo -e "\033[32m ****************************************************************************** \033[0m"
		echo -e "\033[32m  LocalTest local data dir is ${LocalWorkingDir} \033[0m"
        echo -e "\033[32m ****************************************************************************** \033[0m"
        echo -e "\033[32m ****************************************************************************** \033[0m"
		echo ""
	fi	
}

#usage:  runMain ${TestType} ${TestYUVName}  ${FinalResultDir}  ${ConfigureFile}
 runMain()
 {
	if [ ! $# -eq 6 ]
	then
		echo -e "\033[32m usage: runMain  \${TestType}      \${TestYUVName}  \${FinalResultDir} \033[0m"
        echo -e "\033[32m                 \${ConfigureFile} \${SubCaseIndex} \${SubCaseFile}    \033[0m"
		echo -e "\033[32m  detected by run_TestOneYUVWithAssignedCases.sh \033[0m"
		return 1
	fi
	
	TestType=$1
	TestYUVName=$2
	FinalResultDir=$3
	ConfigureFile=$4
    SubCaseIndex=$5
	AssignedCasesFile=$6

	HostName=`hostname`
	TestYUVFullPath=""
	TestReport="${FinalResultDir}/TestReport_${TestYUVName}_SubCasesIndex_${SubCaseIndex}.report"
    TestSummaryFileName="${TestYUVName}_SubCasesIndex_${SubCaseIndex}.Summary"
	CurrentDir=`pwd`
	ConfigureFile=`echo ${ConfigureFile} | awk 'BEGIN {FS="/"} {print $NF}'`
	
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
FinalResultDir=$3
ConfigureFile=$4
SubCaseIndex=$5
SubCaseFile=$6
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo "*********************************************************"
echo ""
runMain  ${TestType} ${TestYUVName}  ${FinalResultDir}  ${ConfigureFile} ${SubCaseIndex} ${SubCaseFile}
