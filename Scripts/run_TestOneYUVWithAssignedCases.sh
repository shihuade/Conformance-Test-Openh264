#!/bin/bash
#***************************************************************************************
# brief:
#      --start point of one test sequence
#      --usage: run_TestOneYUVWithAssignedCases.sh  ${TestType}        ${TestYUVName}
#                                                   ${FinalResultDir}  ${ConfigureFile}
#                                                   ${SubCaseIndex}    ${SubCaseFile}
#
#date:  04/23/2014 Created
#***************************************************************************************

runGlobalVariableInitial()
{
    HostName=`hostname`
    TestReport="${FinalResultDir}/TestReport_${TestYUVName}_SubCasesIndex_${SubCaseIndex}.report.log"
    TestSummaryFileName="${TestYUVName}_SubCasesIndex_${SubCaseIndex}.Summary.log"
    InputYUVCheck="InputYUVCheck.log"
    YUVDeleteLog="DeletedYUVList.log"
    ConfigureFile=`echo ${ConfigureFile} | awk 'BEGIN {FS="/"} {print $NF}'`
    LocalWorkingDir=""
    TestYUVFullPath=""
    CurrentDir=`pwd`
    TestResult=""
}

runGetYUVFullPath()
{
	local YUVDir=""
    let "InputFormat=0"

    YUVDir=`cat ${ConfigureFile} | grep ^TestYUVDir  | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
    vTemp=`cat ${ConfigureFile}  | grep ^InputFormat | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
    let "InputFormat=${vTemp}"

    [ ! ${InputFormat} -eq 0 ] && TestYUVFullPath=`pwd` && TestYUVFullPath=${TestYUVFullPath}/${TestYUVName} && return 0
    [ ! -d ${YUVDir} ]         && echo "YUV directory setting is not correct,${YUVDir} does not exist! "     && return 1

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

runCheckInputYUV()
{
    runGetYUVFullPath  ${TestYUVName}  ${ConfigureFile}
    if [ ! $? -eq 0 ]
    then
        echo -e "\033[31m\n can not find test yuv file ${TestYUVName}  under host ${HostName} \033[0m"
        echo -e "\033[31m     Failed!                                                         \033[0m"
        return 1
    fi

    if [ ! -s  ${TestYUVFullPath} ]
    then
        echo -e "\033[31m file size of test yuv is 0! --${TestYUVName}  under host ${HostName} \033[0m"
        echo -e "\033[31m Failed!                                                              \033[0m"
        return 1
    fi
}

runTestOneYUV()
{
    #check input YUV
    runCheckInputYUV     >${InputYUVCheck}
    let "ReturnValue=$?"
    cat ${InputYUVCheck}
    [ ! ${ReturnValue} -eq 0 ] && TestResult="Test YUV file check failed! not exist or zero size!" && return 1

    #test assigned cases
    ./run_TestAssignedCases.sh  ${LocalWorkingDir}  ${ConfigureFile}    \
                                ${TestYUVName}      ${TestYUVFullPath}  \
                                ${SubCaseIndex}     ${AssignedCasesFile}
    let "ReturnValue=$?"

    #copy test result files to final dir
    cp  -f ${LocalWorkingDir}/result/*.csv  ${FinalResultDir}

    [ ! ${ReturnValue} -eq 0 ] && TestResult="Not all cases passed!"
    return ${ReturnValue}
}

runSetLocalWorkingDir()
{
    #for both SGE data and local test, in order to decrease tho sge-master's workload,
    #need local data folder for each job/testYUV
	TempDataDir="/home"
	if [ ${TestType} = "SGETest" ]
	then
		SGEJobID=$JOB_ID
		LocalWorkingDir="${TempDataDir}/${HostName}/SGEJobID_${SGEJobID}"

		[ -d ${LocalWorkingDir} ] && ./run_SafeDelete.sh  ${LocalWorkingDir}

		mkdir -p ${LocalWorkingDir}
		cp -f ./*   ${LocalWorkingDir}
	else
        LocalWorkingDir=${CurrentDir}
    fi
}

runOutoutTestReport()
{
    SummaryFile="${LocalWorkingDir}/result/${TestSummaryFileName}"

    #basic info for this test
    echo -e "\033[34m ***************************************************************************************************** \033[0m"
    echo -e "\033[34m  Test report for YUV ${TestYUVName}              \033[0m"
    echo -e "\033[34m ***************************************************************************************************** \033[0m"
    echo -e "\033[35m   test host          is: ${HostName}             \033[0m"
    echo -e "\033[35m   test type          is: ${TestType}             \033[0m"
    echo -e "\033[35m   test directory     is: ${LocalWorkingDir}      \033[0m"
    echo -e "\033[35m   AssignedCasesFile  is: ${AssignedCasesFile}    \033[0m"
    echo -e "\033[32m   test YUV full path is: ${TestYUVFullPath}      \033[0m"
    echo -e "\033[34m ***************************************************************************************************** \033[0m"
    echo -e "\033[36m   Sub-Case Index is: ${SubCaseIndex}             \033[0m"
    echo -e "\033[36m   Host name      is: ${HostName}                 \033[0m"
    echo -e "\033[36m   SGE job ID     is: ${SGEJobID}                 \033[0m"
    echo -e "\033[36m   SGE job name   is: ${JOB_NAME}                 \033[0m"
    echo -e "\033[34m ***************************************************************************************************** \033[0m"

    #input YUV check
    [ -e ${InputYUVCheck} ] && cat ${InputYUVCheck}

    #test summary
    [ -e ${SummaryFile} ]   && cat ${SummaryFile}

    #output final result
    if [  ! ${PassedFlag} -eq 0 ]
    then
        echo -e "\033[31m Failed!  ${TestResult}             \033[0m"
        echo -e "\033[31m Not all Cases passed the test! \n\n\033[0m"
    else
        echo -e "\033[32m Succeed!                           \033[0m"
        echo -e "\033[32m All Cases passed the test!     \n\n\033[0m"
    fi
}

runMain()
{
    runGlobalVariableInitial
	runSetLocalWorkingDir

    #test assigned cases for one YUV
    cd ${LocalWorkingDir}
    runTestOneYUV
    PassedFlag=$?
    cd ${CurrentDir}

    #output to test report
    runOutoutTestReport >${TestReport}
    cat ${TestReport}

    #deleted test YUV
    runDeleteYUV >${YUVDeleteLog} 2>&1

	return ${PassedFlag}
}

runTestExample()
{
    TestType=LocalTest
    TestYUVName="horse_riding_640x512_30.yuv"
    FinalResultDir="FinalResult"
    ConfigureFile="case_for_Mac_fast_test.cfg"
    SubCaseIndex=0
    AssignedCasesFile="./case.csv"

    cp -f  ../CaseConfigure/${ConfigureFile} ${ConfigureFile}
    runMain
}

#****************************************************************************
#example test
#runTestExample
#EnableExampleTest()
#{
#****************************************************************************
#main entry
#****************************************************************************
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo "*********************************************************"
echo ""
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

runMain
#****************************************************************************
#}