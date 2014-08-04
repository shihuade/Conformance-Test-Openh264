#!/bin/bash
#get YUV file's full path 
#usage: runGetYUVPath  ${YUVName}  ${FindScope}
runGetYUVPath()
{
	if [ ! $# -eq 2 ]
	then
		echo "runGetYUVPath  \${YUVName}  \${FindScope} "
		return 1
	fi
	local YUVName=$1
	local FindScope=$2
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
<<<<<<< HEAD
=======

>>>>>>> 4220e30995dda0a55e288feab41934377df430ac
}
YUVName=$1
FindScope=$2
runGetYUVPath  ${YUVName}  ${FindScope}


