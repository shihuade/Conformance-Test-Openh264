#!/bin/bash
#***************************************************************************************
# brief:
#      --resubmit SGE jobs
#      --usage:  ./run_SGEJobReSubmit.sh  ${Option}
#
#      --e.g:
#            1) resubmit all jobs
#                   ./run_SGEJobReSubmit.sh  All
#
#            2) resubmit all releated jobs of given YUVs
#                   ./run_SGEJobReSubmit.sh  YUV  01.yuv 02.yuv
#
#            2) resubmit given Job IDs
#                   ./run_SGEJobReSubmit.sh  JobID  123  124  126
#
#
#
#date: 6/09/2015 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
	echo -e "\033[32m usage:  ./run_SGEJobReSubmit.sh  \${Option}             \033[0m"
    echo ""
    echo -e "\033[32m   --e.g:                                                \033[0m"
    echo -e "\033[32m        1) resubmit all jobs                             \033[0m"
    echo -e "\033[32m           ./run_SGEJobReSubmit.sh  All                  \033[0m"
    echo ""
    echo -e "\033[32m        2) resubmit all releated jobs of given YUVs      \033[0m"
    echo -e "\033[32m           ./run_SGEJobReSubmit.sh  YUV  01.yuv 02.yuv   \033[0m"
    echo ""
    echo -e "\033[32m        3) resubmit given Job IDs                        \033[0m"
    echo -e "\033[32m          ./run_SGEJobReSubmit.sh  JobID  123  124  126  \033[0m"
    echo ""
}

runInit()
{
    declare -a aSubmittedSGEJobIDList
    declare -a aSubmittedSGEJobNameList
    declare -a aSubmittedSGEJobInfoList
    declare -a aReSubmittedYUVList

    declare -a aReSubmittedSGEJobFileList
    declare -a aReSubmittedSGEJobOutFileList
    declare -a aReSubmittedSGEJobFlagFileList
    declare -a aReSubmittedSGEJobErrorInfoFileList

    declare -a aReSubmittedSGEJobSHA1List
    declare -a aReSubmittedSGEJobAllCasesFileList
    declare -a aReSubmittedSGEJobErrorCasesFileList
    declare -a aReSubmittedSGEJobTestReportFileList

    declare -a aResubmitSGEJobIDList
    declare -a aResubmitSGEJobNameList
    declare -a aResubmitSGEJobInfoList

    declare -a aUpdateLogFlagList

    let "ReSubmittedJobNum = 0"

    CurrentDir=`pwd`
    TestSpace=${CurrentDir}/AllTestData
    TestResultDir=${CurrentDir}/FinalResult
    SGEJobSubmitJobLog="${CurrentDir}/SGEJobsSubmittedInfo.log"


    date
    DateInfo=`date`
    DateInfo=`echo ${DateInfo} | awk '{for(i=1;i<=NF;i++) printf("--%s",$i)}'`
    BackupSGEJobSubmitJobLog=${SGEJobSubmitJobLog}-${DateInfo}.log
    ReSubmitLog="${CurrentDir}/ReSubmitInfo_Date-${DateInfo}.log"
}

#*******************************************************************************
#      job submitted info in log looks like as below
# ******************************************************************************
# ******************************************************************************
# test YUV is Doc_Complex_768x1024.yuv
# ******************************************************************************
# Your job 2607 ("----Doc_Complex_768x1024.yuv_SubCaseIndex_0----") has been submitted
# Your job 2608 ("----Doc_Complex_768x1024.yuv_SubCaseIndex_10----") has been submitted
# Your job 2609 ("----Doc_Complex_768x1024.yuv_SubCaseIndex_11----") has been submitted
#  ......
runGetSubmittedJobInfoByIDs()
{
#aSubmittedSGEJobIDList=(2590 2608  2612)

    let "ReSubmittedJobNum = ${#aSubmittedSGEJobIDList[@]}"
    for((i=0;i<${ReSubmittedJobNum};i++))
    do
        aSubmittedSGEJobNameList[$i]=NULL
    done

    while read line
    do
        if [[ "$line" =~ ^"Your job" ]]
        then
            TempJobID=`echo $line | awk '{print $3}'`
            TempJobName=`echo $line | awk 'BEGIN {FS="----"} {print $2}'`

            for((i=0;i<${ReSubmittedJobNum};i++))
            do
                vSubmmitedJobID=${aSubmittedSGEJobIDList[$i]}
                if [ "${vSubmmitedJobID}" -eq "${TempJobID}" ]
                then
                    aSubmittedSGEJobNameList[$i]=${TempJobName}
                    aSubmittedSGEJobInfoList[$i]=${line}
                fi
            done
        fi

    done <${SGEJobSubmitJobLog}

    echo "aSubmittedSGEJobNameList is ${aSubmittedSGEJobNameList[@]}"
}

