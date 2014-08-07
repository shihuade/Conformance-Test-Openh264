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
	DeleteItem="NULL"
	FileName="NULL"
	FullPath="NULL"
}


#usage: runUserNameCheck 
runUserNameCheck()
{

	if [  ${UserName} = "root"  ]
	then
		echo ""
		echo  -e "\033[31m delete files under root is not allowed \033[0m"
		echo  -e "\033[31m detected by run_SafeDelere.sh \033[0m"
		echo ""
		exit 1
	fi
	
	return 0
}

#usage: runGetItermInfo  $FilePath
runGetFileName()
{
	if [ ! -f ${DeleteItem} ]
	then
		echo -e "\033[31m DeleteItem is not a file! \033[0m"
		return 1
	fi
	
	if [[  $DeleteItem  =~ ^"/"  ]]
	then
		FileName=` echo ${DeleteItem} | awk 'BEGIN {FS="/"}; {print $NF}'`
	elif [[  $DeleteItem  =~ ^".."  ]]
	then
		FileName=` echo ${DeleteItem} | awk 'BEGIN {FS="/"}; {print $NF}'`
	elif [[  $DeleteItem  =~ ^"./"  ]]
	then
		FileName=` echo ${DeleteItem} | awk 'BEGIN {FS="/"}; {print $NF}'`
	else
		FileName=` echo ${DeleteItem} | awk 'BEGIN {FS="/"}; {print $NF}'`
	fi
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
	
	if [ ! -f ${DeleteItem} ]
	then
		echo -e "\033[31m DeleteItem is not a file! \033[0m"
		return 1
	fi
	
	local TempPath="NULL"
	if [[  $DeleteItem  =~ ^"/"  ]]
	then
		TempPath=`echo ${DeleteItem} |awk 'BEGIN {FS="/"} {for (i=1;i<NF;i++) printf("%s/",$i)}'`
	elif [[  $DeleteItem  =~ ^".."  ]]
	then
		TempPath=`echo ${DeleteItem} |awk 'BEGIN {FS="/"} {for (i=1;i<NF;i++) printf("%s/",$i)}'`
	elif [[ $DeleteItem  =~ ^"./" ]]
	then
		TempPath=`echo ${DeleteItem} |awk 'BEGIN {FS="/"} {for (i=1;i<NF;i++) printf("%s/",$i)}'`
	elif [[ $DeleteItem  =~ "/" ]]
	then
		TempPath=`echo ${DeleteItem} |awk 'BEGIN {FS="/"} {for (i=1;i<NF;i++) printf("%s/",$i)}'`
	else
		TempPath=${CurrentDir}
	fi
	
	#for those permission denied files
	cd ${TempPath}
	if [ ! $? -eq 0 ]
	then
		cd ${CurrentDir}
		exit 1
	else
		FullPath=`pwd`
		cd ${CurrentDir}
		return 0
	fi

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

	if [ ! -d ${DeleteItem} ]
	then
		echo -e "\033[31m DeleteItem is not a folder! \033[0m"
		return 1
	fi 
	
	#for those permission denied folder
	cd ${DeleteItem}
	if [ ! $? -eq 0 ]
	then
		cd ${CurrentDir}
		return 1
	fi
	cd ${CurrentDir}
	
	if [[  $DeleteItem  =~ ^"/"  ]]
	then
		FullPath=${DeleteItem}
		cd ${FullPath}
		FullPath=`pwd`
		cd ${CurrentDir}
	elif [[  $DeleteItem  =~ ^"../"  ]]
	then
		cd ${DeleteItem}
		FullPath=`pwd`
		cd ${CurrentDir}
	elif [[  $DeleteItem  =~ ^"./"  ]]
	then
		cd ${DeleteItem}
		FullPath=`pwd`
		cd ${CurrentDir}
	else
		cd $DeleteItem
		FullPath=`pwd`
		cd ${CurrentDir}
	fi
	
	return 0	
}


