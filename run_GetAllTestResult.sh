#!/bin/bash
#***************************************************************************************
# brief:
#      --test all cases of all sequences 
#      --usage:  run_GetAllTestResult.sh  ${TestType}       \
#                                         ${ConfigureFile}  \
#                                         ${AllTestResultPassFlagFile}
#
#
#date: 04/28/2015 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
    echo -e "\033[31m usage: ./run_GetAllTestResult.sh   \${TestType}                   \033[0m"
    echo -e "\033[31m                                    \${ConfigureFile}              \033[0m"
    echo -e "\033[31m                                    \${AllTestResultPassFlagFile}  \033[0m"
    echo -e "\033[31m \${AllTestResultPassFlagFile} will be generated if all test cases passed!   \033[0m"
    echo ""
 }


runGetAllYUVTestResult()
{
    echo "">${AllTestSummary}
    echo "">${AllYUVAllSlavesTestReort}
    echo "YUV list based cfg file ${ConfigureFile} is:"
    echo "  ${aTestYUVList[@]}"
    for TestYUV in ${aTestYUVList[@]}
    do
        # combine sub-cases files into single all cases file
        echo ""
        echo "combining sub-set cases files into single all cases file..."
        echo ""
        DetailSummaryFile="${FinalTestReportDir}/${TestYUV}_AllCasesAllSlaves.Summary.log"
        SummaryFile="${FinalTestReportDir}/TestReport_${TestYUV}.log"
        SHA1TableFile="${FinalTestReportDir}/${TestYUV}_AllCases_SHA1_Table.csv"
        ./Scripts/run_SubCasesToAllCasesCombination.sh  ${FinalResultDir} ${TestYUV} 0
        ./Scripts/run_SubCasesToAllCasesCombination.sh  ${FinalResultDir} ${TestYUV} 1
        ./Scripts/run_SubCasesToAllCasesCombination.sh  ${FinalResultDir} ${TestYUV} 2
        ./Scripts/run_SubCasesToAllCasesCombination.sh  ${FinalResultDir} ${TestYUV} 3
        ./Scripts/run_SubCasesToAllCasesSummary.sh ${TestYUV} ${DetailSummaryFile} ${SummaryFile}

        if [ ! $? -eq 0 ]
        then
            let "AllTestFlag=1"
        fi

        cp -f ${SHA1TableFile} ${SHA1TableDir}

        #print test sequence's test summary
        cat ${SummaryFile}       >>${AllTestSummary}
        cat ${DetailSummaryFile} >>${AllYUVAllSlavesTestReort}
    done

}

runPromptInfo()
{
    if [ ${AllTestFlag} -eq 0  ]
    then
        echo ""
        echo -e "\033[34m ************************************************************************** \033[0m"
        echo -e "\033[34m      Finale test result:  All test succed!       \033[0m"
        echo -e "\033[34m **************************************************************************** \033[0m"
        echo ""
    else
        echo ""
        echo -e "\033[31m ************************************************************************** \033[0m"
        echo -e "\033[31m      Finale test result:  Not all cases passed!  \033[0m"
        echo -e "\033[31m **************************************************************************** \033[0m"
        echo ""
    fi
    echo -e "\033[34m **************************************************************************** \033[0m"
    echo  -e "\033[32m        Summary result can be found in ./FinalTestReport                     \033[0m"
    echo  -e "\033[32m        All result can be found     in ./FinaleRestult                       \033[0m"
    echo  -e "\033[32m        SHA1  table  can be found   in ./SHA1Table                           \033[0m"
    echo -e "\033[34m **************************************************************************** \033[0m"

}

runOutputSummary()
{

	echo ""
	echo -e "\033[32m ********************************************************** \033[0m"
	echo -e "\033[32m All test sequences under all test slaves test report:      \033[0m"
	echo -e "\033[32m ********************************************************** \033[0m"
	echo ""
    cat ${AllYUVAllSlavesTestReort}
    echo ""
    echo -e "\033[32m ********************************************************** \033[0m"
    echo -e "\033[32m All test sequences' summary listed as below:               \033[0m"
    echo -e "\033[32m ********************************************************** \033[0m"
	cat ${AllTestSummary}
	echo ""
	echo -e "\033[32m ********************************************************** \033[0m"
	echo ""
}

