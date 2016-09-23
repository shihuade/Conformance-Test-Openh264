#!/bin/bash
#***************************************************************************************
# brief:
#      --delete file or entire folder, instead of using "rm -rf ",
#        use this script to delete file or folder
#
#      -- usage:   
#         ./run_SafeDelere.sh  $DeleteItem
#           
#      -- eg: 1  ./run_SafeDelere.sh  tempdata.info   --->delete only one file
#             2  ./run_SafeDelere.sh  ../TempDataFolder   --->delete entire folder
#                ./run_SafeDelere.sh  /opt/TempData/ABC
#                                     ../../../ABC
#                                     ABC
#
#date:  5/08/2014 Created
#***************************************************************************************
runGlobalInitial()
{
	UserName=`whoami`
	CurrentDir=`pwd`
	FileName="NULL"
	FullPath="NULL"
}

#usage: runUserNameCheck 
runUserNameCheck()
{
	[ ${UserName} = "root" ] && echo -e "\033[31m\n delete files under root is not allowed \033[0m" && exit 1

	return 0
}

#usage: runGetItermInfo  $FilePath
runGetFileName()
{
	[ ! -f ${DeleteItem} ] && echo -e "\033[31m DeleteItem is not a file! \033[0m" && return 1

    FileName=` echo ${DeleteItem} | awk 'BEGIN {FS="/"}; {print $NF}'`

	return 0
}

#******************************************************************************************************
#usage:  runGetFileFullPath  $FileDeleteItem
#eg:  current path is /opt/VideoTest/openh264/ABC
#     runGetFileFullPath  abc.txt                  --->/opt/VideoTest/openh264/ABC
#     runGetFileFullPath  ../123.txt               --->/opt/VideoTest/openh264
#     runGetFileFullPath  /opt/VieoTest/456.txt    --->/opt/VieoTest
#******************************************************************************************************
runGetFileFullPath()
{
    local TempPath="NULL"

	[ ! -f ${DeleteItem} ] && echo -e "\033[31m DeleteItem is not a file! \033[0m" && return 1

    TempPath=`echo ${DeleteItem} |awk 'BEGIN {FS="/"} {for (i=1;i<NF;i++) printf("%s/",$i)}'`
    [ "${TempPath}" = "" ] && TempPath=${CurrentDir}

	#for those permission denied files
    cd ${TempPath} && [ ! $? -eq 0 ] && cd ${CurrentDir} && return 1
    cd ${CurrentDir}
    cd ${TempPath} && FullPath=`pwd` && cd ${CurrentDir} && return 0

}

#******************************************************************************************************
#usage:  runGetFolderFullPath  $FolderDeleteItem
#eg:  current path is /opt/VideoTest/openh264/ABC
#     runGetFolderFullPat   SubFolder             --->/opt/VideoTest/openh264/ABC/ SubFolder
#     runGetFolderFullPat  ../EFG              --->/opt/VideoTest/openh264/EFG
#     runGetFolderFullPat  /opt/VieoTest/MyFolder    --->/opt/VieoTest/MyFolder
#******************************************************************************************************
runGetFolderFullPath()
{
	[ ! -d ${DeleteItem} ] && echo -e "\033[31m DeleteItem is not a folder! \033[0m" && return 1

	#for those permission denied folder
	cd ${DeleteItem} && [ ! $? -eq 0 ] && cd ${CurrentDir} && return 1

    cd ${CurrentDir}
    #get full path
    cd ${DeleteItem} && FullPath=`pwd` && cd ${CurrentDir} && return 0
}

runDeleteItemCheck()
{
	let "CheckFlag=1"
	#get full path
	[ -d $DeleteItem  ]  && runGetFolderFullPath  && let "CheckFlag=$?"
	[ -f $DeleteItem ]   && runGetFileFullPath    && let "CheckFlag=$?"

	if [ ! ${CheckFlag} -eq 0  ]
	then
		echo  -e "\033[31m delete item does not exist or permission denied! \033[0m"
        echo  -e "\033[31m DeleteItem is ${DeleteItem}                      \033[0m"
		exit 1
	fi
	return 0
}

