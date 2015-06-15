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
    echo ""
    echo " e.g.: "
    echo "     run_JenkinsJob_SGEJobSubmit.sh  0 SCC"
    echo "     run_JenkinsJob_SGEJobSubmit.sh  1 SCC"
    echo "     run_JenkinsJob_SGEJobSubmit.sh  0 SVC"
    echo "     run_JenkinsJob_SGEJobSubmit.sh  1 SVC"
    echo ""
    echo "\${KillRunningJobFlag} ==1, kill current running jobs and submit new jobs"
    echo ""
    echo "\${KillRunningJobFlag} ==0, check current running jobs; "
    echo "               1) if jobs have not completed yet, skip job submittion"
    echo "               1) if jobs completed yet,backup test data,clean up test space and submit new jobs"
    echo ""
}

runInitial()
{
    JenkinsHomeDir="/Users/jenkins"
    AttachmentsFolder="Openh264-SGETest/Jenkins-Job-Submit-Log"
    AttachmentsDir="${JenkinsHomeDir}/${AttachmentsFolder}"

    #log file for attachments
    #log file for attachments
    SGEJobSubmittedLog="SGEJobsSubmittedInfo.log"
    JobsStatusLog="SGEJobStatus.txt"
    AllJobsCompletedFlagFile="AllSGEJobsCompleted.flag"

    SummaryInfo="NULL"
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

    if [ ${KillFlag} -eq 1  ]
    then
        ./run_SGEJobCancel.sh All
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
    echo        Update SGE job infor for  ${TestProfile}
    echo "*****************************************************************************"
    echo "*****************************************************************************"
    echo ""
    echo ""

    if [ -e ${SGEJobSubmittedLog} ]
    then
        ./run_SGEJobStatusUpdate.sh ${SGEJobSubmittedLog} ${AllJobsCompletedFlagFile}>${SVCStatusLog}
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
        echo "it may caused by:""
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



    ./run_Main.sh SGETest  CaseConfigure/case_${TestProfile}.cfg  "${CodecBranch}"  "${ReposAddr}"

    cp ${SGEJobSubmittedLog} ${AttachmentsDir}/${TestProfile}_${SGEJobSubmittedLog}


}


runCancelAllRunningJobsAndSubmitNewJobs()
{

    runSGEJobsUpdate
    runSGEJobPreviousTestBackup
    runKillJob

    runCleanUpAllTestData

    runSubmitSGEJobs

    SummaryInfo="Stop all previous SGE jobs and submit new jobs based setting!"

}

runCheckAndSubmitJobs()
{
    if [ ! -e {SGEJobSubmittedLog} ]
    then
        runCleanUpAllTestData
        runSubmitSGEJobs
    else
        runSGEJobsUpdate
        if [ -e ${AllJobsCompletedFlagFile} ]
        then
            runSGEJobPreviousTestBackup
            runCleanUpAllTestData
            runSubmitSGEJobs
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
    cp ${SGEJobSubmittedLog}          ${AttachmentsDir}/${TestProfile}_${SGEJobSubmittedLog}
    cp ${JobsStatusLog}               ${AttachmentsDir}/${TestProfile}_${JobsStatusLog}
    cp ${AllJobsCompletedFlagFile}    ${AttachmentsDir}/${TestProfile}_${AllJobsCompletedFlagFile}
    echo ""
    echo "*****************************************************************************"

}

runOutputSUmmary()
{

    echo ""
    echo "*****************************************************************************"
    echo " TestProfile is ${TestProfile}"
    echo " KillJobsFlag is ${KillJobsFlag}"
    echo ""
    echo " SummaryInfo for this job is ${SummaryInfo}"
    echo "*****************************************************************************"

}

runMain()
{

    runInitial

    if [ ${KillJobsFlag} -eq 1 ]
    then
        runCancelAllRunningJobsAndSubmitNewJobs
    else
        runCheckAndSubmitJobs
    fi

    runCopyFilesToAttachedDir
    runOutputSUmmary

    return 0

}

if [ ! $# -eq 2 ]
then
    runUsage
    exit 1
fi

TestProfile=$1
KillJobsFlag=$2

runMain ${TestProfile} ${KillJobsFlag}



