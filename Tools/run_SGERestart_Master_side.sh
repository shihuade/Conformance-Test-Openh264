#!/bin/bash

#*******************************************************************************************
# brief: for restart or reboot all SGE system on sge-master side
#            
# usage: 
#       --./run_SGERestart_Master_side.sh  Reboot  (for reboot all hosts and sge master)
#       --./run_SGERestart_Master_side.sh  Restart (for restart all hosts and sge master)
#       -- recommend to put this file to /root/ 
#
#  date: 2014/09/15
#*******************************************************************************************


runUasge()
{
	echo ""
	echo -e "\033[31m  usage: \033[0m"
	echo -e "\033[31m     ./run_SGERestart_Master_side.sh  Reboot  (for reboot all hosts and sge master)  \033[0m"
	echo -e "\033[31m     ./run_SGERestart_Master_side.sh  Restart (for restart all hosts and sge master) \033[0m"
	echo ""
}
runGlobleInitial()
{	
    declare -a aHostNameList
    declare -a aHostIPList
    declare -a aAllSGEIPList


	CurrentDir=`pwd`
	SGERestarScriptFolder="/opt/sge62u2_1/SVC_SGE1/common/"
	SGERoomFolder="/opt/sge62u2_1/SVC_SGE1/"
	SGETestBedFolder="/opt/sge62u2_1/SGE_room2/"

    UserName="root"
    ConfigureFile="${CurrentDir}/SGE.cfg"
    ScriptFileName="${CurrentDir}/run_SGERestart_For_Host_side.sh"

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

runNFSRestart()
{
	echo ""
	echo -e "\033[33m restarting the NFS service.....\033[0m"
	echo ""
	/etc/init.d/rpcbind  restart
	/etc/init.d/nfs  restart
}

runSGEMasterRestart()
{
	echo ""
	echo -e "\033[32m sge-master----host name is $HOSTNAME\033[0m"
	echo -e "\033[32m  running start script for sge-master \033[0m"
	echo -e "\033[32m  SGEstart script directory is ${SGERestarScriptFolder}  \033[0m"
	echo -e "\033[32m entering to directory ${SGERestarScriptFolder} ....  \033[0m"
	cd ${SGERestarScriptFolder}
	pwd
	./sgemaster start
	echo -e "\033[32m leaving  directory ${SGERestarScriptFolder},back to ${CurrentDir} ....  \033[0m"
	cd ${CurrentDir}
}



runRestartSGESystem()
{

	runGlobleInitial
    runGetSGEMasterAndHostsInfo

	echo -e "\033[32m  ********************************************************* \033[0m"
	echo -e "\033[32m  restarting sge-qmaster... \033[0m"
	runNFSRestart
	runSGEMasterRestart
	echo -e "\033[32m  ********************************************************* \033[0m"
	
	echo ""
	echo -e "\033[32m  ********************************************************* \033[0m"
	echo ""
	echo "host Number is ${HostNum}"
	echo ""
	echo "host IP list is  ${aHostIPList[@]}"
	echo ""
	echo "host name  list is  ${aHostNameList[@]}"
	echo -e "\033[32m  ********************************************************************** \033[0m"
	
	for((i=0; i<${HostNum}; i++))
	do
		echo -e "\033[32m  ****************************************************************** \033[0m"
		echo ""
		echo -e "\033[32m  Copy files to host side                                            \033[0m"

        scp  ${ConfigureFile}   ${UserName}@${aHostIPList[$i]}:~/
        scp  ${ScriptFileName}  ${UserName}@${aHostIPList[$i]}:~/

        echo ""
        echo -e "\033[32m  ****************************************************************** \033[0m"
        echo ""
        echo -e "\033[32m  restarting host is ${aHostNameList[$i]}--IP ${aHostIPList[$i]}     \033[0m"
		echo ""
		echo -e "\033[34m  ssh log in please input password!                                  \033[0m"
		echo -e "\033[34m  when login the host, please run below command to restart the host! \033[0m"
		echo -e "\033[34m     cd                                                              \033[0m"
		echo -e "\033[34m     ./run_SGERestart_For_Host_side.sh                               \033[0m"
		echo -e "\033[34m     and type exit back to sge master side                           \033[0m"
        ssh  ${UserName}@${aHostIPList[$i]}
		
		echo ""
		echo ""
		echo -e "\033[32m  back to sge master now!                                            \033[0m"
		echo -e "\033[32m  restart next host!                                                 \033[0m"
		echo -e "\033[32m  ****************************************************************** \033[0m"
	
	done
	
	echo ""
	echo -e "\033[32m  all hosts have been restart! \033[0m"
	echo ""
}

runRebootAllSGEHostAndMaster()
{

	runGlobleInitial
    runGetSGEMasterAndHostsInfo

	echo ""
	echo -e "\033[32m  reboot all hosts now \033[0m"
	echo ""
	for((i=0; i<${HostNum}; i++))
	do
		echo -e "\033[32m  ********************************************************* \033[0m"
		echo ""
		echo -e "\033[32m  reboot host is ${aHostNameList[$i]}--IP ${aHostIPList[$i]}\033[0m"
		echo ""
		echo -e "\033[34m  ssh log in please input password! \033[0m"
		echo -e "\033[34m  when login the host, please run below command to reboot the host! \033[0m"
		echo -e "\033[34m     reboot                           \033[0m"
		echo -e "\033[34m     and type exit back to sge master side  \033[0m"
        ssh  ${UserName}@${aHostIPList[$i]}
		
		echo ""
		echo ""
		echo -e "\033[32m  back to sge master now! \033[0m"
		echo -e "\033[32m  reboot next host! \033[0m"
		echo -e "\033[32m  ********************************************************* \033[0m"
	
	done
	
	echo ""
	echo -e "\033[32m  all hosts have been rebooted! \033[0m"
	echo -e "\033[32m  now reboot the sge master. \033[0m"
	echo -e "\033[32m  and please restart the SGE system. \033[0m"
	echo ""
	
}

runMain()
{
	if [ ! $# -eq 1 ]
	then
		runUasge
	fi
	
	Option=$1

	if [ ${Option} = "Reboot" ]
	then
		runRebootAllSGEHostAndMaster
	elif [ ${Option} = "Restart" ]
	then
		runRestartSGESystem
	else
		runUasge
	fi

	return 0
}

Option=$1
runMain ${Option}