runDeleteItemCheck()
{
	let "CheckFlag=0"
	#get full path
	if [  -d $DeleteItem  ]
	then
		runGetFolderFullPath  
		let "CheckFlag=$?"
	elif [ -f $DeleteItem ]
	then
		runGetFileFullPath 
		let "CheckFlag=$?"
	else
		let "CheckFlag=1"
	fi
	
	if [ ! ${CheckFlag} -eq 0  ]
	then
		echo  -e "\033[31m delete item does not exist or permission denied! \033[0m"
		echo  -e "\033[31m please double check!  \033[0m"
		echo  -e "\033[31m detected by run_SafeDelere.sh \033[0m"
		exit 1
	fi

	return 0
}

runFolderLocationCheck()
{
	local ItemDirDepth=`echo ${FullPath} | awk 'BEGIN {FS="/"} {print NF}'`

	#only item  under  /home/, /root/, /opt/ can be delete!
	let "FolderFlag=0"
	if [[ ${FullPath} =~ ^/root/  ]]
	then
		let "FolderFlag=0"
	elif [[ ${FullPath} =~ ^/home/  ]]
	then
		let "FolderFlag=0"
	elif [[ ${FullPath} =~ ^/opt/  ]]
	then
		let "FolderFlag=0"
	else
		let "FolderFlag=1"
	fi
	
	if [ ! ${FolderFlag} -eq 0 ]
	then
		echo ""
		echo -e "\033[31m only item  under  /home/xxx, /root/xxx, /opt/xxx can be delete, please double check!  \033[0m"
		echo -e "\033[31m detected by run_SafeDelere.sh \033[0m"
		exit 1		
	fi	
	
	
	#for other non-project folder data protection
	#e.g /opt/VideoTest/DeleteItem depth=4
	if [  $ItemDirDepth -lt 5 ]
	then
		echo ""
		echo -e "\033[31m FullPath is ${FullPath} \033[0m"
		echo -e "\033[31m FileDepth is  $ItemDirDepth not matched the minimum depth(5) \033[0m"
		echo -e "\033[31m unsafe delete! try to delete non-project items: $FullPath \033[0m"
		echo -e "\033[31m detected by run_SafeDelere.sh \033[0m"
		exit  1
	fi
	
	if [   -d ${DeleteItem}  -a "${FullPath}" = "${CurrentDir}"  ]
	then
		echo ""
		echo -e "\033[31m DeletingPatth--CurrentPath: ${FullPath} -- ${CurrentDir} \033[0m"
		echo -e "\033[31m trying to delete current dir, it is not allow! \033[0m"
		echo -e "\033[31m detected by run_SafeDelere.sh \033[0m"
		exit 1
	fi
		
	return 0
}

runDeleteItem()
{
	let "DeleteFlag=0"
	#delete file/folder
	if [  -d $DeleteItem  ]
	then
		DeleteItem=${FullPath}
		if [ "${DeleteItem}" = "/*"  ]
		then
			echo "DeleteItem is ${DeleteItem}"
			echo "trying to delete system folder, it is not allow! please double check!"
			exit 1
		fi
		
		echo "deleted folder is:  $DeleteItem"
		rm -rf ${DeleteItem}
		let "DeleteFlag=$?"
	elif [ -f $DeleteItem ]
	then		
		runGetFileName
		DeleteItem="${FullPath}/${FileName}"
		echo "deleted file is :  $DeleteItem"
		rm  ${DeleteItem}
		let "DeleteFlag=$?"
	fi

	if [ ! ${DeleteFlag} -eq 0 ]
	then
		echo -e "\033[31m deleted failed! \033[0m"
		exit 1
	fi
	
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
	#parameter check!
	if [ ! $# -eq 1  ]
	then
		echo "usage runMain \$DeleteItem"
		return 1
	fi

	runGlobalInitial
	DeleteItem=$1
	
	#user validity check
	runUserNameCheck  
	
	#check item exist or not or there is permission denied for current user
	runDeleteItemCheck

	#check that whether item is project file/folder or not 
	runFolderLocationCheck
	
	
	#delete item
	runDeleteItem
	
	#output parse info
	#runOutputParseInfo

}
DeleteItem=$1
echo ""
runMain $DeleteItem
echo ""


