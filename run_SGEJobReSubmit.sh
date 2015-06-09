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
#date: 04/26/2015 Created
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

    declare -a aResubmitSGEJobIDList
    declare -a aYUVList

    let "SubmittedJobNum = 0"

    CurrentDir=`pwd`
    TestSpace=${CurrentDir}
    SGEJobSubmitJobLog="${CurrentDir}/SGEJobsSubmittedInfo.log"

}

runDelSGEJobs()
{



}

runUpdateSubmitJobLog()
{


}

updateJobRelatedTestFiles()
{

#SHA1 File
#report
#passed Status .csv files




}
run






runParseJobsInfo()
{
    aSubmittedSGEJobIDList=(`./Scripts/run_ParseSGEJobIDs.sh     ${SGEJobSubmittedLogFile}`)
    aSubmittedSGEJobNameList=(`./Scripts/run_ParseSGEJobNames.sh ${SGEJobSubmittedLogFile}`)

    #list info include ID and status
    #e.g.:aCurrentSGEQueueJobIDList=(501 r 502 r 503 w 504 qw)
    let "SubmittedJobNum       = ${#aSubmittedSGEJobIDList[@]}"
    let "CurrentSGEQueueJobNum = ${#aCurrentSGEQueueJobIDList[@]}/2"

}

runModifiedSGEJobSubmittedFile()
{

for((i=0;i<${ResubmitJobNum};i++))
do
    ResubmitJobID=${aResubmitSGEJobIDList[$i]}



done
}

runGetJobSGEFile()
{





}
runResubmitJob()
{

for JobID in ${aResubmitSGEJobIDList[@]}
do

done


}













runSGEJobSubmit()
{
	let "JobNum=0"
    runInitialSGEJobInfoFile >${SGEJobListFile}

	for TestYUV in ${aTestYUVList[@]}
	do
        SubFolder="${AllTestDataDir}/${TestYUV}"
        echo ""
        echo "test YUV is ${TestYUV}"
        echo ""
        echo "******************************************************************************" >>${SGEJobListFile}
        echo "test YUV is ${TestYUV}" >>${SGEJobListFile}
        echo "******************************************************************************" >>${SGEJobListFile}

        for vSGEFile in ${SubFolder}/${TestYUV}*.sge
        do
            TestSubmitFlagFile="${vSGEFile}_Submitted.flag"

            if [  -e  ${SubFolder}/${TestSubmitFlagFile} ]
            then
                continue
            fi

            echo "submitting job ......"
            # e.g.: Your job 534 ("CREW_176x144_30.yuv_SGE_Test_SubCaseIndex_1") has been submitted
            aSubmitJobList[$JobNum]=`qsub  ${vSGEFile} `
            echo "submit job is ${aSubmitJobList[$JobNum]} "
            echo "${aSubmitJobList[$JobNum]}" >>${SGEJobListFile}
            let "JobNum ++"
            touch ${TestSubmitFlagFile}
            #cd  ${CurrentDir}

        done
	done
	return 0
}

runMain()
{
	CurrentDir=`pwd`

	let "CurrentSGEJobNum=0"
	declare -a aTestYUVList

	#get full path info
	cd ${AllTestDataDir}
	AllTestDataDir=`pwd`
	cd  ${CurrentDir}

	#get YUV list
    aTestYUVList=(`./Scripts/run_GetTestYUVSet.sh  ${ConfigureFile}`)
    if [ ! $? -eq 0 ]
    then
        echo -e "\033[31m  Failed to parse test YUV set. please double check! \033[0m"
        echo -e "\033[31m  detected by $0 \033[0m"
        exit 1
    fi

    runSGEJobSubmit

    return 0

}
#parameter check!
if [ ! $# -eq 3  ]
then
runUsage
exit 1
fi

AllTestDataDir=$1
ConfigureFile=$2
SGEJobListFile=$3
runMain  ${AllTestDataDir}  ${ConfigureFile} ${SGEJobListFile}