runRenameSHA1TableForTravis()
{
    echo ""
    echo -e "\033[32m ********************************************************** \033[0m"
    echo -e "\033[32m rename SHA1 table file for travis test \033[0m"
    echo
    for file in ${SHA1TableDir}/*.csv
    do
        vTempFileName=`echo $file | awk 'BEGIN {FS="/"} {print $NF}'`
        vBitStreamName=`echo $vTempFileName | awk 'BEGIN {FS=".264"} {print $1 }'`
        vBitStreamName="${vBitStreamName}.264"
        vRename="${SHA1TableDir}/${vBitStreamName}_AllCases_SHA1_Table.csv"

        mv ${file}  ${vRename}
        echo -e "\033[32m vBitStreamName is ${vBitStreamName}                    \033[0m"
        echo -e "\033[32m file ${file} has been renamed to ${vRename}            \033[0m"
    done

    echo ""
    echo -e "\033[32m ********************************************************** \033[0m"
    echo ""


}

runRenameSHA1TableFile()
{
    while read line
    do
        if [[ "$line" =~ ^InputFormat  ]]
        then
            TempString=`echo $line | awk 'BEGINE {FS=":"} {print $2}' `
            TempString=`echo $TempString | awk 'BEGIN {FS="#"} {print $1}' `
            let "InputFileFormat= ${TempString}"
        fi

    done <${ConfigureFile}

    if [ ${InputFileFormat} -eq 1 ]
    then
        runRenameSHA1TableForTravis
    fi
}

runCheck()
{
    echo ""
    echo -e "\033[32m ********************************************************** \033[0m"
    echo -e "\033[32m     getting final test result... \033[0m"
    echo -e "\033[32m     CurrentDir is :${CurrentDir} \033[0m"
    echo -e "\033[32m ********************************************************** \033[0m"
    echo ""
    if [ ! -d ${FinalResultDir} ]
    then
        echo ""
        echo -e "\033[31m ${FinalResultDir} does does not exist, please double check! \033[0m"
        echo ""
        exit 1

    fi
    if [ ! -d ${SHA1TableDir} ]
    then
        echo ""
        echo -e "\033[31m ${SHA1TableDir} does does not exist, please double check! \033[0m"
        echo ""
        exit 1
    fi

    if [ ! -d ${FinalTestReportDir} ]
    then
        mkdir ${FinalTestReportDir}
    fi

}

runMain()
{
    CurrentDir=`pwd`
    #get full path info
    FinalResultDir=${CurrentDir}/FinalResult
    SHA1TableDir=${CurrentDir}/SHA1Table
    FinalTestReportDir=${CurrentDir}/FinalTestReport
    #check input parameters
	runCheck

    #Summary report for all test sequences
    AllTestSummary="${FinalTestReportDir}/AllTestYUVsSummary.txt"
    AllTestResultCombineConsole="${FinalTestReportDir}/AllTestResultCombineConsole.txt"
    #Detail report file for all test sequences under all slaves test report
    AllYUVAllSlavesTestReort="${FinalTestReportDir}/AllTestYUVsAllSlavesDetailTestReport.txt"
    let "AllTestFlag=0"
	declare -a aTestYUVList

    #get YUV list
    aTestYUVList=(`./Scripts/run_GetTestYUVSet.sh  ${ConfigureFile}`)

	#get all test summary
    runGetAllYUVTestResult  >${AllTestResultCombineConsole}

    runRenameSHA1TableFile

    runOutputSummary
    runPromptInfo

    if [ -e ${AllTestResultPassFlagFile} ]
    then
        ./Scripts/run_SafeDelete.sh ${AllTestResultPassFlagFile}
    fi

    if [ ${AllTestFlag} -eq 0  ]
    then
        touch ${AllTestResultPassFlagFile}
    fi

    return ${AllTestFlag}

}
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters is:"
echo "        $0 $@"
echo "*********************************************************"
echo ""


if [ ! $# -eq 3  ]
then
    runUsage
    exit 1
fi

TestType=$1
ConfigureFile=$2
AllTestResultPassFlagFile=$3
runMain


