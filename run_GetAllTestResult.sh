#!/bin/bash
#***************************************************************************************
# brief:
#      --test all cases of all sequences 
#      --usage:  run_GetAllTestResult.sh  ${TestType}       \
#                                         ${ConfigureFile}  \
#                                         ${AllTestResultPassFlag}
#
#
#date: 04/28/2015 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
    echo -e "\033[31m usage: ./run_GetAllTestResult.sh   \${TestType}               \033[0m"
    echo -e "\033[31m                                    \${ConfigureFile}          \033[0m"
    echo -e "\033[31m                                    \${AllTestResultPassFlag}  \033[0m"
    echo -e "\033[31m \${AllTestResultPassFlag} will be generated if all test cases passed!   \033[0m"
    echo ""
 }


runGetAllYUVTestResult()
{
    echo "">${AllTestSummary}
    for TestYUV in ${aTestYUVList[@]}
    do
        # combine sub-cases files into single all cases file
        echo ""
        echo "combining sub-set cases files into single all cases file..."
        echo ""
        DetailSummaryFile="${FinalSummaryDir}/${TestYUV}_AllCasesAllSlaves.Summary"
        SummaryFile="${FinalSummaryDir}/TestReport_${TestYUV}.log"
        SHA1TableFile="${FinalSummaryDir}/${TestYUV}_AllCases_SHA1_Table.csv"
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
        cat ${SummaryFile} >>${AllTestSummary}

      done

}

runPromptInfo()
{
    echo ""
    echo  -e "\033[32m Final result can be found in ./FinaleRestult \033[0m"
    echo  -e "\033[32m SHA1  table  can be found in ./SHA1Table \033[0m"
    echo ""
    if [ ${AllTestFlag} -eq 0  ]
    then
        echo ""
        echo -e "\033[32m ************************************************************************** \033[0m"
        echo -e "\033[32m    All test succed!    \033[0m"
        echo -e "\033[32m **************************************************************************** \033[0m"
        echo ""
    else
        echo ""
        echo -e "\033[31m ************************************************************************** \033[0m"
        echo -e "\033[31m  Not all cases passed!  \033[0m"
        echo -e "\033[31m **************************************************************************** \033[0m"
        echo ""
    fi

}

runOutputSummary()
{

	echo ""
	echo -e "\033[32m ********************************************************** \033[0m"
	echo -e "\033[32m all test summary listed as below: \033[0m"
	echo -e "\033[32m ********************************************************** \033[0m"
	echo ""
	cat ${AllTestSummary}
	echo ""
	echo -e "\033[32m ********************************************************** \033[0m"
	echo ""
}

runCheck()
{
    echo ""
    echo -e "\033[32m ********************************************************** \033[0m"
    echo -e "\033[32m     getting final test result... \033[0m"
    echo -e "\033[32m     CurrentDir is :${CurrentDir}\033[0m"
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
    if [ ! -d ${FinalSummaryDir} ]
    then
        mkdir ${FinalSummaryDir}
    fi

}

runMain()
{
    CurrentDir=`pwd`
    #get full path info
    FinalResultDir=${CurrentDir}/FinalResult
    SHA1TableDir=${CurrentDir}/SHA1Table
    FinalSummaryDir=${CurrentDir}/FinalResult_Summary
    #check input parameters
	runCheck

    AllTestSummary="${FinalSummaryDir}/AllTestYUVsSummary.txt"
    let "AllTestFlag=0"
	declare -a aTestYUVList


    #get YUV list
    aTestYUVList=(`./Scripts/run_GetTestYUVSet.sh  ${ConfigureFile}`)

	#get all test summary
	runGetAllYUVTestResult
    runOutputSummary
    runPromptInfo

    if [ -e ${AllTestResultPassFlag} ]
    then
        ./Scripts/run_SafeDelete.sh ${AllTestResultPassFlag}
    fi

    if [ ${AllTestFlag} -eq 0  ]
    then
        touch ${AllTestResultPassFlag}
    fi
    return 0

}
if [ ! $# -eq 3  ]
then
    runUsage
    exit 1
fi

TestType=$1
ConfigureFile=$2
AllTestResultPassFlag=$3
runMain
