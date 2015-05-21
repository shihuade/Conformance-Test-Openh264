#!/bin/bash
#***************************************************************************************
# brief:
#      --parse all completed SGE jobs' test status----passed all cases or not
#        parse based on test report file under ./FinalRsult/TestReport_*
#      --usage:  ./run_ParseSGEJobPassStatus.sh ${Option}
#
#      --e.g.:  ./run_ParseSGEJobPassStatus.sh FailedJobID
#      --e.g.:  ./run_ParseSGEJobPassStatus.sh FailedJobName
#      --e.g.:  ./run_ParseSGEJobPassStatus.sh FailedJobUnpassedNum
#      --e.g.:  ./run_ParseSGEJobPassStatus.sh SuccedJobID
#      --e.g.:  ./run_ParseSGEJobPassStatus.sh SuccedJobName
#      --e.g.:  ./run_ParseSGEJobPassStatus.sh SuccedJobUnpassedNum
#      --e.g.:  ./run_ParseSGEJobPassStatus.sh UnRunCaseJobID
#      --e.g.:  ./run_ParseSGEJobPassStatus.sh UnRunCaseJobName
#
#date: 05/012/2014 Created
#***************************************************************************************

runUsage()
{
    echo ""
    echo -e "\033[31m usage:  ./run_ParseSGEJobPassStatus.sh \${Option}              \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  1) get failed jobs' ID list                             \033[0m"
    echo -e "\033[32m          ./run_ParseSGEJobPassStatus.sh FailedJobID            \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  2) get failed jobs' name list                           \033[0m"
    echo -e "\033[32m          ./run_ParseSGEJobPassStatus.sh FailedJobName          \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  3) get failed jobs' un-passed cases num                 \033[0m"
    echo -e "\033[32m          ./run_ParseSGEJobPassStatus.sh FailedJobUnpassedNum   \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  4) get succed jobs' ID list                             \033[0m"
    echo -e "\033[32m          ./run_ParseSGEJobPassStatus.sh SuccedJobID            \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  5) get succed jobs' name list                           \033[0m"
    echo -e "\033[32m          ./run_ParseSGEJobPassStatus.sh SuccedJobName          \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  6) get succed jobs' passed cases num                    \033[0m"
    echo -e "\033[32m          ./run_ParseSGEJobPassStatus.sh SuccedJobPassedNum     \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  4) get un-run case jobs' ID list(e.g.:YUV not found)    \033[0m"
    echo -e "\033[32m          ./run_ParseSGEJobPassStatus.sh UnRunCaseJobID         \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  5) get un-run case jobs' name list(e.g.:YUV not found)  \033[0m"
    echo -e "\033[32m          ./run_ParseSGEJobPassStatus.sh UnRunCaseJobName       \033[0m"
    echo ""


}

runInitial()
{
    declare -a aFailedJobIDList
    declare -a aFailedJobNameList
    declare -a aFailedJobUnpassedCasesNumList

    declare -a aUnRunCaseJobIDList
    declare -a aUnRunCaseJobNameList

    declare -a aSuccedJobIDList
    declare -a aSuccedJobNameList
    declare -a aSuccedJobUnpassedCasesNumList

    let "FailedJobNum=0"
    let "SuccedJobNum=0"
    let "UnRunCaseJobNum=0"

    CurrentDir=`pwd`
    JobReportFolder="FinalResult"

    let "UnpassedCasesNum=0"
    let "PassedCasesNum=0"
    SGEJobID=""
    SGEJobName=""

    let "JobCompletedFlag=0"
    let "UnrunCasesFlag=0"

}

runCheck()
{
    if [ -d ${JobReportFolder} ]
    then
        cd ${JobReportFolder}
        JobReportFolder=`pwd`
        cd ${CurrentDir}
    else
        echo ""
        echo -e "\033[31m Final result folder for report does not exist,please double check   \033[0m"
        echo ""
        exit 1
    fi

    return 0
}

#report file template list as below:
#  **********************************************************************
#  Test report for YUV MSHD_320x192_12fps.yuv
#
#  Succeed!
#  All Cases passed the test!
#  ..................Test summary for MSHD_320x192_12fps.yuv....................
#  TestStartTime is Sun May 10 23:47:01 EDT 2015
#  TestEndTime   is Mon May 11 01:53:41 EDT 2015
#  total case  Num     is : 2000
#  EncoderPassedNum    is : 2000
#  EncoderUnPassedNum  is : 0
#  DecoderPassedNum    is : 2000
#  DecoderUpPassedNum  is : 0
#  DecoderUnCheckNum   is : 0
#
#  --issue bitstream can be found in  /home/ZhaoYun/SGEJobID_849/issue
#  --detail result  can be found in   /home/ZhaoYun/SGEJobID_849/result
#  report file: /opt/sge62u2_1/SGE_room2/OpenH264ConformanceTest/NewSGE-SVC-Test/FinalResult/
#  **********************************************************************

