#!/bin/bash
#***************************************************************************************
# brief:
#      --parse all completed SGE jobs' test status----passed all cases or not
#        parse based on test report file under ./FinalRsult/TestReport_*
#      --usage:  ./run_ParseSGEJobPassStatus.sh ${Option}
#
#      --e.g.:  ./run_ParseSGEJobPassStatus.sh FailedJobID
#      --e.g.:  ./run_ParseSGEJobPassStatus.sh SuccedJobID
#
#
#date: 05/012/2014 Created
#***************************************************************************************

runUsage()
{
    echo ""
    echo -e "\033[31m usage:  ./run_ParseRunningSGEJobIDsAndStatus.sh \${Option}   \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  1) get all job IDs  \033[0m"
    echo -e "\033[32m          ./run_ParseRunningSGEJobIDsAndStatus.sh JobID        \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  2) get all job status  \033[0m"
    echo -e "\033[32m          ./run_ParseRunningSGEJobIDsAndStatus.sh JobStatus    \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  3) get all job IDs  \033[0m"
    echo -e "\033[32m          ./run_ParseRunningSGEJobIDsAndStatus.sh IDAndStatus  \033[0m"
    echo ""
}

runInitial()
{
    declare -a aFailedJobIDList
    declare -a aFailedJobNameList
    declare -a aFailedJobUnpassedCasesNumList

    declare -a aSuccedJobIDList
    declare -a aSuccedJobNameList
    declare -a aSuccedJobUnpassedCasesNumList

    let "FailedJobNum=0"
    let "SuccedJobNum=0"

    CurrentDir="pwd"
    JobReportFolder="FinalResult"

    let "UnpassedCasesNum=0"
    let "PassedCasesNum=0"
    SGEJobID=""
    SGEJobName=""

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

    if [ $# -eq 1 ]
    then
        echo ""
        echo -e "\033[31m usage:  runParseStatus \${ReportFile}   \033[0m"
        echo ""
        retunr 1
    fi
    ReportFile=$1

    if [ ！-e ${ReportFile} ]
    then
        echo ""
        echo -e "\033[31m Report file ${ReportFile} does not exist!  \033[0m"
        echo ""
        return 1
    fi


    let "UnpassedCasesNum=0"
    SGEJobID=""
    SGEJobName=""
    while read line
    do
        if [[ "$line" =~ "EncoderUnPassedNum" ]]
        then
            TempString=`echo $line | awk 'BEGIN {FS=":"} {print $1}'`
            let "UnpassedCasesNum = ${TempString}"

        elif [[ "$line" =~ "EncoderPassedNum" ]]
        then
            TempString=`echo $line | awk 'BEGIN {FS=":"} {print $1}'`
            let "PassedCasesNum = ${TempString}"

        else [[ "$line" =~ "issue bitstream" ]]
        then
            # --issue bitstream can be found in  /home/ZhaoYun/SGEJobID_849/issue
            TempString=`echo $line | awk 'BEGIN {FS="/"} {print $4}'`
            TempString=`echo $TempString | awk 'BEGIN {FS="_"} {print $2}'`
            SGEJobID=${TempString}
        else [[ "$line" =~ "Test report" ]]
        then
            # Test report for YUV MSHD_320x192_12fps.yuv
            TempString=`echo $line | awk '{print $5}'`
            SGEJobName=${TempString}
        fi
    done <${ReportFile}

}

runCheckJobPassedStatus()
{

    if [ ! "${UnpassedCasesNum}" -eq 0 ]
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
            runParseStatus ${file}
            runCheckJobPassedStatus
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
    fi
}

runOptionValidateCheck()
{
    declare -a aOptionList
    aOptionList=()
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


