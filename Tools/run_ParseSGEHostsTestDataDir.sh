#!/bin/bash
#***************************************************************************************
# brief:
#      --Get SGE host and master test data dir based on configure file
#      --usage:  run_ParseSGEHostsTestDataDir.sh  ${SGEConfigureFile}
#
#
#date: 05/06/2015 Created
#***************************************************************************************


runUsage()
{
    echo ""
    echo -e "\033[31m Usage: run_ParseSGEHostsTestDataDir.sh  \${SGEConfigureFile}   \033[0m"
    echo ""
    echo -e "\033[32m  e.g.: run_ParseSGEHostsTestDataDir.sh  SGE.cfg                \033[0m"
    echo ""
}

runPareseHostTestDataDir()
{
    TempDir=""

    while read line
    do
        # Dir-Host-GuanYu: /home/GuanYu
        if [[ "${line}" =~ "Dir-" ]]
        then
            TempDir=`echo $line     | awk 'BEGIN {FS=":"} {print $2}'`
            aHostTestDataDirList[${HostNum}]="${TempDir}"
            let "HostNum ++"

        fi
    done < ${SGEConfigureFile}

}

runMain()
{

    if [ ! $# -eq 1 ]
    then
        runUsage
        exit 1
    fi

    SGEConfigureFile=$1


    if [ ! -e ${SGEConfigureFile} ]
    then
        runUsage
        echo -e "\033[31m SGEConfigureFile ${SGEConfigureFile} does not exit, please double check! \033[0m"
        exit 1
    fi

    declare -a aHostTestDataDirList
    let "HostNum = 0"

    runPareseHostTestDataDir
    echo ${aHostTestDataDirList[@]}

}

SGEConfigureFile=$1
runMain ${SGEConfigureFile}