runGetSubmittedJobInfoByYUVs()
{
#aReSubmittedYUVList=(Doc_Complex_768x1024.yuv )

    let "NumYUV=${#aReSubmittedYUVList[@]}"
    let "ReSubmittedJobNum=0"
    while read line
    do
        if [[ "$line" =~ ^"Your job" ]]
        then
            TempJobID=`echo $line | awk '{print $3}'`
            TempJobName=`echo $line | awk 'BEGIN {FS="----"} {print $2}'`

            for((i=0;i<${NumYUV};i++))
            do
                vReSubmmitedYUV=${aReSubmittedYUVList[$i]}
                if [[ "${TempJobName}" =~ "${vReSubmmitedYUV}" ]]
                then
                    aSubmittedSGEJobIDList[$ReSubmittedJobNum]=${TempJobID}
                    aSubmittedSGEJobNameList[$ReSubmittedJobNum]=${TempJobName}
                    aSubmittedSGEJobInfoList[$i]=${line}
                    let "ReSubmittedJobNum ++"
                fi
            done
        fi

    done <${SGEJobSubmitJobLog}

}

runGetSubmittedJobInfoByAllJobs()
{

    let "ReSubmittedJobNum=0"
    let "ExampleLineFlag=0"
    while read line
    do
        if [[ "$line" =~ ^"Your job" ]]
        then
            if [ ${ExampleLineFlag} -eq 0 ]
            then
                let "ExampleLineFlag = 1"
            else
                TempJobID=`echo $line | awk '{print $3}'`
                TempJobName=`echo $line | awk 'BEGIN {FS="----"} {print $2}'`

                aSubmittedSGEJobIDList[$ReSubmittedJobNum]=${TempJobID}
                aSubmittedSGEJobNameList[$ReSubmittedJobNum]=${TempJobName}
                aSubmittedSGEJobInfoList[$i]=${line}
                let "ReSubmittedJobNum ++"
            fi
        fi

    done <${SGEJobSubmitJobLog}

 	return 0
}

runOutputReSubmittedJobInfo()
{
    echo -e "\033[32m ******************************************************************************  \033[0m"
    echo                   ReSubmitted Job info listed as below:
    echo -e "\033[32m ******************************************************************************  \033[0m"

    for((i=0;i<${ReSubmittedJobNum};i++))
    do
        echo -e "\033[32m ${aSubmittedSGEJobIDList[$i]}:  ${aSubmittedSGEJobNameList[$i]}             \033[0m"
        echo -e "\033[32m      sge job submitted info  :  ${aSubmittedSGEJobInfoList[$i]}           \033[0m"
        echo -e "\033[32m      sge job file            :  ${aReSubmittedSGEJobFileList[$i]}           \033[0m"
        echo -e "\033[32m      job output file         :  ${aReSubmittedSGEJobOutFileList[$i]}        \033[0m"
        echo -e "\033[32m      job error info  file    :  ${aReSubmittedSGEJobErrorInfoFileList[$i]}  \033[0m"
        echo -e "\033[32m      job submitted flag file :  ${aReSubmittedSGEJobFlagFileList[$i]}       \033[0m"
        echo ""
        echo -e "\033[32m      result-SHA1 file        :  ${aReSubmittedSGEJobSHA1List[$i]}           \033[0m"
        echo -e "\033[32m      result-All cases file   :  ${aReSubmittedSGEJobAllCasesFileList[$i]}   \033[0m"
        echo -e "\033[32m      result-Failed cases file:  ${aReSubmittedSGEJobErrorCasesFileList[$i]}  \033[0m"
        echo -e "\033[32m      result-Test report file :  ${aReSubmittedSGEJobTestReportFileList[$i]} \033[0m"
    done
    echo -e "\033[32m ******************************************************************************  \033[0m"

}

