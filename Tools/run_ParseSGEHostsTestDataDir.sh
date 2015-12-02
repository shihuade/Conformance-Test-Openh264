#!/bin/bash
#***************************************************************************************
# brief:
#      --Get SGE host and master test data dir based on configure file
#      --usage:  run_ParseSGEHostsTestDataDir.sh  ${SGEConfigureFile} ${HostName}
#
#
#date: 05/06/2015 Created
#***************************************************************************************


runUsage()
{
    echo ""
    echo -e "\033[31m Usage: run_ParseSGEHostsTestDataDir.sh  \${SGEConfigureFile}                \033[0m"
    echo -e "\033[31m                                         \${HostName}                        \033[0m"
    echo ""
    echo -e "\033[32m  e.g.: get all:        run_ParseSGEHostsTestDataDir.sh  SGE.cfg  All        \033[0m"
    echo -e "\033[32m  e.g.: get Master-SCC: run_ParseSGEHostsTestDataDir.sh  SGE.cfg  Master-SCC \033[0m"
    echo -e "\033[32m  e.g.: get Master-SVC: run_ParseSGEHostsTestDataDir.sh  SGE.cfg  Master-SVC \033[0m"
    echo ""
    echo -e "\033[32m  e.g.: get GuanYU: run_ParseSGEHostsTestDataDir.sh  SGE.cfg  Host-GuanYu    \033[0m"
    echo -e "\033[32m  e.g.: get MaChao: run_ParseSGEHostsTestDataDir.sh  SGE.cfg  Host-MaChao    \033[0m"
   echo ""
}

runPareseHostTestDataDir()
{
    TempDir=""

    while read line
    do
        # Dir-Host-GuanYu: /home/GuanYu
        if [[ "${line}" =~ "${ParsPatern}" ]]
        then
            TempDir=`echo $line     | awk 'BEGIN {FS=":"} {print $2}'`
            aHostTestDataDirList[${HostNum}]="${TempDir}"
            let "HostNum ++"

        fi
    done < ${SGEConfigureFile}

}

runGetParsePattern()
{
    if [[ ${HostName} =~ "All"  ]]
    then
        ParsPatern="Dir-"
    elif [[ ${HostName} =~ "Master-"  ]]
    then
        ParsPatern="Dir-${HostName}"
    elif [[ ${HostName} =~ "Host-"  ]]
    then
        ParsPatern="Dir-${HostName}"
    fi
}

runMain()
{

    if [ ! $# -eq 2 ]
    then
        runUsage
        exit 1
    fi

    SGEConfigureFile=$1
    HostName=$2
    ParsPatern=""


    if [ ! -e ${SGEConfigureFile} ]
    then
        runUsage
        echo -e "\033[31m SGEConfigureFile ${SGEConfigureFile} does not exit, please double check! \033[0m"
        exit 1
    fi

    declare -a aHostTestDataDirList
    let "HostNum = 0"

    runGetParsePattern
    runPareseHostTestDataDir

    echo ${aHostTestDataDirList[@]}


}

SGEConfigureFile=$1
HostName=$2
runMain ${SGEConfigureFile} ${HostName}