runDirWhiteListCheck()
{
    #white list dir
	HostName=`hostname`
	let "FolderFlag=1"
	[[ ${FullPath} =~ ^/opt/sge62u2_1/SGE_room2 ]] && let "FolderFlag=0"
	[[ ${FullPath} =~ ^/opt/${HostName}  ]]        && let "FolderFlag=0"
	[[ ${FullPath} =~ ^/home/  ]]                  && let "FolderFlag=0"
	[[ ${FullPath} =~ ^/root/  ]]                  && let "FolderFlag=0"
    [[ ${FullPath} =~ ^/Users/  ]]                 && let "FolderFlag=0"

	if [ ! ${FolderFlag} -eq 0 ]
	then
		echo -e "\033[31m deleting item's fullPath is ${FullPath} \033[0m"
		echo -e "\033[31m delete dir is not in the allow list!    \033[0m"
		exit 1
	fi
}

runDirLocationCheck()
{
	#for other non-project folder data protection
	#e.g /opt/VideoTest/DeleteItem ItemDirDepth=4
    ItemDirDepth=`echo ${FullPath} | awk 'BEGIN {FS="/"} {print NF}'`
	if [ $ItemDirDepth -lt 4 ]
	then
		echo -e "\033[31m  deleting item's fullPath is ${FullPath}          \033[0m"
		echo -e "\033[31m  FileDepth does not matched the minimum depth(4)  \033[0m"
		echo -e "\033[31m 	  should looks like /XXX/XXX/XXX/DeleteItem     \033[0m"
		exit  1
	fi
	
	if [ -d ${DeleteItem}  -a "${FullPath}" = "${CurrentDir}" ]
	then
		echo -e "\033[31m DeleteItem is ${DeleteItem}                    \033[0m"
		echo -e "\033[31m trying to delete current dir, it is not allow! \033[0m"
		exit 1
	fi
		
	return 0
}

runDeleteItem()
{
	let "DeleteFlag=0"
	#delete file/folder
	if [ -d $DeleteItem ]
	then
        echo "deleted folder is:  $DeleteItem"
		DeleteItem=${FullPath}
		[ "${DeleteItem}" = "/*"  ] && echo "trying to delete system folder, it is not allow! please double check!" && exit 1

		rm -rf ${DeleteItem}
		let "DeleteFlag=$?"
	elif [ -f $DeleteItem ]
	then		
		runGetFileName
		DeleteItem="${FullPath}/${FileName}"
		echo "deleted file is :  $DeleteItem"
        rm  -f ${DeleteItem}
		let "DeleteFlag=$?"
	fi

	[ ! ${DeleteFlag} -eq 0 ] && echo -e "\033[31m deleted failed! \033[0m" && exit 1

	return 0
}

runOutputParseInfo()
{
	echo "UserName    ${UserName}"
	echo "CurrentDir  ${CurrentDir}"
	echo "DeleteItem  ${DeleteItem}"
	echo "FileName    ${FileName}"
	echo "FullPath    ${FullPath}"
}

#usage runMain $DeleteItem
runMain()
{
	runGlobalInitial

	#user validity check
	#runUserNameCheck  

	#check item exist or not or there is permission denied for current user
	runDeleteItemCheck

	#check that whether item is project file/folder or not
    runDirWhiteListCheck
	runDirLocationCheck

	#delete item
    runDeleteItem

	#output parse info
	runOutputParseInfo
}
#***************************************************************************************
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo "*********************************************************"
if [ ! $# -eq 1  ]
then
    echo "usage runMain \$DeleteItem"
    exit 1
fi

DeleteItem=$1

runMain
#***************************************************************************************
