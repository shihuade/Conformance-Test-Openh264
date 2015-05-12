#!/bin/bash
#***********************************************
#  script used in jenkins job confiugre
#
#***********************************************


JenkinsHomeDir="/Users/jenkins"
AttachmentsFolder="Openh264-SGETest/Jenkins-Job-Status-Check-Log"
AttachmentsDir="${JenkinsHomeDir}/${AttachmentsFolder}"
SCCTestSpace="/opt/sge62u2_1/SGE_room2/OpenH264ConformanceTest/NewSGE-SCC-Test"
SVCTestSpace="/opt/sge62u2_1/SGE_room2/OpenH264ConformanceTest/NewSGE-SVC-Test"
FinalResultDir="FinalResult"

#log file for attachments
SGEJobSubmittedLog="SGEJobsSubmittedInfo.log"
SCCStatusLog="SCCSGEJobStatus.txt"
SVCStatusLog="SVCSGEJobStatus.txt"
SCCJobReportLog="SCCJobReport.txt"
SVCJobReportLog="SVCJobReport.txt"
AllTestSummary="AllTestYUVsSummary.txt"
SCCAllTestSummary="AllTestYUVsSummary_SCC.txt"
SCCAllTestSummary="AllTestYUVsSummary_SVC.txt"
AllJobsCompletedFlagFile="AllSGEJobsCompleted.flag"
AllTestResultPassFlag="AllCasesPass.flag"

#SGE environment configuration
#*******************************************
PATH=$PATH:$HOME/bin:/opt/sge62u2_1:/opt/sge62u2_1/bin/lx24-x86:/opt/SDK/bin:/opt/SDK
SGE_ROOT=/opt/sge62u2_1;export SGE_ROOT
SGE_CELL=SVC_SGE1;export SGE_CELL
SGE_QMASTER_PORT="10536";export SGE_QMASTER_PORT
SGE_EXECD_PORT="10537";export SGE_EXECD_PORT
JAVA_HOME=/opt/SDK;export JAVA_HOME
PATH=$PATH:$SGE_ROOT/bin
export PATH
#*******************************************


#basic info
echo "***********************************"
pwd
if [ -d ${AttachmentsDir} ]
then
${SCCTestSpace}/Scripts/run_SafeDelete.sh ${AttachmentsDir}
fi
mkdir -p ${AttachmentsDir}
echo "***********************************"

echo ""
echo ""
echo "*****************************************************************************"
echo "*****************************************************************************"
echo         SGE jobs status for SVC
echo "*****************************************************************************"
echo "*****************************************************************************"
echo ""
echo ""
cd ${SVCTestSpace}
pwd

git fetch origin
git checkout NewSGEV1.2
git pull origin NewSGEV1.2

./run_SGEJobStatusUpdate.sh ${SGEJobSubmittedLog} ${AllJobsCompletedFlagFile}>${SVCStatusLog}
cat ${SVCStatusLog}
echo ""
echo "*****************************************************************************"
echo         report for completed jobs ---- SVC
echo "*****************************************************************************"
echo ""
echo >${SVCJobReportLog}
for file in ${SVCTestSpace}/${FinalResultDir}/TestReport*
do
if [ -e ${file} ]
then
cat ${SVCTestSpace}/${FinalResultDir}/TestReport* >>${SVCJobReportLog}
fi
done
cat ${SVCJobReportLog}
#get summary
if [ -e ${AllJobsCompletedFlagFile} ]
then
echo ""
echo "*****************************************************************************"
echo         Final summary for all jobs ---- SVC
echo "*****************************************************************************"
echo ""
./run_GetAllTestResult.sh SGETest ./CaseConfigure/case_SVC.cfg ${AllTestResultPassFlag}
cat  ${SVCTestSpace}/${FinalResultDir}/${AllTestSummary}
cp   ${SVCTestSpace}/${FinalResultDir}/${AllTestSummary}  ${AttachmentsDir}/${SVCAllTestSummary}
fi
cp ${SVCStatusLog}       ${AttachmentsDir}
cp ${SVCJobReportLog}    ${AttachmentsDir}
cp ${SGEJobSubmittedLog} ${AttachmentsDir}/SVC_${SGEJobSubmittedLog}



echo ""
echo ""
echo "*****************************************************************************"
echo "*****************************************************************************"
echo         SGE jobs status for SCC
echo "*****************************************************************************"
echo "*****************************************************************************"
echo ""
echo ""
cd ${SCCTestSpace}

git fetch origin
git checkout NewSGEV1.2
git pull origin NewSGEV1.2

pwd
./run_SGEJobStatusUpdate.sh ${SGEJobSubmittedLog} ${AllJobsCompletedFlagFile}>${SCCStatusLog}
cat ${SCCStatusLog}
echo ""
echo "*****************************************************************************"
echo         report for completed jobs ---- SCC
echo "*****************************************************************************"
echo ""
echo >${SCCJobReportLog}
for file in ${SCCTestSpace}/${FinalResultDir}/TestReport*
do
if [ -e ${file} ]
then
cat ${SCCTestSpace}/${FinalResultDir}/TestReport* >>${SCCJobReportLog}
fi
done
cat ${SCCJobReportLog}
#get summary
if [ -e ${AllJobsCompletedFlagFile} ]
then
echo ""
echo "*****************************************************************************"
echo         Final summary for all jobs ---- SCC
echo "*****************************************************************************"
echo ""
./run_GetAllTestResult.sh SGETest ./CaseConfigure/case_SCC.cfg ${AllTestResultPassFlag}
cat  ${SCCTestSpace}/${FinalResultDir}/${AllTestSummary}
cp   ${SCCTestSpace}/${FinalResultDir}/${AllTestSummary}  ${AttachmentsDir}/${SCCAllTestSummary}
fi
cp ${SCCStatusLog}       ${AttachmentsDir}
cp ${SCCJobReportLog}    ${AttachmentsDir}
cp ${SGEJobSubmittedLog} ${AttachmentsDir}/SCC_${SGEJobSubmittedLog}



