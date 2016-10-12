#!/bin/bash
#***************************************************************************************
# brief:
#      --combine subcase files into single files for all test cases
#      --usage:  run_SubCasesToAllCasesSummary.sh ${YUVName} ${SummaryFile}
#
#date: 04/28/2015 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
    echo -e "\033[31m usage:  ./run_SubCasesToAllCasesSummary.sh \${YUVName}     \033[0m"
    echo -e "\033[31m                                            \${SummaryFile} \033[0m"
    echo -e "\033[31m                                            \${OutputFile}  \033[0m"
    echo ""
 }

runSummarizeAllTestResult()
{
    TempString=""

    while read line
    do
        TempNum=`echo $line | awk 'BEGIN {FS=":"} {print $2}'`
        TempNum=`echo $TempNum | awk ' BEGIN {FS="\033"} {print $1}'`


        if [[ ${line} =~ "total" ]]
        then
            let " TotalNum += ${TempNum} "
        elif [[ ${line} =~ "EncoderPassedNum" ]]
        then
            let " EncoderPassedNum += ${TempNum} "
        elif [[ ${line} =~ "EncoderUnPassedNum" ]]
        then
            let " EncoderUnPassedNum += ${TempNum} "
        elif [[ ${line} =~ "DecoderPassedNum" ]]
        then
            let " DecoderPassedNum += ${TempNum} "
        elif [[ ${line} =~ "DecoderUpPassedNum" ]]
        then
            let " DecoderUpPassedNum += ${TempNum} "
        elif [[ ${line} =~ "DecoderUnCheckNum" ]]
        then
            let " DecoderUnCheckNum += ${TempNum} "
        fi
    done < ${SummaryFile}

}

runOutputTestSummary()
{


    echo -e "\033[34m **********************************************************************   \033[0m"
    echo -e "\033[32m *        Test report of all cases for YUV ${YUVName}    \033[0m"
    echo -e "\033[34m **********************************************************************   \033[0m"
    if [ ! ${EncoderUnPassedNum} -eq 0 -o ${TotalNum} -eq 0 ]
    then
        echo -e "\033[31m   Not all Cases passed the test!   \033[0m"
        echo -e "\033[31m     Failed!   \033[0m"
        let "TestFlag=1"
    else
        echo -e "\033[32m   All Cases passed the test!   \033[0m"
        echo -e "\033[32m     Succeed!   \033[0m"
        let "TestFlag=0"
    fi

    echo -e "\033[32m total case  Num     is : ${TotalNum}            \033[0m"
    echo -e "\033[32m EncoderPassedNum    is : ${EncoderPassedNum}    \033[0m"
    echo -e "\033[31m EncoderUnPassedNum  is : ${EncoderUnPassedNum}  \033[0m"
    echo -e "\033[32m DecoderPassedNum    is : ${DecoderPassedNum}    \033[0m"
    echo -e "\033[31m DecoderUpPassedNum  is : ${DecoderUpPassedNum}  \033[0m"
    echo -e "\033[31m DecoderUnCheckNum   is : ${DecoderUnCheckNum}   \033[0m"
    echo -e "\033[34m **********************************************************************   \033[0m"
    echo -e "\033[34m **********************************************************************   \033[0m"

}
runOutputDetailResult()
{
    echo ""
    echo ""
    echo -e "\033[32m **********************************************************************   \033[0m"
    echo -e "\033[32m *     Test report below for sub-cases set of YUV ${YUVName}              \033[0m"
    echo -e "\033[32m **********************************************************************   \033[0m"
    cat  ${SummaryFile}
    echo -e "\033[32m **********************************************************************   \033[0m"
    echo -e "\033[32m **********************************************************************   \033[0m"
    echo -e "\033[32m **********************************************************************   \033[0m"

}

runCheck()
{
    if [ ! -e ${SummaryFile} ]
    then
        echo -e "\033[31m File ${SummaryFile} does not exist,please double check! \033[0m"
        exit 1
    fi
}

runMain()
{
    if [ ! $# -eq 3 ]
	then
		runUsage
		exit 1
	fi

    YUVName=$1
    SummaryFile=$2
    OutputFile=$3

    let "TestFlag=0"

    let "TotalNum = 0"
    let "EncoderPassedNum =0"
    let "EncoderUnPassedNum = 0"
    let "DecoderPassedNum =0"
    let "DecoderUpPassedNum = 0"
    let "DecoderUnCheckNum =0"
    TempFile=${YUVName}_OverallSummary.log

    echo  -e "\033[34m ********************************************************** \033[0m"
    echo  -e "\033[34m        Test summary for all sub-cases of ${YUVName}        \033[0m"
    echo  -e "\033[34m ********************************************************** \033[0m"

    runCheck

    runSummarizeAllTestResult
    runOutputTestSummary   >${TempFile}
    runOutputDetailResult  >>${TempFile}
    runOutputTestSummary   >${OutputFile}

    echo  -e "\033[34m ********************************************************** \033[0m"
    echo  -e "\033[34m        Completed test summary for ${YUVName}               \033[0m"
    echo  -e "\033[34m        summary is ${OutputFile}                            \033[0m"
    echo  -e "\033[34m ********************************************************** \033[0m"


    #deleted temp file
    #./Scripts/run_SafeDelete.sh ${SummaryFile}
    #mv ${TempFile}  ${SummaryFile}


    return ${TestFlag}
}
#*********************************************************************************************************
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo "*********************************************************"
echo
YUVName=$1
SummaryFile=$2
OutputFile=$3
runMain  ${YUVName} ${SummaryFile} ${OutputFile}
#*********************************************************************************************************

