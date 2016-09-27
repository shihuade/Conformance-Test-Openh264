#!/bin/bash
#**************************************************************************************
#
#   when set to 1, will kill all related jobs and submit jobs based on codec branch
#   when set to 0, jenkins will detect that whether current jobs have been completed.
#       ----if not yet, jenkins will skip job submit and output current job status;
#       ----if all jobs have been completed, jenkins will
#            --1)get test summary
#            --2) backup test data
#            --3) submit SGE jobs based on given codec Repos and branch
#
#
#**************************************************************************************

runUsage()
{
    echo ""
    echo " Usage: run_JenkinsJob_SGEJobSubmit.sh  \${KillRunningJobFlag} \${TestProfile}"
    echo "                                        \${CodecBranch}        \${ReposAddr}"
    echo ""
    echo " e.g.: "
    echo "     run_JenkinsJob_SGEJobSubmit.sh  0 SCC master https://github.com/openh264.git"
    echo "     run_JenkinsJob_SGEJobSubmit.sh  1 SCC master https://github.com/openh264.git"
    echo "     run_JenkinsJob_SGEJobSubmit.sh  0 SVC master https://github.com/openh264.git"
    echo "     run_JenkinsJob_SGEJobSubmit.sh  1 SVC master https://github.com/openh264.git"
    echo ""
    echo "     KillRunningJobFlag ==1, kill current running jobs and submit new jobs"
    echo ""
    echo "     KillRunningJobFlag ==0, check current running jobs; "
    echo "               1) if jobs have not completed yet, skip job submittion"
    echo "               1) if jobs completed yet,backup test data,clean up test space and submit new jobs"
    echo ""
}

runInitial()
{
    JenkinsHomeDir="/Users/jenkins"
    AttachmentsFolder="Openh264-SGETest/Jenkins-Job-Submit-Log"
    AttachmentsDir="${JenkinsHomeDir}/${AttachmentsFolder}"
    CurrentDir=`pwd`
    SGEJobsTestSpace="${CurrentDir}"
    
    #for job status 
    FinalTestReportDir="FinalTestReport"
    AllTestSummary="AllTestYUVsSummary.txt"
    SGEJobsAllTestSummary="${TestProfile}_AllTestYUVsSummary.txt"
    AllJobsCompletedFlagFile="AllSGEJobsCompleted.flag"
    AllTestResultPassFlag="AllCasesPass.flag"
    let " SubmitJobStatusFlag = 0"

    #log file for attachments
    #log file for attachments
    SGEJobSubmittedLog="SGEJobsSubmittedInfo.log"
    SGEJobCancelJobLog="SGEJobsCancelInfo.log"
    JobsStatusLog="SGEJobStatus.txt"

#ConfigureFile="CaseConfigure/case_${TestProfile}.cfg"
ConfigureFile="CaseConfigure/case_for_linux_fast_test.cfg"

    CodecInfoLog="CodecInfo.log"
    SummaryInfo="NULL"

    SCCStatusLog="SCCSGEJobStatus.txt"
    SVCStatusLog="SVCSGEJobStatus.txt"
    
    SCCJobSubmittedDateLog="SCCJobSubmittedDate.txt"
    SVCJobSubmittedDateLog="SVCJobSubmittedDate.txt"
    JobSubmittedDateLog="JobSubmittedDate.txt"
    
    PrieviousJobBackupLog="${TestProfile}_PreviousJobBackupInfo.txt"
    
    date
    DateInfo=`date`
    SGEJobStatusLog="${TestProfile}_SGEJobStatus.txt"
}


runKillJob()
{

    echo "*****************************************************************************"
    echo "*****************************************************************************"
    echo         Kill jobs before job submittion for  ${TestProfile}
    echo "*****************************************************************************"
    echo "*****************************************************************************"
    echo ""
    echo ""

    if [ ${KillJobsFlag} = "true"  ]
    then
        ./run_SGEJobCancel.sh All >${SGEJobCancelJobLog}
    fi
    echo ""
    echo ""
    echo "*****************************************************************************"
    echo "*****************************************************************************"

}

