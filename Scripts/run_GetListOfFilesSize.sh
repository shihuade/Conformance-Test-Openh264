#!/bin/bash


#****************************************************************
#brief:get list of files' size
#
#usage: run_GetListOfFilesSize.sh file1 file2 ...
#
#
##date:  5/08/2014 Created
#****************************************************************
#usage: runGetFileSize  $FileName
runGetFileSize()
{
	if [ ! -e $1   ]
	then
		echo ""
		echo "file $1 does not exist!"
		echo "usage: runGetFileSize  $FileName!"
		echo ""
		return 1
	fi

	local FileName=$1
	local FileSize=""
	local TempInfo=""
	TempInfo=`ls -l $FileName`
	FileSize=`echo $TempInfo | awk '{print $5}'`
	echo $FileSize

}

#usage: run_GetListOfFilesSize.sh ${File1} ${File2} ......
runMain()
{

	if [  $# -lt 1 ]
	then
		echo ""
		echo "usage: run_GetListOfFilesSize.sh  \${File1} \${File2} ......"
		echo ""
		exit 1
	fi

	local FileNum=$#
	declare -a aFileList
	declare -a aFileSize
	aFileList=( $@ )

	let "FileIndex=0"
	for file in ${aFileList[@]}
	do
		if [ ! -e ${file} ]
		then
			echo ""
			echo  -e "\033[31m file ${file} does not exist! please check \033[0m"
			echo  -e "\033[31m  set size to 0 bit \033[0m"
			echo ""

			aFileList[${FileIndex}]=0

		else
			aFileList[${FileIndex}]=`runGetFileSize  $file`
		fi

		let "FileIndex ++"
	done

	echo ""
	echo  -e "\033[32m file size is:              \033[0m"
	echo  -e "\033[32m       ${aFileList[@]}      \033[0m"
	echo ""

}


FileList=$@
runMain ${FileList}

