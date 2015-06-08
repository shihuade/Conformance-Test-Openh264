#/bin/bash

runUsage()
{
	echo -e "\033[32m **************--usage--************************************************************ \033[0m"
    echo ""
	echo -e "\033[32m  --./run_BackupTestData.sh \${YourTestDataDir} \${PrefixForBackupFolderName}        \033[0m"
    echo ""
    echo -e "\033[32m  e.g.:                                                                              \033[0m"
    echo -e "\033[32m  --./run_BackupTestData.sh  ./   SCC_V1.3                                           \033[0m"
    echo ""
    echo -e "\033[32m  backup folder will be:                                                             \033[0m"
    echo -e "\033[32m   /home/SGETestBackUp/openh264/\${PreFixInfo}_ConformanceTest_\${DateInfo}          \033[0m"
    echo ""
    echo -e "\033[32m   /home/SGETestBackUp/openh264/SCC_V1.3_ConformanceTest-Fri-Mar-6-21:02:01-CST-2015 \033[0m"
   echo ""
	echo -e "\033[32m *********************************************************************************** \033[0m"
}

runGenerateCodecCommitInfo()
{
	cd ${TestSpaceDir}/${SourceFolder}
	echo "***************************************"
	echo "***********branch info**********"
	echo ""
	git branch
	echo ""
	echo ""
	echo "***********commit info**********"
	echo ""
	git log -2
	echo ""	
	echo "***************************************"
	cd ${CurrentDir}
}

runGenerateDateInfo()
{
	date
	TempDateInfo=`date`
	TempDateInfo=`echo ${TempDateInfo} | awk 'BEGINE {FS="[ ]"} {for(i=1;i<=NF;i++)printf("-%s",$i)}'`
	DateInfo=${TempDateInfo}
}


runFolderCheck()
 {
	if [ ! -d ${TestSpaceDir}  ]
	then
		echo -e "\033[31m  TestSpaceDir----${TestSpaceDir} dose not exist, please double check! \033[0m"
		exit 1
	else
		cd ${TestSpaceDir}
		TestSpaceDir=`pwd`
		cd ${CurrentDir}
	fi
	
	if [ ! -d ${TestSpaceDir}/${SourceFolder}  ]
	then
		echo -e "\033[31m SourceFolder----${TestSpaceDir}/${SourceFolder}  dose not exist, please double check! \033[0m"
		exit 1
	fi
	
	if [ ! -d ${TestSpaceDir}/${CodecFolder}  ]
	then
		echo -e "\033[31m CodecFolder----${TestSpaceDir}/${CodecFolder}  dose not exist, please double check! \033[0m"
		exit 1
	fi
	
	if [ ! -d ${TestSpaceDir}/${ConfigureFolder}  ]
	then
		echo -e "\033[31m ConfigureFolder----${TestSpaceDir}/${ConfigureFolder}  dose not exist, please double check! \033[0m"
		exit 1
	fi	
	
	if [ ! -d ${TestSpaceDir}/${FinalResultFolder}  ]
	then
		echo -e "\033[31m FinalResultFolder----${TestSpaceDir}/${FinalResultFolder}  dose not exist, please double check! \033[0m"
		exit 1
	fi
 
 }
 
 
runBackupTestData()
 {
	mkdir -p  ${BackupFolder}
	mkdir -p  ${BackupFolder}/${CodecFolder}
	mkdir -p  ${BackupFolder}/${ConfigureFolder}
	mkdir -p  ${BackupFolder}/${FinalResultFolder}

    cp -f  ${TestSpaceDir}/*.log                    ${BackupFolder}
    cp -f  ${TestSpaceDir}/*.txt                    ${BackupFolder}
    cp -f  ${TestSpaceDir}/*.flag                   ${BackupFolder}
	cp -f  ${TestSpaceDir}/${CodecFolder}/*         ${BackupFolder}/${CodecFolder}
 	cp -f  ${TestSpaceDir}/${ConfigureFolder}/*     ${BackupFolder}/${ConfigureFolder}
	cp -f  ${TestSpaceDir}/${FinalResultFolder}/*   ${BackupFolder}/${FinalResultFolder}
 }
 

runBackupInfo()
{
	echo -e "\033[32m **************--backup info--****************************\033[0m"
	echo -e "\033[32m                                                          \033[0m"
	echo -e "\033[32m  backup date:    ${DateInfo}                             \033[0m"
	echo -e "\033[32m  backup folder:  ${BackupFolder}                         \033[0m"
	echo -e "\033[32m                                                          \033[0m"
	echo -e "\033[32m  backup data include:                                    \033[0m"
	echo -e "\033[32m   --test codec in          ${TestSpaceDir}/Codec         \033[0m"
	echo -e "\033[32m   --test configure file in ${TestSpaceDir}/CaseConfigure \033[0m"
	echo -e "\033[32m   --test result in         ${TestSpaceDir}/FinalResult   \033[0m"
	echo -e "\033[32m *********************************************************\033[0m"

}

runBackupLog()
 {
	runBackupInfo>${BackupFolder}/${BackupLogFile}
	echo "">>${BackupFolder}/${BackupLogFile}
	cat ${SourceInfoLog} >>${BackupFolder}/${BackupLogFile}
 }
 
runMain()
 {
    if [ ! $#  -eq 2 ]
	then
		runUsage
		exit 1
	fi
	
    TestSpaceDir=$1
	PreFixInfo=$2
	SourceFolder="Source"
	CodecFolder="Codec"
	ConfigureFolder="CaseConfigure"
	FinalResultFolder="FinalResult_Summary"

	CurrentDir=`pwd`
	BackupDir="/home/SGETestBackUp/openh264"
	BackupLogFile="Backup_readme.log"
	BackupFolder=""
	DateInfo=""
	SourceInfoLog="SourceInfo.log"
	
	#check folder 
	runFolderCheck
	
	#generate date info for backup folder
	runGenerateDateInfo

	#generate bolder name
	BackupFolder="${BackupDir}/${PreFixInfo}_ConformanceTest${DateInfo}"
	
	#generate source code info
	runGenerateCodecCommitInfo>${SourceInfoLog}	
	
	#backup test data
	runBackupTestData
	
	#generate backup log
	runBackupInfo
	runBackupLog
	
}
TestSpaceDir=$1
PreFixInfo=$2
runMain  ${TestSpaceDir} ${PreFixInfo}