runParseStatus()
{

    if [ ! $# -eq 1 ]
    then
        echo ""
        echo -e "\033[31m usage:  runParseStatus \${ReportFile}   \033[0m"
        echo ""
        return 1
    fi

    ReportFile=$1

    if [ ! -e ${ReportFile} ]
    then
        echo ""
        echo -e "\033[31m Report file ${ReportFile} does not exist!  \033[0m"
        echo ""
        return 1
    fi


    let "UnpassedCasesNum=0"
    let "PassedCasesNum=0"
    let "JobCompletedFlag=0"
    let "UnrunCasesFlag=0"

    SGEJobID=""
    SGEJobName=""

    while read line
    do
        if [[ "$line" =~ "EncoderUnPassedNum" ]]
        then
            TempString=`echo $line | awk 'BEGIN {FS=":"} {print $2}'`
            TempString=`echo $TempString | awk  ' {print $1}'`
            #echo "TempString is ${TempString}"
            let "UnpassedCasesNum = ${TempString}"

            let "JobCompletedFlag=1"

        elif [[ "$line" =~ "EncoderPassedNum" ]]
        then
            TempString=`echo $line | awk 'BEGIN {FS=":"} {print $2}'`
            TempString=`echo $TempString | awk '{print $1}'`
            let "PassedCasesNum = ${TempString}"

        elif [[ "$line" =~ "SGEJobID" ]]
        then
            # SGEJobID   is: 533
            TempString=`echo $line | awk 'BEGIN {FS=":"} {print $2}'`
            TempString=`echo $TempString | awk '{print $1}'`
            SGEJobID=${TempString}
        elif [[ "$line" =~ "SGEJobName" ]]
        then
            # SGEJobName is: MSHD_320x192_12fps.yuv_SubCasedIndex_1
            TempString=`echo $line | awk 'BEGIN {FS=":"} {print $2}'`
            TempString=`echo $TempString | awk '{print $1}'`
            SGEJobName=${TempString}
        elif [[ "$line" =~ "issue bitstream" ]]
        then
            # --issue bitstream can be found in  /home/ZhaoYun/SGEJobID_849/issue
            TempString=`echo $line | awk 'BEGIN {FS="/"} {print $4}'`
            TempString=`echo $TempString | awk 'BEGIN {FS="_"} {print $2}'`
            SGEJobID=${TempString}
        elif [[ "$line" =~ "Test report" ]]
        then
            # Test report for YUV MSHD_320x192_12fps.yuv
            TempString=`echo $line | awk '{print $6}'`
            SGEJobName=${TempString}
        elif [[ "$line" =~ "can not find test yuv" ]]
        then
            # can not find test yuv
            let "JobCompletedFlag=1"
            let "UnrunCasesFlag=1"

        fi

    done <${ReportFile}

}

runUpdateJobPassedStatus()
{

    if [  "${UnrunCasesFlag}" -eq 1 ]
    then
        aUnRunCaseJobIDList[${FailedJobNum}]=${SGEJobID}
        aUnRunCaseJobNameList[${FailedJobNum}]=${SGEJobName}
        let "UnRunCaseJobNum ++"

    else [ ! "${UnpassedCasesNum}" -eq 0 ]
    then
        aFailedJobIDList[${FailedJobNum}]=${SGEJobID}
        aFailedJobNameList[${FailedJobNum}]=${SGEJobName}
        aFailedJobUnpassedCasesNumList[${FailedJobNum}]=${UnpassedCasesNum}
        let "FailedJobNum ++"
    else
        aSuccedJobIDList[${SuccedJobNum}]=${SGEJobID}
        aSuccedJobNameList[${SuccedJobNum}]=${SGEJobName}
        aSuccedJobUnpassedCasesNumList[${SuccedJobNum}]=${PassedCasesNum}
        let "SuccedJobNum ++"
    fi

}

runParseAllReportFile()
{

    for file in ${JobReportFolder}/TestReport_*
    do
        if [ -e "${file}" ]
        then
            #echo "file is ${file}"
            runParseStatus ${file}

            if [ ${JobCompletedFlag} -eq 1 ]
            then
                runUpdateJobPassedStatus
            fi
        fi
    done

}

runOutputParseResult()
{
    if [ "${Option}" = "FailedJobID"  ]
    then
        echo ${aFailedJobIDList[@]}
    elif [ "${Option}" = "FailedJobName" ]
    then
        echo ${aFailedJobNameList[@]}
    elif [ "${Option}" = "FailedJobUnPassedNum" ]
    then
        echo ${aFailedJobUnpassedCasesNumList[@]}
    elif [ "${Option}" = "SuccedJobID" ]
    then
        echo ${aSuccedJobIDList[@]}
    elif [ "${Option}" = "SuccedJobName" ]
    then
        echo ${aSuccedJobNameList[@]}
    elif [ "${Option}" = "SuccedJobPassedNum" ]
    then
        echo ${aSuccedJobUnpassedCasesNumList[@]}
    elif [ "${Option}" = "UnRunCaseJobID" ]
    then
        echo ${aUnRunCaseJobIDList[@]}
    elif [ "${Option}" = "UnRunCaseJobName" ]
    then
        echo ${aUnRunCaseJobNameList[@]}
    fi
}

runOptionValidateCheck()
{
    declare -a aOptionList
    aOptionList=(FailedJobID FailedJobName FailedJobUnpassedNum SuccedJobID SuccedJobName SuccedJobPassedNum)
    let "Flag=1"

    for InputOption in ${aOptionList[@]}
    do
        if [ "${Option}" = "${InputOption}"  ]
        then
            let "Flag=0"
        fi
    done

    if [ ! ${Flag} -eq 0 ]
    then
        runUsage
        exit 1
    fi

}
runMain()
{
    runOptionValidateCheck
    runInitial
    runCheck

    runParseAllReportFile
    runOutputParseResult
}

Option=$1
runMain


