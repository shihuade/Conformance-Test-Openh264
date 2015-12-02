#!/bin/bash
#***************************************************************************************
# brief:
#      --Get SGE host and master name based on configure file
#      --usage:  run_ParseSGEHostsName.sh  ${SGEConfigureFile}
#
#
#date: 05/06/2015 Created
#***************************************************************************************


runUsage()
{
    echo ""
    echo -e "\033[31m Usage: run_ParseSGEHostsName.sh  \${SGEConfigureFile}   \033[0m"
    echo ""
    echo -e "\033[32m  e.g.: run_ParseSGEHostsName.sh  SGE.cfg                \033[0m"
    echo ""
}

runPareseHostName()
{
    TempName=""

    while read line
    do
        # IP-Host-GuanYu: 10.224.203.122
        if [[ "${line}" =~ "IP-" ]]
        then
            TempName=`echo $line     | awk 'BEGIN {FS=":"} {print $1}'`
            TempName=`echo $TempName | awk 'BEGIN {FS="-"} {print $3}'`
            aHostNameList[${HostNum}]="${TempName}"
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

    declare -a aHostNameList
    let "HostNum = 0"

    runPareseHostName
    echo ${aHostNameList[@]}

}

SGEConfigureFile=$1
runMain ${SGEConfigureFile}
