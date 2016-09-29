#!/bin/bash
#***************************************************************************************
# brief:
#      --resubmit SGE jobs
#      --usage:  ./run_SGEJobCancel.sh  ${Option}
#
#      --e.g:
#            1) cancel all jobs
#                   ./run_SGEJobCancel.sh  All
#
#            2) cancel all releated jobs of given YUVs
#                   ./run_SGEJobCancel.sh  YUV  01.yuv 02.yuv
#
#            2) cancel given Job IDs
#                   ./run_SGEJobCancel.sh  JobID  123  124  126
#
#
#
#date: 6/09/2015 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
	echo -e "\033[32m usage:  ./run_SGEJobCancel.sh  \${Option}             \033[0m"
    echo ""
    echo -e "\033[32m   --e.g:                                              \033[0m"
    echo -e "\033[32m        1) cancel all jobs                             \033[0m"
    echo -e "\033[32m           ./run_SGEJobCancel.sh  All                  \033[0m"
    echo ""
    echo -e "\033[32m        2) cancel all releated jobs of given YUVs      \033[0m"
    echo -e "\033[32m           ./run_SGEJobCancel.sh  YUV  01.yuv 02.yuv   \033[0m"
    echo ""
    echo -e "\033[32m        3) cancel given Job IDs                        \033[0m"
    echo -e "\033[32m          ./run_SGEJobCancel.sh  JobID  123  124  126  \033[0m"
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
    let "MatchedJobIDNum = 0"

    CurrentDir=`pwd`
    TestSpace=${CurrentDir}/AllTestData
    TestResultDir=${CurrentDir}/FinalResult
    SGEJobSubmitJobLog="${CurrentDir}/SGEJobsSubmittedInfo.log"


    date
    DateInfo=`date`
    DateInfo=`echo ${DateInfo} | awk '{for(i=1;i<=NF;i++) printf("--%s",$i)}'`
    BackupSGEJobSubmitJobLog=${SGEJobSubmitJobLog}-${DateInfo}.log
    JobCancelLog="${CurrentDir}/ReSubmitInfo_Date-${DateInfo}.log"
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
    let "MatchedJobIDNum = 0"
    for((i=0;i<${ReSubmittedJobNum};i++))
    do
        aSubmittedSGEJobNameList[$i]=NULL
        aSubmittedSGEJobInfoList[$i]=NULL
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
                    let "MatchedJobIDNum ++"
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
    let "ReSubmittedJobNum = 0"
    let "MatchedJobIDNum = 0"
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
                    echo "---------------------------------------"
                    echo "  i is $i"
                    echo "TempJobID is ${TempJobID}"
                    echo "TempJobName     is ${TempJobName}"
                    echo "vReSubmmitedYUV is ${vReSubmmitedYUV}"
                    echo "ReSubmittedJobNum is ${ReSubmittedJobNum}"

                    aSubmittedSGEJobIDList[$ReSubmittedJobNum]=${TempJobID}
                    aSubmittedSGEJobNameList[$ReSubmittedJobNum]=${TempJobName}
                    aSubmittedSGEJobInfoList[$ReSubmittedJobNum]=${line}

                    echo "aSubmittedSGEJobIDList[$ReSubmittedJobNum]   is ${aSubmittedSGEJobIDList[$ReSubmittedJobNum]}"
                    echo "aSubmittedSGEJobNameList[$ReSubmittedJobNum] is ${aSubmittedSGEJobNameList[$ReSubmittedJobNum]}"
                    echo "aSubmittedSGEJobInfoList[$ReSubmittedJobNum] is ${aSubmittedSGEJobInfoList[$ReSubmittedJobNum]}"

                    let "ReSubmittedJobNum ++"
                    let "MatchedJobIDNum ++"
                fi
            done
        fi

    done <${SGEJobSubmitJobLog}

}

runGetSubmittedJobInfoByAllJobs()
{

    let "ReSubmittedJobNum =0"
    let "ExampleLineFlag =0"
    let "MatchedJobIDNum =0"
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
                aSubmittedSGEJobInfoList[$ReSubmittedJobNum]=${line}
                let "ReSubmittedJobNum ++"
                let "MatchedJobIDNum ++"
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
# TestReport_CREW_352x288_30.yuv_SubCasesIndex_0.report.log
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
        elif [[ "$file" =~ .report.log$ ]]
        then
            TempYUVName=`echo $TempFileName          | awk 'BEGIN {FS=".yuv"} {print $1}'`
            TempYUVName=`echo $TempYUVName           | awk 'BEGIN {FS="TestReport_"} {print $2}'`
            TempSubCaseIndex=`echo $TempFileName     | awk 'BEGIN {FS="SubCasesIndex_"} {print $2}'`
            TempSubCaseIndex=`echo $TempSubCaseIndex | awk 'BEGIN {FS=".report.log"} {print $1}'`
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

                if [[ "${TempFileName}" =~ .report.log$ ]]
                then
                    aReSubmittedSGEJobTestReportFileList[$i]=${file}
                fi

            fi
        done

    done

}

runDelPreviousJob()
{
    echo -e "\033[34m **********************************************************  \033[0m"
    echo    "            del previous jobs"
    echo -e "\033[34m **********************************************************  \033[0m"

    for((i=0;i<${ReSubmittedJobNum};i++))
    do
        vTempJobID=${aSubmittedSGEJobIDList[$i]}
        echo "Deleted Job ID is ${vTempJobID} "
        qdel ${vTempJobID}
    done
    echo -e "\033[34m **********************************************************  \033[0m"
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

runGetJobsInfo()
{
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

}
runMain()
{

    runInit
    runCheck
    runParseOption

    echo "">>${JobCancelLog}
    echo "*********************************************************" >>${JobCancelLog}
    echo "*********************************************************" >>${JobCancelLog}
    echo " Before cancel job, current SGE jobs info listed as below" >>${JobCancelLog}
    qstat >>${JobCancelLog}
    echo "*********************************************************" >>${JobCancelLog}
    echo "**********************************************************" >>${JobCancelLog}
    echo "">>${JobCancelLog}
    echo "">>${JobCancelLog}

    runGetJobsInfo >${JobCancelLog}

    runGetReSubmittedSGEJobFile  >>${JobCancelLog}
    runGetReSubmittedSGEJobTestRestultFile  >>${JobCancelLog}


    runDelPreviousJob     >>${JobCancelLog}
    runOutputReSubmittedJobInfo >>${JobCancelLog}

    sleep 20
    echo "">>${JobCancelLog}
    echo "*********************************************************" >>${JobCancelLog}
    echo "*********************************************************" >>${JobCancelLog}
    echo " After cancel job, current SGE jobs info listed as below" >>${JobCancelLog}
    qstat >>${JobCancelLog}
    echo "*********************************************************" >>${JobCancelLog}
    echo "**********************************************************" >>${JobCancelLog}
    echo "">>${JobCancelLog}
    echo "">>${JobCancelLog}

    cat ${JobCancelLog}



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

echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters is:"
echo "        $0 $@"
echo "*********************************************************"
echo ""

runMain

