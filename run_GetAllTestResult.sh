#!/bin/bash
#***************************************************************************************
# brief:
#      --test all cases of all sequences 
#      --usage:  run_AllBitStreamALlCasesTest  ${AllTestDataDir} \
#                                              ${FinalResultDir} \
#                                              ${ConfigureFile}
#
#
#date: 05/08/2014 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
	echo -e "\033[31m usage: ./run_AllTestSequencesAllCasesTest.sh   \${TestType}  \${AllTestDataDir}  \${FinalResultDir} \${ConfigureFile} \033[0m"
	echo -e "\033[31m       --eg:   ./run_AllTestSequencesAllCasesTest.sh  SGETest   AllTestData  FinalResult ./CaseConfigure/case.cfg \033[0m"
	echo -e "\033[31m       --eg:   ./run_AllTestSequencesAllCasesTest.sh  LocalTest AllTestData  FinalResult ./CaseConfigure/case.cfg \033[0m"
 	echo ""
 }
runGetTestSummary()
{
	echo "">${AllTestSummary}
		
	let "AllPassedFlag=0"
	for TestYUV in ${aTestYUVList[@]}
	do
		echo -e "\033[32m final checking for ${TestYUV}  \033[0m"
		echo ""
		if [ -e  ${FinalResultDir}/TestReport_${TestYUV}.report ]
		then
	
			let "ReportLineIndex=0"
			while read line
			do
				if [ ${ReportLineIndex}  -eq 3 ]
				then
					if [[  $line =~ "Failed!" ]]
					then
						let "AllPassedFlag=1"
					fi
					break
				fi
				
				let "ReportLineIndex ++"
				
			done <${FinalResultDir}/TestReport_${TestYUV}.report
			
			echo "">>${AllTestSummary}
			cat ${FinalResultDir}/TestReport_${TestYUV}.report >>${AllTestSummary}
		else
			echo -e "\033[31m  ${FinalResultDir}/TestReport_${TestYUV}.report does not exist! \033[0m"
			let "AllPassedFlag=1"
		fi
	done
	
	echo ""
	echo -e "\033[32m ********************************************************** \033[0m"
	echo -e "\033[32m all test summary listed as below: \033[0m"
	echo -e "\033[32m ********************************************************** \033[0m"
	echo ""
	cat ${AllTestSummary}
	echo ""
	echo -e "\033[32m ********************************************************** \033[0m"
	echo ""
	
	return ${AllPassedFlag}
}
 

#usage: runMain  ${BitstreamDir} ${AllTestDataDir}  ${FinalResultDir}
runMain()
{
	#parameter check!
	if [ ! $# -eq 4  ]
	then
		runUsage
		exit 1
	fi
	
	TestType=$1
	AllTestDataDir=$2
	FinalResultDir=$3
	ConfigureFile=$4
	#check input parameters
	runCheck
	
	CurrentDir=`pwd`
	
	TestFlagFile=""
	AllTestSummary="${FinalResultDir}/AllTestYUVsSummary.txt"
	let "CurrentSGEJobNum=0"
	declare -a aTestYUVList
	declare -a aSubmitJobList
	declare -a aAllSGEJobIDList
	
	#get full path info
	cd ${AllTestDataDir}
	AllTestDataDir=`pwd`
	cd  ${CurrentDir}
	cd ${FinalResultDir}
	FinalResultDir=`pwd`
	cd  ${CurrentDir}
	echo ""
	echo "testing all test sequences......"
	echo ""
	
	#get YUV list
	runGetTestYUVList
	
	#Test 
	if [ ${TestType} = "SGETest"  ]
	then
		runSGETest
	elif [ ${TestType} = "LocalTest"  ]
	then
		runLocalTest
	fi
	
	#get all test summary
	runGetTestSummary
	return $?
	
}
TestType=$1
AllTestDataDir=$2
FinalResultDir=$3
ConfigureFile=$4
runMain  ${TestType}  ${AllTestDataDir}  ${FinalResultDir} ${ConfigureFile}

