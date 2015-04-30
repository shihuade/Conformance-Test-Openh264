#!/bin/bash
#***************************************************************************************
# brief:
#      --test all cases of all sequences 
#      --usage:  run_GetAllTestResult.sh  ${TestType}     \
#                                         ${ConfigureFile}
#
#
#date: 04/28/2015 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
    echo -e "\033[31m usage: ./run_GetAllTestResult.sh   \${TestType}       \033[0m"
    echo -e "\033[31m                                    \${ConfigureFile}  \033[0m"
    echo ""
 }


runGetAllYUVTestResult()
{
    echo "">${AllTestSummary}
    echo "">${AllSGESlaveInfoFile}
    for TestYUV in ${aTestYUVList[@]}
    do
        # combine sub-cases files into single all cases file
        echo ""
        echo "combining sub-set cases files into single all cases file..."
        echo ""
        DetailSummaryFile="${FinalResultDir}/${TestYUV}_AllCasesAllSlaves.Summary"
        SummaryFile="${FinalResultDir}/TestReport_${TestYUV}.log"
        SHA1TableFile="${FinalResultDir}/${TestYUV}_AllCases_SHA1_Table.csv"
        ./Scripts/run_SubCasesToAllCasesCombination.sh  ${FinalResultDir} ${TestYUV} 0
        ./Scripts/run_SubCasesToAllCasesCombination.sh  ${FinalResultDir} ${TestYUV} 1
        ./Scripts/run_SubCasesToAllCasesCombination.sh  ${FinalResultDir} ${TestYUV} 2
        ./Scripts/run_SubCasesToAllCasesCombination.sh  ${FinalResultDir} ${TestYUV} 3

        echo "SummaryFile info after summary...."
cat ${DetailSummaryFile}
echo ""
echo ""
        ./Scripts/run_SubCasesToAllCasesSummary.sh ${TestYUV} ${DetailSummaryFile} ${SummaryFile}

        if [ ! $? -eq 0 ]
        then
            let "AllTestFlag=1"
        fi

        cp -f ${SHA1TableFile} ${SHA1TableDir}

        #print test sequence's test summary
        cat ${SummaryFile} >>${AllTestSummary}

        if [ ${TestType} = "SGTest" ]
        then
            SGESlaveInfoFile="${FinalResultDir}/${TestYUV}_SGESlaveInfo.log"
            ./Scripts/run_SubCasesToAllCasesCombination.sh ${FinalResultDir} ${TestYUV} \
                                                           ${SGESlaveInfoFile}
            #print test sequence's slave info
            cat ${SGESlaveInfoFile} >>${AllSGESlaveInfoFile}
        fi

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
}

runMain()
{
	if [ ! $# -eq 2  ]
	then
		runUsage
		exit 1
	fi
	
	TestType=$1
	ConfigureFile=$2
	FinalResultDir=FinalResult
    SHA1TableDir=SHA1Table
	CurrentDir=`pwd`
	#check input parameters
	runCheck

    AllTestSummary="${FinalResultDir}/AllTestYUVsSummary.txt"
    AllSGESlaveInfoFile="${FinalResultDir}/AllTestYUVsSGESlaveInfo.txt"
    let "AllTestFlag=0"
	declare -a aTestYUVList


	#get full path info
	cd ${FinalResultDir}
	FinalResultDir=`pwd`
	cd  ${CurrentDir}
    cd ${SHA1TableDir}
    SHA1TableDir=`pwd`
    cd ${CurrentDir}
    #get YUV list
    aTestYUVList=(`./Scripts/run_GetTestYUVSet.sh  ${ConfigureFile}`)

	#get all test summary
	runGetAllYUVTestResult
    runOutputSummary
    runPromptInfo
    return ${AllTestFlag}

}
TestType=$1
ConfigureFile=$2
runMain  ${TestType} ${ConfigureFile}

