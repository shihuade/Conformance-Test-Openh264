#!/bin/bash
#**************************************************************************************
#
#  Usage:
#       run_JenkinsSGEJobStatusUpdate.sh  ${TestProfile}
#
#  brief:
#       update jobs status.
#       if all jobs have been cpmpleted, get test summary and back up test data
#
# date: 2015/06/18
#**************************************************************************************

runUsage()
{
    echo ""
    echo " Usage: run_JenkinsSGEJobStatusUpdate.sh  \${TestProfile}"
    echo ""
    echo " e.g.: "
    echo "     run_JenkinsSGEJobStatusUpdate.sh  SCC "
    echo "     run_JenkinsSGEJobStatusUpdate.sh  SVC "
    echo ""
}



runInital()
{
    CurrentDir=`pwd`
    SGEJobsTestSpace="${CurrentDir}"

    JenkinsHomeDir="/Users/jenkins"
    AttachmentsFolder="Openh264-SGETest/Jenkins-Job-Status-Check-Log"
    AttachmentsDir="${JenkinsHomeDir}/${AttachmentsFolder}"

    CaseConfigureFileDir="CaseConfigure"
    CaseConfigureFile="${CaseConfigureFileDir}/case_${TestProfile}.cfg"
    FinalResultSummaryDir="FinalTestReport"
    FinalResultDir="FinalResult"
    SGEIPInfoFile="${CurrentDir}/Tools/SGE.cfg"

    JobFailedFlagFile="FailedJobInfo.txt"
    JobFailedFlag="False"

    #log file for attachments
    SGEJobSubmittedLog="SGEJobsSubmittedInfo.log"
    SGEJobsStatusLog="${TestProfile}_SGEJobStatus.txt"
    SGEJobsReportLog="${TestProfile}_JobReport.txt"
    AllTestSummary="AllTestYUVsSummary.txt"
    SGEJobsAllTestSummary="${TestProfile}_AllTestYUVsSummary.txt"
    AllJobsCompletedFlagFile="AllSGEJobsCompleted.flag"
    AllTestResultPassFlag="AllCasesPass.flag"
    CodecInfoLog="CodecInfo.log"

    SuccedJobsInfo="SuccedJobsDetailInfo.txt"
    FailedJobsInfo="FailedJobsDetailInfo.txt"
    UnRunCasesJobsInfo="UnRunCasesJobsDetailInfo.txt"
    UnknownReasonJobsInfo="UnknownReasonJobsDetailInfo.txt"


}

runOutputBasicInfo()
{
    echo ""
    echo ""
    echo "*****************************************************************************"
    echo "*****************************************************************************"
    echo " SGE jobs status for ${TestProfile}"
    echo "*****************************************************************************"
    echo "*****************************************************************************"
    echo ""
    echo "  CurrentDir is ${CurrentDir} "
    echo ""
}

runUpdateScript()
{

    git branch
    git  remote -v

    git fetch origin
    git checkout master
    git pull origin master

}

runUpdateJobStatus()
{

    ./run_SGEJobStatusUpdate.sh ${SGEJobSubmittedLog} ${AllJobsCompletedFlagFile}>${SGEJobsStatusLog}

    echo ""
    echo "*****************************************************************************"
    echo "   jobs  status ---- ${TestProfile}"
    echo "*****************************************************************************"
    echo ""

    cat ${SGEJobsStatusLog}
    echo "*****************************************************************************"
    echo ""

}

runGetAllCompletedJobReport()
{
    echo ""
    echo "*****************************************************************************"
    echo " report for completed jobs ---- ${TestProfile}"
    echo "*****************************************************************************"
    echo ""

    echo >${SGEJobsReportLog}
    for file in ${SGEJobsTestSpace}/${FinalResultDir}/TestReport*
    do
        echo file is $file
        if [ -e ${file} ]
        then

            echo "report file: ${file}">>${SGEJobsReportLog}
            cat ${file} >>${SGEJobsReportLog}
        fi
    done

    cat ${SGEJobsReportLog}

    echo "*****************************************************************************"
    echo ""


}

runGetSummary()
{
    #get summary
    if [ -e ${AllJobsCompletedFlagFile} ]
    then
        echo ""
        echo "*****************************************************************************"
        echo " Final summary for all jobs ---- ${TestProfile}"
        echo "*****************************************************************************"
        echo ""
        ./run_GetAllTestResult.sh SGETest ${CaseConfigureFile} ${AllTestResultPassFlag}
        cat  ${SGEJobsTestSpace}/${FinalResultSummaryDir}/${AllTestSummary}
        cp   ${SGEJobsTestSpace}/${FinalResultSummaryDir}/${AllTestSummary}  ${AttachmentsDir}/${SGEJobsAllTestSummary}
    fi

}
runCopyFilesToAchiveDir()
{
    cd ${CurrentDir}

    cp ${SGEJobsStatusLog}    ${AttachmentsDir}
    cp ${SGEJobsReportLog}    ${AttachmentsDir}

    echo "****************************************"
    echo "AttachmentsDir is ${AttachmentsDir}"
    echo "****************************************"

    if [ -e ${SGEJobSubmittedLog} ]
    then
        cp ${SGEJobSubmittedLog} ${AttachmentsDir}/${TestProfile}_${SGEJobSubmittedLog}
    fi

    if [ -e ${CodecInfoLog} ]
    then
        cp ${CodecInfoLog}  ${AttachmentsDir}/${TestProfile}_${CodecInfoLog}
    fi

    if [ -e ${CaseConfigureFile} ]
    then
        cp ${CaseConfigureFile}  ${AttachmentsDir}
    fi

    if [ -e ${SGEIPInfoFile} ]
    then
        cp ${SGEIPInfoFile}  ${AttachmentsDir}/SGEIPInfo.txt
    fi

    if [ -e ${SuccedJobsInfo} ]
    then
        cp ${SuccedJobsInfo}  ${AttachmentsDir}/${TestProfile}_${SuccedJobsInfo}
    fi

    if [ -e ${FailedJobsInfo} ]
    then
        cp ${FailedJobsInfo}  ${AttachmentsDir}/${TestProfile}_${FailedJobsInfo}
    fi

    if [ -e ${UnRunCasesJobsInfo} ]
    then
        cp ${UnRunCasesJobsInfo}  ${AttachmentsDir}/${TestProfile}_${UnRunCasesJobsInfo}
    fi

    if [ -e ${UnknownReasonJobsInfo} ]
    then
        cp ${UnknownReasonJobsInfo}  ${AttachmentsDir}/${TestProfile}_${UnknownReasonJobsInfo}
    fi

}

runMain()
{
    runInital
    runOutputBasicInfo
    runUpdateScript
    runUpdateJobStatus

    runGetAllCompletedJobReport

    runGetSummary
    runCopyFilesToAchiveDir

}

if [ ! $# -eq 1 ]
then
    runUsage
    exit 1
fi

TestProfile=$1
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters is:"
echo "        $0 $@"
echo "*********************************************************"
echo ""

runMain ${TestProfile}

