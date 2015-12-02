#!/bin/bash
#***************************************************************************************
# brief:
#      --Get SGE host and master IP based on configure file
#      --usage:  run_ParseSGEHostsIP.sh  ${SGEConfigureFile}
#
#
#date: 05/06/2015 Created
#***************************************************************************************


runUsage()
{
    echo ""
    echo -e "\033[31m Usage: run_ParseSGEHostsIP.sh  \${SGEConfigureFile}              \033[0m"
    echo -e "\033[31m                                 \${HostName}                     \033[0m"
    echo ""
    echo -e "\033[32m  e.g.: get all:    run_ParseSGEHostsIP.sh  SGE.cfg  All          \033[0m"
    echo -e "\033[32m  e.g.: get Master: run_ParseSGEHostsIP.sh  SGE.cfg  Master       \033[0m"
    echo -e "\033[32m  e.g.: get GuanYU: run_ParseSGEHostsIP.sh  SGE.cfg  Host-GuanYu  \033[0m"
    echo -e "\033[32m  e.g.: get GuanYU: run_ParseSGEHostsIP.sh  SGE.cfg  Host-ZhaoYun \033[0m"
    echo ""
    echo ""
}

runPareseHostIP()
{
    TempIP=""

    while read line
    do
        # IP-Host-GuanYu: 10.224.203.122
        if [[ "${line}" =~ "${ParsPatern}" ]]
        then
            TempIP=`echo $line     | awk 'BEGIN {FS=":"} {print $2}'`
            aHostIPList[${HostNum}]="${TempIP}"
            let "HostNum ++"

        fi
    done < ${SGEConfigureFile}

}
runGetParsePattern()
{
    if [[ ${HostName} =~ "All"  ]]
    then
        ParsPatern="IP-"
    elif [[ ${HostName} =~ "Master"  ]]
    then
        ParsPatern="IP-Master"
    elif [[ ${HostName} =~ "Host"  ]]
    then
        ParsPatern="IP-${HostName}"
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

    declare -a aHostIPList
    let "HostNum = 0"

    runGetParsePattern
    runPareseHostIP
    echo ${aHostIPList[@]}

}

SGEConfigureFile=$1
HostName=$2
runMain ${SGEConfigureFile} ${HostName}
