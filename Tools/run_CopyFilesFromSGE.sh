#!/bin/bash
#***************************************************************************************
# brief:
#      --copy file from SGE host/master  based on configure file
#      --usage:  run_CopyFilesFromSGE.sh  ${HostOption} \
#                                         \${JobIDOrTestProfile}  \
#                                         \${FileName}  \
#                                         \${DestDir}
#
#date: 05/06/2015 Created
#***************************************************************************************


runUsage()
{
    echo ""
    echo -e "\033[31m Usage: run_CopyFilesFromSGE.sh  \${HostOption}          \033[0m"
    echo -e "\033[31m                                 \${JobIDOrTestProfile}  \033[0m"
    echo -e "\033[31m                                 \${FileName}            \033[0m"
    echo -e "\033[31m                                 \${DestDir}             \033[0m"
    echo ""
    echo -e "\033[32m  e.g.: run_CopyFilesFromSGE.sh  Host-GuanYu 733 "*.csv"  ./TestData             \033[0m"
    echo -e "\033[32m        copy all .csv test result files from host GuanYU with SGE job ID 733     \033[0m"
    echo ""
    echo -e "\033[32m  e.g.: run_CopyFilesFromSGE.sh  Host-GuanYu 733  test.Summary.log ./TestData    \033[0m"
    echo -e "\033[32m        copy all test.Summary.log file from host GuanYU with SGE job ID 733      \033[0m"
    echo ""
    echo -e "\033[32m  e.g.: run_CopyFilesFromSGE.sh  Master  SVC  "*.csv"  ./AllSVCTestData          \033[0m"
    echo -e "\033[32m        copy all .csv test result files in folder ./FinalResult from SGE master  \033[0m"
    echo ""
    echo -e "\033[32m  e.g.: run_CopyFilesFromSGE.sh  Master  SCC  "*.csv"  ./AllSCCTestData          \033[0m"
    echo -e "\033[32m        copy all test .csv result files in folder ./FinalResult from SGE master  \033[0m"
    echo ""
    echo -e "\033[32m  Test data dir for host   is /home/\${HostName}/SGEJobID_\${JobID}/result       \033[0m"
    echo -e "\033[32m  Test data dir for master is /\${TestSpace}\Finalresult                         \033[0m"
    echo ""
}


runInitial()
{
    HostName=""
    JobID=""
    TestType=""

    RemoteIP=""
    RemoteSourceDir=""
    RemoteSourceFilePath=""
    RemoteUser="root"
    ConfigureFile="SGE.cfg"
    CurrentDir=`pwd`
    TempDestDir="TempTestData"
    HostDataFolder="result"
    MasterFolder="FinalResult"

}

runCopyFileFormRemoteHost()
{
    echo "scp ${RemoteUser}@${RemoteIP}:${RemoteSourceFilePath}  ${DestDir}"
    scp ${RemoteUser}@${RemoteIP}:${RemoteSourceFilePath}  ${DestDir}
}

runRemoteInfoCheck()
{
    if [ "${RemoteIP}" = "" ]
    then
        echo ""
        echo -e "\033[31m Remote IP can not find, please configure in the SGE.cfg file!   \033[0m"
        echo -e "\033[31m  host name is ${HostName}   \033[0m"
        echo ""
        runUsage
        exit 1
    elif [[ "${RemoteIP}" =~ " " ]]
    then

        echo ""
        echo -e "\033[31m  Multiple IP of Remote host is not support, please use single remote host!   \033[0m"
        echo -e "\033[31m  RemoteIP is ${RemoteIP}   \033[0m"
        echo ""
        runUsage
        exit 1
    fi

    if [ "${RemoteSourceDir}" = "" ]
    then
        echo ""
        echo -e "\033[31m Remote host source dir can not find, please configure in the SGE.cfg file!   \033[0m"
        echo -e "\033[31m  host name is ${HostName}   \033[0m"
        echo ""
        runUsage
        exit 1
    elif [[ "${RemoteSourceDir}" =~ " " ]]
    then
        echo ""
        echo -e "\033[31m  Multiple RemoteSourceDir of Remote host is not support, please use single remote host!   \033[0m"
        echo -e "\033[31m  RemoteSourceDir is ${RemoteSourceDir}   \033[0m"
        echo ""
        runUsage
        exit 1
    fi
}
runParseInputOption()
{

    if [[ "${HostOption}" =~ "Host-" ]]
    then
        HostName=`echo $HostOption | awk 'BEGIN {FS="-"} {print $2}'`
        JobID=${JobIDOrTestProfile}
        RemoteIP=`./run_ParseSGEHostsIP.sh  ${ConfigureFile}  ${HostOption} `
        RemoteSourceDir=`./run_ParseSGEHostsTestDataDir.sh  ${ConfigureFile}  ${HostOption} `
        RemoteSourceFilePath="${RemoteSourceDir}/SGEJobID_${JobID}/${HostDataFolder}/${FileName}"

    elif [[ "${HostOption}" =~ "Master" ]]
    then
        HostName="Master-LiuBei"
        TestType=${JobIDOrTestProfile}
        RemoteIP=`./run_ParseSGEHostsIP.sh  ${ConfigureFile}  Master `
        #Dir-Master-LiuBei-SCC
        RemoteSourceDir=`./run_ParseSGEHostsTestDataDir.sh   ${ConfigureFile}  "Master-${TestType}" `
        RemoteSourceFilePath="${RemoteSourceDir}/${MasterFolder}/${FileName}"
    else
        echo -e "\033[31m option error!  \033[0m"
        runUsage
        exit 1
    fi

}

runCheck()
{
    if [ ! -e ${ConfigureFile}  ]
    then
        echo ""
        echo -e "\033[31m ConfigureFile ${ConfigureFile} does not exist, please double check!   \033[0m"
        echo ""
        exit 1
    fi

    if [ "${DestDir}" = "" ]
    then
        DestDir=${CurrentDir}
    elif [ -d "${DestDir}"  ]
    then
        cd ${DestDir}
        DestDir=`pwd`
        cd ${CurrentDir}
    else
        echo ""
        echo -e "\033[31m DestDir ${DestDir} does not exist, please double check!   \033[0m"
        echo ""
        exit 1
    fi
}

runMain()
{
    runInitial
    runCheck
    runParseInputOption
    runRemoteInfoCheck
    runCopyFileFormRemoteHost

}

HostOption=$1
JobIDOrTestProfile=$2
FileName=$3
DestDir=$4
echo "FileName is ${FileName}"
if  [ $# -lt 3 ]
then
    runUsage
    exit 1
fi
runMain