runSGEJobsUpdate()
{

    echo "*****************************************************************************"
    echo "*****************************************************************************"
    echo        Update SGE job info for  ${TestProfile}
    echo "*****************************************************************************"
    echo "*****************************************************************************"
    echo ""
    echo ""

    if [ -e ${SGEJobSubmittedLog} ]
    then
        ./run_SGEJobStatusUpdate.sh ${SGEJobSubmittedLog} ${AllJobsCompletedFlagFile}>${SGEJobStatusLog}
        cat ${SGEJobStatusLog}
    else
        echo "there is no job been sbumitted yet!"
    fi

    echo ""
    echo ""
    echo "*****************************************************************************"
    echo "*****************************************************************************"
}

runCleanUpAllTestData()
{

    echo "*****************************************************************************"
    echo "*****************************************************************************"
    echo       clean up all previous test data before job submit for  ${TestProfile}
    echo "*****************************************************************************"
    echo "*****************************************************************************"
    echo ""
    echo ""

    ./run_CleanUpTestSpace.sh

    echo ""
    echo ""
    echo "*****************************************************************************"
    echo "*****************************************************************************"


}
runGetPriviousTestSummary()
{
    #get summary
    if [ -e ${AllJobsCompletedFlagFile} ]
    then
        echo ""
        echo "*****************************************************************************"
        echo " Final summary for all previous submitted jobs ---- ${TestProfile}"
        echo "*****************************************************************************"
        echo ""
        ./run_GetAllTestResult.sh SGETest ${ConfigureFile} ${AllTestResultPassFlag}
        cat  ${SGEJobsTestSpace}/${FinalTestReportDir}/${AllTestSummary}
        cp   ${SGEJobsTestSpace}/${FinalTestReportDir}/${AllTestSummary}  ${AttachmentsDir}/${SGEJobsAllTestSummary}
        
        if [ ! -e ${AllTestResultPassFlag} ]
        then
             echo "*****************************************************************************"
             echo " not all cases passed the test for previous submit!"
             echo " test profile is ${TestProfile}  "
             echo " please double check!"
             echo "*****************************************************************************"
             let " SubmitJobStatusFlag = 1"
        fi
    fi

}

runSGEJobPreviousTestBackup()
{

    echo "*****************************************************************************"
    echo "*****************************************************************************"
    echo         Data backup for  ${TestProfile}
    echo "*****************************************************************************"
    echo "*****************************************************************************"
    echo ""
    echo ""
    if [ -e ${AllJobsCompletedFlagFile} ]
    then

        ./run_BackupTestData.sh  ./   ${TestProfile}
    else
        echo "there is no test summary in current dir"
        echo "it may caused by:"
        echo "           1) there is no job been submitted for test"
        echo "           2) there are still jobs running for test and have not completed yet"

    fi
    echo ""
    echo ""
    echo "*****************************************************************************"
    echo "*****************************************************************************"

}

runSubmitSGEJobs()
{

    ./run_Main.sh SGETest  ${ConfigureFile}  "${CodecBranch}"  "${ReposAddr}"

}
runGenerateDateInfo()
{
    echo "****************************************" >${JobSubmittedDateLog}
    echo ""                                        >>${JobSubmittedDateLog}
    echo "Submitted date is:"                      >>${JobSubmittedDateLog}
    echo        ${DateInfo}                        >>${JobSubmittedDateLog}
    echo ""                                        >>${JobSubmittedDateLog}
    echo "****************************************">>${JobSubmittedDateLog}
}

runCancelAllRunningJobsAndSubmitNewJobs()
{

    runSGEJobsUpdate
    runGetPriviousTestSummary

    runSGEJobPreviousTestBackup >${PrieviousJobBackupLog}
    cat ${PrieviousJobBackupLog}
    
    runKillJob
    cat ${SGEJobCancelJobLog}

    runCleanUpAllTestData

    runSubmitSGEJobs
    runGenerateDateInfo

}