runGetReSubmittedSGEJobFile()
{

    for((i=0;i<${ReSubmittedJobNum};i++))
    do
        aReSubmittedSGEJobFileList[$i]=NULL
        aReSubmittedSGEJobOutFileList[$i]=NULL
        aReSubmittedSGEJobErrorInfoFileList[$i]=NULL
        aReSubmittedSGEJobFlagFileList[$i]=NULL

    done

    for file in ${TestSpace}/*/*.sge*
    do

        TempFileName=`echo $file | awk 'BEGIN {FS="/"} {print $NF}'`
        vMatchedPattern=`echo $TempFileName | awk 'BEGIN {FS=".sge"} {print $1}'`

        for((i=0;i<${ReSubmittedJobNum};i++))
        do
            if [[ "${aSubmittedSGEJobNameList[$i]}" =~ "${vMatchedPattern}" ]]
            then
                if [[ "${file}" =~ .sge$ ]]
                then
                    aReSubmittedSGEJobFileList[$i]=${file}
                fi

                if [[ "${file}" =~ .sge.o$ ]]
                then
                    aReSubmittedSGEJobOutFileList[$i]=${file}
                fi

                if [[ "${file}" =~ .sge.e$ ]]
                then
                    aReSubmittedSGEJobErrorInfoFileList[$i]=${file}
                fi

                if [[ "${file}" =~ .sge_Submitted.flag$ ]]
                then
                    aReSubmittedSGEJobFlagFileList[$i]=${file}
                fi

            fi
        done

    done

}
#***************************************************************
#   job test result files listed as below
#***************************************************************
# CREW_352x288_30.yuv_AllCasesOutput_SubCasesIndex_0.csv
# CREW_352x288_30.yuv_AllCases_SHA1_Table_SubCasesIndex_0.csv
# CREW_352x288_30.yuv_UnpassedCasesOutput_SubCasesIndex_0.csv
# TestReport_CREW_352x288_30.yuv_SubCasesIndex_0.report
runGetReSubmittedSGEJobTestRestultFile()
{

    for((i=0;i<${ReSubmittedJobNum};i++))
    do
        aReSubmittedSGEJobSHA1List[$i]=NULL
        aReSubmittedSGEJobAllCasesFileList[$i]=NULL
        aReSubmittedSGEJobErrorCasesFileList[$i]=NULL
        aReSubmittedSGEJobTestReportFileList[$i]=NULL

    done

    for file in ${TestResultDir}/*
    do
        TempFileName=`echo $file | awk 'BEGIN {FS="/"} {print $NF}'`

        TempYUVName=NULL
        TempSubCaseIndex=NULL
        vMatchedPattern=NULL

        if [[ "$file" =~ .csv$ ]]
        then
            TempYUVName=`echo $TempFileName          | awk 'BEGIN {FS=".yuv"} {print $1}'`
            TempSubCaseIndex=`echo $TempFileName     | awk 'BEGIN {FS="SubCasesIndex_"} {print $2}'`
            TempSubCaseIndex=`echo $TempSubCaseIndex | awk 'BEGIN {FS=".csv"} {print $1}'`
        elif [[ "$file" =~ .report$ ]]
        then
            TempYUVName=`echo $TempFileName          | awk 'BEGIN {FS=".yuv"} {print $1}'`
            TempYUVName=`echo $TempYUVName           | awk 'BEGIN {FS="TestReport_"} {print $2}'`
            TempSubCaseIndex=`echo $TempFileName     | awk 'BEGIN {FS="SubCasesIndex_"} {print $2}'`
            TempSubCaseIndex=`echo $TempSubCaseIndex | awk 'BEGIN {FS=".report"} {print $1}'`
        fi

        vMatchedPattern="${TempYUVName}.yuv_SubCaseIndex_${TempSubCaseIndex}"

        for((i=0;i<${ReSubmittedJobNum};i++))
        do
            if [ "${aSubmittedSGEJobNameList[$i]}" = "${vMatchedPattern}" ]
            then
                if [[ "${TempFileName}" =~ "AllCases_SHA1_Table" ]]
                then
                    aReSubmittedSGEJobSHA1List[$i]=${file}
                fi

                if [[ "${TempFileName}" =~ "AllCasesOutput_" ]]
                then
                    aReSubmittedSGEJobAllCasesFileList[$i]=${file}
                fi

                if [[ "${TempFileName}" =~ "UnpassedCasesOutput" ]]
                then
                    aReSubmittedSGEJobErrorCasesFileList[$i]=${file}
                fi

                if [[ "${TempFileName}" =~ .report$ ]]
                then
                    aReSubmittedSGEJobTestReportFileList[$i]=${file}
                fi

            fi
        done

    done

}

runRemoveJobFilesBeforeReSubmit()
{
    echo -e "\033[32m **********************************************************  \033[0m"
    echo    "            delete all job related files before re-submit"
    echo -e "\033[32m **********************************************************  \033[0m"

    for((i=0;i<${ReSubmittedJobNum};i++))
    do
        if [ -e ${aReSubmittedSGEJobOutFileList[$i]} ]
        then
            echo "delete file: ${aReSubmittedSGEJobOutFileList[$i]}"
            #./Scripts/run_SafeDelete.sh ${aReSubmittedSGEJobOutFileList[$i]}
        fi

        if [ -e ${aReSubmittedSGEJobErrorInfoFileList[$i]} ]
        then
            echo "delete file: "
            #./Scripts/run_SafeDelete.sh ${aReSubmittedSGEJobErrorInfoFileList[$i]}
            fi

        if [ -e ${aReSubmittedSGEJobFlagFileList[$i]} ]
        then
            echo "delete file: ${aReSubmittedSGEJobErrorInfoFileList[$i]}"
            #./Scripts/run_SafeDelete.sh ${aReSubmittedSGEJobErrorInfoFileList[$i]}
        fi

        if [ -e ${aReSubmittedSGEJobSHA1List[$i]} ]
        then
            echo "delete file: ${aReSubmittedSGEJobSHA1List[$i]}"
            #./Scripts/run_SafeDelete.sh ${aReSubmittedSGEJobSHA1List[$i]}
        fi

        if [ -e ${aReSubmittedSGEJobAllCasesFileList[$i]} ]
        then
            echo "delete file: ${aReSubmittedSGEJobAllCasesFileList[$i]}"
            #./Scripts/run_SafeDelete.sh ${aReSubmittedSGEJobAllCasesFileList[$i]}
        fi

        if [ -e ${aReSubmittedSGEJobErrorCasesFileList[$i]} ]
        then
            echo "delete file: ${aReSubmittedSGEJobErrorCasesFileList[$i]}"
            #./Scripts/run_SafeDelete.sh ${aReSubmittedSGEJobErrorCasesFileList[$i]}
        fi

        if [ -e ${aReSubmittedSGEJobTestReportFileList[$i]} ]
        then
            echo "delete file: ${aReSubmittedSGEJobTestReportFileList[$i]}"
            #./Scripts/run_SafeDelete.sh ${aReSubmittedSGEJobTestReportFileList[$i]}
        fi
    done

    echo -e "\033[32m **********************************************************  \033[0m"
}

runDelPreviousJob()
{
    echo -e "\033[34m **********************************************************  \033[0m"
    echo    "            del previous jobs"
    echo -e "\033[34m **********************************************************  \033[0m"

    for((i=0;i<${ReSubmittedJobNum};i++))
    do
        vTempJobID=${aSubmittedSGEJobIDList[$i]}
        qdel ${vTempJobID}
    done
    echo -e "\033[34m **********************************************************  \033[0m"
}

runReSubmitSGEJobs()
{
    echo -e "\033[32m **********************************************************  \033[0m"
    echo    "             ReSubmit jobs"
    echo -e "\033[32m **********************************************************  \033[0m"

    for((i=0;i<${ReSubmittedJobNum};i++))
    do

        vTempJobID=${aSubmittedSGEJobIDList[$i]}
        vTempJobName=${aSubmittedSGEJobNameList[$i]}
        vTempSGEJobFile=${aReSubmittedSGEJobFileList[$i]}
        vSubmittedFlagFile=${vTempSGEJobFile}_Submitted.flag

        if [ -e ${aReSubmittedSGEJobFileList[$i]} -a  -e ${vSubmittedFlagFile} ]
        then
            vTempJobReSubmitInfo=`qsub ${vSubmittedFlagFile} `
            vTempJobReSubmitInfo="Your job 2609 (----Doc_Complex_768x1024.yuv_SubCaseIndex_11----) has been submitted"
            vTempReSubmitJobID=`echo ${vTempJobReSubmitInfo} | awk '{print $3}'`
            vTempReSubmitJobName=`echo ${vTempJobReSubmitInfo} | awk 'BEGIN {FS="----"} {print $2}'`
        else
            vTempReSubmitJobID=NULL
            vTempReSubmitJobName=NULL
            vTempJobReSubmitInfo=NULL
        fi

        aResubmitSGEJobIDList[$i]=${vTempReSubmitJobID}
        aResubmitSGEJobNameList[$i]=${vTempReSubmitJobName}
        aResubmitSGEJobInfoList[$i]=${vTempJobReSubmitInfo}

    done

    echo -e "\033[32m **********************************************************  \033[0m"

}

runOutputReSubmitInfo()
{

    echo -e "\033[32m ***************************************************************  \033[0m"
    echo    "             ReSubmit job info"
    echo -e "\033[32m ***************************************************************  \033[0m"

    for((i=0;i<${ReSubmittedJobNum};i++))
    do
        echo -e "\033[33m **********************************************************   \033[0m"
        echo -e "\033[33m  job id from--to  : ${aSubmittedSGEJobIDList[$i]}            \033[0m"
        echo -e "\033[33m                   : ${aResubmitSGEJobIDList[$i]}             \033[0m"
        echo -e "\033[33m  job name from--to: ${aSubmittedSGEJobNameList[$i]}          \033[0m"
        echo -e "\033[33m                     ${aResubmitSGEJobNameList[$i]}           \033[0m"
        echo -e "\033[33m  job info from--to: ${aSubmittedSGEJobInfoList[$i]}          \033[0m"
        echo -e "\033[33m                     ${aResubmitSGEJobInfoList[$i]}           \033[0m"
        echo -e "\033[33m  log update flag  : ${aUpdateLogFlagList[$i]}                \033[0m"
        echo -e "\033[33m ***********************************************************  \033[0m"

    done
    echo -e "\033[33m ***************************************************************  \033[0m"
}


runUpdateSubmitLog()
{

    if [ -e ${SGEJobSubmitJobLog} ]
    then
        cp -f ${SGEJobSubmitJobLog} ${BackupSGEJobSubmitJobLog}
    fi

    for((i=0;i<${ReSubmittedJobNum};i++))
    do
        aUpdateLogFlagList[$i]="False"
    done


    let "FirstLineFlag=1"
    vTempLogFile="${SGEJobSubmitJobLog}.Temp"
    while read line
    do
        vOutputLine=$line

        for((i=0;i<${ReSubmittedJobNum};i++))
        do
            if [ "${aSubmittedSGEJobInfoList[$i]}" = "$line"  ]
            then
                echo $line
                echo ${aSubmittedSGEJobInfoList[$i]}
                aUpdateLogFlagList[$i]="True"
                vOutputLine="${aResubmitSGEJobInfoList[$i]}"
            fi
        done

        if [ ${FirstLineFlag} -eq 1 ]
        then
            echo "${vOutputLine}" >${vTempLogFile}
            let "FirstLineFlag=0"
        else
            echo "${vOutputLine}" >>${vTempLogFile}
        fi

    done <${SGEJobSubmitJobLog}

    mv ${vTempLogFile} ${SGEJobSubmitJobLog}

}

runReSubmitSummary()
{


 return 0
}

runCheck()
{
    if [ ! -e ${SGEJobSubmitJobLog} ]
    then
        echo -e "\033[31m *********************************************************************  \033[0m"
        echo    "         SGE job submitted info log file does not exist,please double check"
        echo -e "\033[31m *********************************************************************  \033[0m"
        exit 1
    fi

}
runParseOption()
{

    if [ "${aOption[0]}" == "All" ]
    then
        return 0
    elif [ "${aOption[0]}" == "YUV" ]
    then
        if [ ${ParamNum} -lt 2 ]
        then
            runUsage
            exit 1
        fi

        for((i=1;i<ParamNum;i++))
        do
            let "j = i-1"
            aReSubmittedYUVList[$j]=${aOption[$i]}
        done
        return 0

    elif [ "${aOption[0]}" == "JobID" ]
    then
        if [ ${ParamNum} -lt 2 ]
        then
            runUsage
            exit 1
        fi

        for((i=1;i<ParamNum;i++))
        do
            let "j = i-1"
            aSubmittedSGEJobIDList[$j]=${aOption[$i]}
        done
        return 0

    else
        runUsage
        exit 1
    fi

}

runMain()
{

    runInit
    runCheck
    runParseOption

    if [ "${aOption[0]}" == "All" ]
    then
        runGetSubmittedJobInfoByAllJobs
    elif [ "${aOption[0]}" == "YUV" ]
    then
        runGetSubmittedJobInfoByYUVs
    elif [ "${aOption[0]}" == "JobID" ]
    then
        runGetSubmittedJobInfoByIDs
    fi


    runGetReSubmittedSGEJobFile
    runGetReSubmittedSGEJobTestRestultFile

    runOutputReSubmittedJobInfo >${ReSubmitLog}

    runRemoveJobFilesBeforeReSubmit >>${ReSubmitLog}
    runDelPreviousJob     >>${ReSubmitLog}
    runReSubmitSGEJobs    >>${ReSubmitLog}
    runUpdateSubmitLog    >>${ReSubmitLog}
    runOutputReSubmitInfo >>${ReSubmitLog}

    cat ${ReSubmitLog}

    return 0

}

#parameter check!
if [  $# -lt 1  ]
then
    runUsage
exit 1
fi

declare -a aOption
aOption=($@)
ParamNum=$#

runMain

