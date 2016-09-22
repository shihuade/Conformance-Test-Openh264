#!/bin/bash

#***************************************************************************************
# brief: get YUV file's path 
#
# usage:  run_GetYUVPath.sh  ${YUVName}  ${FindScope}
#
#    e.g.: input :run_GetYUVPath.sh ABC_1280X720.yuv /opt/
#          output    /opt/TestYUV.ABC_1280x720.yuv
#
#
#date:  5/08/2014 Created
#***************************************************************************************
#usage: runGetYUVPath  ${YUVName}  ${FindScope}
runGetYUVPath()
{
	local YUVFullPath="NULL"
	local Log="find.result"
	local CurrentDir=`pwd`
	if [ ! -d ${FindScope} ]
	then
		echo "find scope is not right..."
		exit 1
	else
		cd ${FindScope}
		FindScope=`pwd`
		cd ${CurrentDir}
	fi

	find   ${FindScope}  -name  ${YUVName}>${Log}
	while read line
	do
		YUVFullPath=${line}
		if [ -f ${YUVFullPath} ]
		then
		   break
		fi
	done <${Log}


	if [ ${YUVFullPath} = "NULL" ]
	then
		echo "can not find ${YUVName} in folder ${FindScope}"
		echo ${YUVFullPath}
		return 1
	else
		echo ${YUVFullPath}
		return 0
	fi
}
#********************************************************************************************************
if [ ! $# -eq 2 ]
then
    echo "runGetYUVPath  \${YUVName}  \${FindScope} "
    return 1
fi

YUVName=$1
FindScope=$2

runGetYUVPath
#********************************************************************************************************

