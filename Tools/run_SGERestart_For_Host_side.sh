#!/bin/bash

#************************************************************************************
# brief:
#      --this file is for sge host restart when  the host has been rebooted or  power off 
#
# usage:
#      --1.run under root account
#      --2. just run below command:
#          ./run_SGERestart_For_Host_side.sh
#      --3.if you are using ssh login the host, please type exit back to sge master.
#      --4.recommend to put this script to /root
#
# date: 2014/09/15
#************************************************************************************
runGlobleInitial()
{
        aHostNameList=( "GuanYu" \
                        "GuanYu" \
                        "ZhangFei" \
                        "ZhaoYun" \
                        "MaChao" \
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
                                  
        HostNum=${#aHostIPList[@]}                        
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


runMountSGEFolder()
{
        echo ""
        echo -e "\033[33m mounting SGE's folder.....\033[0m"
        echo ""
        mount ${SGEMasterIP}:${SGERoomFolder}     ${SGERoomFolder}  
        mount ${SGEMasterIP}:${SGETestBedFolder}  ${SGETestBedFolder}
}



runSGEHostRestart()
{
        echo ""
        echo -e "\033[33m  running start script for host----$HOSTNAME \033[0m"
        echo ""
        #run start script
        cd ${SGERestarScriptFolder}
        ./sgeexecd start
        cd ${CurrentDir}

}

runMain()
{

        echo ""
        echo -e "\033[32m current host name is $HOSTNAME\033[0m"
        echo ""

        declare -a aHostNameList
        declare -a aHostIPList

        runGlobleInitial

        runNFSRestart

        runMountSGEFolder

        runSGEHostRestart

        echo ""
        echo -e "\033[32m please type exit back to sge master side if you are using ssh login\033[0m"
        echo ""
        return 0
}
runMain

