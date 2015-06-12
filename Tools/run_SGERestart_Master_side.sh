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
	echo -e "\033[31m     ./run_SGERestart_Master_side.sh  Restart (for restart all hosts and sge master)  \033[0m"
	echo ""
}
runGlobleInitial()
{	
	aHostNameList=( "GuanYu" \
			"ZhangFei" \
			"ZhaoYun" \
			"MaChao"
			"HuangZhong" \
			"MaDai" \
			"JiangWei")
	aHostIPList=(   "10.224.203.122" \
		        "10.224.203.59"  \
		        "10.224.203.20" \
		        "10.224.203.44" \
			"10.224.203.92"  \
		        "10.224.203.40"  \
		        "10.224.203.38" )
				  
	let " HostNum = ${#aHostNameList[@]}"	

	echo -e "\033[32m initializing ...\033[0m"
	echo ""
	echo "host Number is ${HostNum}"
	echo ""
	echo "host IP list is  ${aHostIPList[@]}"
	echo ""
	echo "host name  list is  ${aHostNameList[@]}"
	CurrentDir=`pwd`
	SGEMasterIP="10.224.203.72"
	SGERestarScriptFolder="/opt/sge62u2_1/SVC_SGE1/common/"
	SGERoomFolder="/opt/sge62u2_1/SVC_SGE1/"
	SGETestBedFolder="/opt/sge62u2_1/SGE_room2/"
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
	echo -e "\033[32m  ********************************************************* \033[0m"
	
	for((i=0; i<${HostNum}; i++))
	do
		echo -e "\033[32m  ********************************************************* \033[0m"
		echo ""
		echo -e "\033[32m  restarting host is ${aHostNameList[$i]}--IP ${aHostIPList[$i]}\033[0m"
		echo ""
		echo -e "\033[34m  ssh log in please input password! \033[0m"
		echo -e "\033[34m  when login the host, please run below command to restart the host! \033[0m"
		echo -e "\033[34m     cd                            \033[0m"
		echo -e "\033[34m     ./run_SGERestart_For_Host_side.sh   \033[0m"
		echo -e "\033[34m     and type exit back to sge master side  \033[0m"
		ssh  ${aHostIPList[$i]}
		
		echo ""
		echo ""
		echo -e "\033[32m  back to sge master now! \033[0m"
		echo -e "\033[32m  restart next host! \033[0m"
		echo -e "\033[32m  ********************************************************* \033[0m"
	
	done
	
	echo ""
	echo -e "\033[32m  all hosts have been restart! \033[0m"
	echo ""
}

runRebootAllSGEHostAndMaster()
{

	runGlobleInitial
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
		ssh  ${aHostIPList[$i]}
		
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
	
	Opption=$1
	
	declare -a aHostNameList
	declare -a aHostIPList
	
	if [ ${Opption} = "Reboot" ]
	then
		runRebootAllSGEHostAndMaster
	elif [ ${Opption} = "Restart" ]
	then
		runRestartSGESystem
	else
		runUasge
	fi

	return 0
}

Opption=$1
runMain ${Opption}

