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
    CaseConfigureFileDir="CaseConfigure"
    FinalResultSummaryDir="FinalResult_Summary"
    FinalResultDir="FinalResult"
    SGEIPInfoFile="${SCCTestSpace}/Tools/SGE.cfg"

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

}

runOutputBasicInfo()
{
    echo ""
    echo ""
    echo "*****************************************************************************"
    echo "*****************************************************************************"
    echo         SGE jobs status for SVC
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
    git checkout NewSGEV1.3
    git pull origin NewSGEV1.3

}

runUpdateJobStatus()
{

    ./run_SGEJobStatusUpdate.sh ${SGEJobSubmittedLog} ${AllJobsCompletedFlagFile}>${SGEJobsStatusLog}

    echo ""
    echo "*****************************************************************************"
    echo "   jobs  status ---- SVC"
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
    echo         report for completed jobs ---- SVC
    echo "*****************************************************************************"
    echo ""

    echo >${SGEJobsReportLog}
    for file in ${SVCTestSpace}/${FinalResultDir}/TestReport*
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
        echo         Final summary for all jobs ---- SVC
        echo "*****************************************************************************"
        echo ""
        ./run_GetAllTestResult.sh SGETest ./CaseConfigure/case_SVC.cfg ${AllTestResultPassFlag}
        cat  ${SVCTestSpace}/${FinalResultSummaryDir}/${AllTestSummary}
        cp   ${SVCTestSpace}/${FinalResultSummaryDir}/${AllTestSummary}  ${AttachmentsDir}/${SGEJobsAllTestSummary}
    fi

}
runCopyFilesToAchiveDir()
{
    cd ${CurrentDir}

    cp ${SGEJobsStatusLog}    ${AttachmentsDir}
    cp ${SGEJobsReportLog}    ${AttachmentsDir}

    if [ -e ${SGEJobSubmittedLog} ]
    then
        cp ${SGEJobSubmittedLog} ${AttachmentsDir}/${TestProfile}_${SGEJobSubmittedLog}
    fi
    if [ -e ${CodecInfoLog} ]
    then
        cp ${CodecInfoLog}  ${AttachmentsDir}/${TestProfile}_${CodecInfoLog}
    fi

    if [ -e ${CaseConfigureFileDir}/case_SVC.cfg ]
    then
        cp ${CaseConfigureFileDir}/case_SVC.cfg  ${AttachmentsDir}
    fi

    if [ -e ${CaseConfigureFileDir}/case_SCC.cfg ]
    then
        cp ${CaseConfigureFileDir}/case_SCC.cfg  ${AttachmentsDir}
    fi

    if [ -e ${SGEIPInfoFile} ]
    then
        cp ${SGEIPInfoFile}  ${AttachmentsDir}/SGEIPInfo.txt
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

