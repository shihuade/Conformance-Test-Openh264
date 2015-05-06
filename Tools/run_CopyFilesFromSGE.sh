#!/bin/bash


runUsage()
{

}

runInitial()
{
    HostName=""
    JobID=""
    MasterName=""
    TestType=""




}

runCopyFileFormRemoteHost()
{
    scp ${HostName}@${HostIP}:${SourceDir}/${FileName}  ${DestDir}
}

runCheck()
{

    if [[ $1 =~ "Host-" ]]
    then
        HostName=`echo $1 | awk 'BEGIN {FS="-"} {print $2}'`
        JobID=$2
        HostIP=``

    elif [[ $1 =~ "Master" ]]
    then

    else
        runUsage
        exit 1
    fi


}

runMain()
{
    if  [ $# -lt 3 ]
    then
        runUsage
        exit 1
    fi

    runInitial
    ConfigureFile=$1

    runCheck $1 $2
    runGetSourceIP
    runGetSourceDir

    runCopyFile



}





