#!/bin/bash
#***************************************************************************************
# brief: get file's path
#
# usage:  run_SearchFileAndGetFullPath.sh  ${FileName}  ${FindScope}
#
# e.g.: input :    run_SearchFileAndGetFullPath.sh  ABC_1280X720.yuv /opt/
#       output:    /opt/TestYUV.ABC_1280x720.yuv
#
#
#date:  5/06/2015 Created
#***************************************************************************************
runUsage()
{
    echo ""
    echo -e "\033[31m Usage: run_SearchFileAndGetFullPath.sh \${FileName}         \033[0m"
    echo -e "\033[31m                                        \${FindScope}        \033[0m"
    echo ""
    echo -e "\033[32m  e.g.: run_SearchFileAndGetFullPath.sh  ABC_1280X720 /opt/  \033[0m"
    echo -e "\033[32m        output:  /opt/TestYUV.ABC_1280x720.yuv               \033[0m"
    echo ""
}

runCheck()
{
	if [ ! -d ${FindScope} ]
	then
		echo "find scope is not right..."
		exit 1
	else
		cd ${FindScope}
		FindScope=`pwd`
		cd ${CurrentDir}
	fi
}

runGetFileFullPath()
{
	find   ${FindScope}  -name  ${FileName}>${Log}

	while read line
	do
		FileFullPath=${line}
		if [ -f ${FileFullPath} ]
		then
		   break
		fi
	done <${Log}


	if [ ${FileFullPath} = "NULL" ]
	then
		echo "can not find ${FileName} in folder ${FindScope}"
		echo ${FileFullPath}
		return 1
	else
		echo ${FileFullPath}
		return 0
	fi
}


runMain()
{
    if [ ! $# -eq 2 ]
    then
        runUsage
        exit 1
    fi

    FileName=$1
    FindScope=$2
    FileFullPath="NULL"
    Log="GetFileFullPath.log"
    CurrentDir=`pwd`

    runCheck
    runGetFileFullPath

}

FileName=$1
FindScope=$2
runMain  ${FileName}  ${FindScope}


