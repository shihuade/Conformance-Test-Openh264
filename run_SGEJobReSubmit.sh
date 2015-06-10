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


runInitialSGEJobInfoFile()
{
    echo "***********************************************************************************************"
    echo "    "
    echo "    This file is used for SGE job status detction."
    echo "    "
    echo "    You can add new SGE job info in this file if you want to add "
    echo "    new jobs into current test or restart jobs before all"
    echo "    test jobs are completed"
    echo "    "
    echo "    Job info format should looks like as below:"
    echo "      Your job 534 ("CREW_176x144_30.yuv_SGE_Test_SubCaseIndex_1") has been submitted"
    echo "    "
    date
    echo "*************************************************************************************************"
    echo ""
    echo "    All SGE jobs info List As below"
    echo ""
    echo "*************************************************************************************************"

}


runInit()
{
    declare -a aSubmittedSGEJobIDList
    declare -a aSubmittedSGEJobNameList
    declare -a aReSubmittedYUVList

    declare -a aReSubmittedSGEJobFileList
    declare -a aReSubmittedSGEJobOutFileList
    declare -a aReSubmittedSGEJobFlagFileList
    declare -a aReSubmittedSGEJobErrorInfoFileList

    declare -a aResubmitSGEJobIDList

    let "SubmittedJobNum = 0"

    CurrentDir=`pwd`
    TestSpace=${CurrentDir}/AllTestData
    SGEJobSubmitJobLog="${CurrentDir}/SGEJobsSubmittedInfo.log"

}

runDelSGEJobs()
{


	return 0
}

runUpdateSubmitJobLog()
{

	return 0
}

updateJobRelatedTestFiles()
{

#SHA1 File
#report
#passed Status .csv files



	return 0
}
#*******************************************************************************
#      job submitted info in log looks like as below
# ******************************************************************************
# test YUV is Doc_simple_1024x768.yuv
# ******************************************************************************
# Your job 1636 ("Doc_simple_1024x768.yuv_SubCaseIndex_0") has been submitted
# Your job 1637 ("Doc_simple_1024x768.yuv_SubCaseIndex_10") has been submitted
# Your job 1638 ("Doc_simple_1024x768.yuv_SubCaseIndex_11") has been submitted
#   ......
runGetSubmittedJobInfoByIDs()
{
    aSubmittedSGEJobIDList=(1964  1965 )

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
            TempJobName=`echo $line | awk 'BEGIN {FS="[("")]"} {print $2}'`

            for((i=0;i<${ReSubmittedJobNum};i++))
            do
                vSubmmitedJobID=${aSubmittedSGEJobIDList[$i]}
                if [ "${vSubmmitedJobID}" -eq "${TempJobID}" ]
                then
                    aSubmittedSGEJobNameList[$i]=${TempJobName}
                fi
            done
        fi

    done <${SGEJobSubmitJobLog}

    echo "aSubmittedSGEJobNameList is ${aSubmittedSGEJobNameList[@]}"
}

runGetSubmittedJobInfoByYUVs()
{
    aReSubmittedYUVList=(candyHF2_640x480.yuv Jiessie_James_talking_1280x720_30.yuv)

    let "NumYUV=${#aReSubmittedYUVList[@]}"
    let "ReSubmittedJobNum=0"
    while read line
    do
        if [[ "$line" =~ ^"Your job" ]]
        then
            TempJobID=`echo $line | awk '{print $3}'`
            TempJobName=`echo $line | awk 'BEGIN {FS="[("")]"} {print $2}'`

            for((i=0;i<${NumYUV};i++))
            do
                vReSubmmitedYUV=${aReSubmittedYUVList[$i]}
                if [[ "${TempJobName}" =~ "${vReSubmmitedYUV}" ]]
                then
                    aSubmittedSGEJobIDList[$ReSubmittedJobNum]=${TempJobID}
                    aSubmittedSGEJobNameList[$ReSubmittedJobNum]=${TempJobName}
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
                TempJobName=`echo $line | awk 'BEGIN {FS="[("")]"} {print $2}'`

                aSubmittedSGEJobIDList[$ReSubmittedJobNum]=${TempJobID}
                aSubmittedSGEJobNameList[$ReSubmittedJobNum]=${TempJobName}
                let "ReSubmittedJobNum ++"
            fi
        fi

    done <${SGEJobSubmitJobLog}

 	return 0
}

runOutputReSubmittedJobInfo()
{
    echo -e "\033[32m ****************************************************************************   \033[0m"
    echo                   ReSubmitted Job info listed as below:
    echo -e "\033[32m ****************************************************************************   \033[0m"

    for((i=0;i<${ReSubmittedJobNum};i++))
    do
        echo -e "\033[32m ${aSubmittedSGEJobIDList[$i]}:  ${aSubmittedSGEJobNameList[$i]}            \033[0m"
        echo -e "\033[32m      sge job file            :  ${aReSubmittedSGEJobFileList[$i]}          \033[0m"
        echo -e "\033[32m      job output file         :  ${aReSubmittedSGEJobOutFileList[$i]}       \033[0m"
        echo -e "\033[32m      job error info  file    :  ${aReSubmittedSGEJobErrorInfoFileList[$i]} \033[0m"
        echo -e "\033[32m      job submitted flag file :  ${aReSubmittedSGEJobFlagFileList[$i]}      \033[0m"
    done
    echo -e "\033[32m ***************************************************************************    \033[0m"

}

runGetReSubmittedSGEJobFile()
{

    for((i=0;i<${ReSubmittedJobNum};i++))
    do
        aReSubmittedSGEJobFileList[$i]=NULL
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

runParseOption()
{

    return 0


}


runMain()
{
	CurrentDir=`pwd`

    runInit
    runGetSubmittedJobInfoByIDs
    runGetReSubmittedSGEJobFile
    runOutputReSubmittedJobInfo

#runGetSubmittedJobInfoByYUVs
# runGetReSubmittedSGEFile
#  runOutputReSubmittedJobInfo

#runGetSubmittedJobInfoByAllJobs
#runGetReSubmittedSGEFile
#runOutputReSubmittedJobInfo
# runGetReSubmittedSGEFile

    return 0

}
#parameter check!
if [  $# -lt 1  ]
then
    runUsage
exit 1
fi

runMain