runCheckAndSubmitJobs()
{
    if [ ! -e ${SGEJobSubmittedLog} ]
    then
        runCleanUpAllTestData
        runSubmitSGEJobs
    else
        runSGEJobsUpdate
        if [ -e ${AllJobsCompletedFlagFile} ]
        then
            runSGEJobPreviousTestBackup >${PrieviousJobBackupLog}
            cat ${PrieviousJobBackupLog}
            
            runCleanUpAllTestData
            runSubmitSGEJobs
            runGenerateDateInfo
            SummaryInfo="Backup previous test data and submit new jobs based on setting"
        else
            echo "skip job submit as previous jobs have not been completed yet!"
            SummaryInfo="skip job submit as previous jobs have not been completed yet!"
        fi

    fi



}
runCopyFilesToAttachedDir()
{

    echo ""
    echo "*****************************************************************************"
    echo " copy files to attached dir for ${TestProfile}"
    echo "*****************************************************************************"
    if [ -e ${SGEJobSubmittedLog} ]
    then
        cp ${SGEJobSubmittedLog}          ${AttachmentsDir}/${TestProfile}_${SGEJobSubmittedLog}
    fi

    if [ -e ${JobsStatusLog} ]
    then
        cp ${JobsStatusLog}               ${AttachmentsDir}/${TestProfile}_${JobsStatusLog}
    fi

    if [ -e ${AllJobsCompletedFlagFile} ]
    then
        cp ${AllJobsCompletedFlagFile}    ${AttachmentsDir}/${TestProfile}_${AllJobsCompletedFlagFile}
    fi

    if [ -e ${SGEJobCancelJobLog} ]
    then
        cp ${SGEJobCancelJobLog}    ${AttachmentsDir}/${TestProfile}_${JobsStatusLog}
    fi

    if [ -e ${ConfigureFile} ]
    then
        cp ${ConfigureFile}    ${AttachmentsDir}/${ConfigureFile}
    fi

    if [ -e ${CodecInfoLog} ]
    then
        cp ${CodecInfoLog}    ${AttachmentsDir}/${TestProfile}_${CodecInfoLog}
    fi

    if [ -e ${JobSubmittedDateLog} ]
    then
        cp ${JobSubmittedDateLog}    ${AttachmentsDir}/${JobSubmittedDateLog}
    fi
 
    if [ -e ${SGEJobStatusLog} ]
    then
        cp ${SGEJobStatusLog}    ${AttachmentsDir}/${SGEJobStatusLog}
    fi

   if [ -e ${PrieviousJobBackupLog} ]
    then
        cp ${PrieviousJobBackupLog}    ${AttachmentsDir}/${PrieviousJobBackupLog}
    fi

    echo ""
    echo "*****************************************************************************"

}

runOutputSUmmary()
{

    echo ""
    echo "*****************************************************************************"
    echo " TestProfile    is ${TestProfile}"
    echo " KillJobsFlag   is ${KillJobsFlag}"
    echo " Configure file is ${ConfigureFile}"
    echo " Codec branch   is ${CodecBranch}"
    echo " ReposAddr      is ${ReposAddr}"
    echo ""
    echo " SummaryInfo for this job is:"
    if [ ${SubmitJobStatusFlag} -eq 0 ]
    then
        echo " ${SummaryInfo}--all is well!"
        echo "*****************************************************************************"
        exit 0
    else
        echo " ${SummaryInfo}"
        echo "    --previous submit jobs failed!"
        echo "    --please double check "
        echo "    --and refer detail from privous backup log file--${PrieviousJobBackupLog}"
        echo "*****************************************************************************"
        exit 1
    fi
}

runCheck()
{

    if [ ! -e ${ConfigureFile} ]
    then
        echo ""
        echo "Configure file ${ConfigureFile} does not exist,please double check!"
        echo ""
        exit 1
    fi

    if [ "${TestProfile}" = "SCC"  ]
    then
        JobSubmittedDateLog=${SCCJobSubmittedDateLog}
        return 0
    elif [ "${TestProfile}" = "SVC"  ]
    then
        JobSubmittedDateLog=${SVCJobSubmittedDateLog}
        return 0
    else
        echo ""
        echo " test profile does not support,please refet to the usage!"
        echo ""
        runUsage
        exit 1
    fi

}
runMain()
{

    runInitial
    runCheck

    if [  ${KillJobsFlag} =  "true" ]
    then
        runCancelAllRunningJobsAndSubmitNewJobs
    else
        runCheckAndSubmitJobs
    fi

    runCopyFilesToAttachedDir
    runOutputSUmmary
}

if [ ! $# -eq 4 ]
then
    runUsage
    exit 1
fi

TestProfile=$1
KillJobsFlag=$2
CodecBranch=$3
ReposAddr=$4

echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters is:"
echo "        $0 $@"
echo "*********************************************************"
echo ""

runMain ${TestProfile} ${KillJobsFlag}  "${CodecBranch}"  "${ReposAddr}"



