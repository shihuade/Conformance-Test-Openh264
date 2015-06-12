#!/bin/bash

#*******************************************************************************************
# brief: ssh auto login setting between master and hosts
#            
# usage: 
#        --setting for master side
#          ./run_SSHServerHostAutoLogSetting.sh Master
#        --setting for host side
#          ./run_SSHServerHostAutoLogSetting.sh Host
#
#  date: 2015/06/12
#*******************************************************************************************


runUasge()
{
	echo ""
	echo -e "\033[31m  Usage:                                          \033[0m"
    echo ""
    echo -e "\033[31m  --setting for master side                       \033[0m"
    echo -e "\033[31m     ./run_SSHServerHostAutoLogSetting.sh Master  \033[0m"
    echo ""
    echo -e "\033[31m  --setting for host side                         \033[0m"
    echo -e "\033[31m     ./run_SSHServerHostAutoLogSetting.sh Host    \033[0m"
    echo ""
}
runGlobleInitial()
{
    declare -a aHostNameList
    declare -a aHostIPList
    declare -a aAllSGEIPList

    CurrentDir=`pwd`
    UserName="root"
    ConfigureFile="${CurrentDir}/SGE.cfg"
    ScriptFileName="${CurrentDir}/run_SSHServerHostAutoLogSetting.sh"

    if [ ! -e ${onfigureFile} ]
    then
        echo ""
        echo -e "\033[31m configure file does not exist,please double check! \033[0m"
        echo -e "\033[31m configure file is ${ConfigureFile} \033[0m"
        echo ""
        exit 1
    fi

}

runGetSGEMasterAndHostsInfo()
{

    aAllSGEIPList=(`./run_ParseSGEHostsIP.sh   ${ConfigureFile}  All `)
    SGEMasterIP=(`./run_ParseSGEHostsIP.sh     ${ConfigureFile}  Master `)
    aHostNameList=(`./run_ParseSGEHostsName.sh ${ConfigureFile} `)

    let " HostNum = ${#aHostNameList[@]}"

    echo ""
    echo "host Number is ${HostNum}"
    echo ""
    for((i=0;i<${HostNum};i++))
    do
        let "j=i+1"
        aHostIPList[$i]=${aAllSGEIPList[$j]}
        echo "HostName--${aHostNameList[$i]}----IP--${aHostIPList[$i]}"
    done

}

runSettingInServerSide()
{
    echo -e "\033[32m  ******************************************************************** \033[0m"
    for((i=0;i<${HostNum};i++))
    do
        echo -e "\033[32m  host name: ${aHostNameList[$i]}!  \033[0m"
        echo -e "\033[32m  creat .ssh folder in host side!   \033[0m"
        echo ""
        ssh ${UserName}@${aHostIPList[$i]} "mkdir .ssh"

        echo -e "\033[32m  copy files from server sinde  \033[0m"
        echo ""
        scp  ~/.ssh/id_rsa.pub    ${UserName}@${aHostIPList[$i]}:.ssh/id_rsa.pub
        scp  ${ScriptFileName}    ${UserName}@${aHostIPList[$i]}:~/
        scp  ${ConfigureFile}     ${UserName}@${aHostIPList[$i]}:~/

    done

    echo -e "\033[32m  ******************************************************************** \033[0m"

}

runSettingInHostSide()
{
    HostUserName=`whoami`
    echo -e "\033[32m  ******************************************************************** \033[0m"
    echo -e "\033[32m  "  HostUserName is ${HostUserName} " \033[0m"
    echo -e "\033[32m  ******************************************************************** \033[0m"

    echo -e "\033[32m   Updating authorized_keys info                      \033[0m"
    echo -e "\033[32m   touch ~/.ssh/authorized_keys                       \033[0m"
    echo -e "\033[32m   cat   ~/.ssh/id_rsa.pub  >> ~/.ssh/authorized_keys \033[0m"
    touch ~/.ssh/authorized_keys
    cat   ~/.ssh/id_rsa.pub  >> ~/.ssh/authorized_keys

}

runSettingForAllHost()
{
    echo -e "\033[32m  ******************************************************************** \033[0m"
    for((i=0;i<${HostNum};i++))
    do
        echo -e "\033[32m  host name: ${aHostNameList[$i]}!                    \033[0m"
        echo ""
        echo -e "\033[32m  login host and set in host side                     \033[0m"
        echo ""
        echo -e "\033[32m  please run below comand                             \033[0m"
        echo -e "\033[32m  ./run_SSHServerHostAutoLogSetting.sh Host           \033[0m"
        echo ""
        echo -e "\033[32m  and type exit to back to master side for next host  \033[0m"
        echo ""

        ssh ${UserName}@${aHostIPList[$i]}
    done

    echo -e "\033[32m  ******************************************************************** \033[0m"
}

runMasterSide()
{

    runSettingInServerSide
    runSettingForAllHost
    echo -e "\033[32m  ******************************************************************** \033[0m"
    echo -e "\033[32m    all ssh setting for master-hasts auto longin have been completed!  \033[0m"
    echo -e "\033[32m  ******************************************************************** \033[0m"

}

runHostSide()
{
    runSettingInHostSide

    echo -e "\033[32m  ******************************************************************** \033[0m"
    echo -e "\033[32m    host seting for ${HostUserName} completed! \033[0m"
    echo -e "\033[32m  ******************************************************************** \033[0m"

}

runMain()
{
	if [ ! $# -eq 1 ]
	then
		runUasge
	fi
	
	Option=$1

    runGlobleInitial
    runGetSGEMasterAndHostsInfo

	if [ ${Option} = "Master" ]
	then
		runMasterSide
	elif [ ${Option} = "Host" ]
	then
		runSettingInHostSide
	else
		runUasge
	fi

	return 0
}

Option=$1
runMain ${Option}

