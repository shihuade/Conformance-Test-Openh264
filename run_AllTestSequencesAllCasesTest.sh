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
#usage: runGetTestYUVList 
runGetTestYUVList()
{
	local TestSet0=""
	local TestSet1=""
	local TestSet2=""
	local TestSet3=""
	local TestSet4=""
	local TestSet5=""
	local TestSet6=""
	local TestSet7=""
	local TestSet8=""
	while read line
	do
		if [[ "$line" =~ ^TestSet0  ]]
		then
			TestSet0=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet1  ]]
		then
			TestSet1=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet2  ]]
		then
			TestSet2=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet3  ]]
		then
			TestSet3=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet4  ]]
		then
			TestSet4=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet5  ]]
		then
			TestSet5=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet6  ]]
		then
			TestSet6=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet7  ]]
		then
			TestSet8=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet8  ]]
		then
			TestSet2=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		fi
	done <${ConfigureFile}
	
	aTestYUVList=(${TestSet0}  ${TestSet1}  ${TestSet2}  ${TestSet3}  ${TestSet4}  ${TestSet5}  ${TestSet6}  ${TestSet7} ${TestSet8})
}
runSGEJobSubmit()
{
	let "JobNum=0" 
	for TestYUV in ${aTestYUVList[@]}
	do
		SubFolder="${AllTestDataDir}/${TestYUV}"
		TestSubmitFlagFile="${TestYUV}_Submitted.flag"
		echo ""
		echo "test YUV is ${TestYUV}"
		echo ""
		
		if [  -e   ${SubFolder}/${TestSubmitFlagFile} ]
		then
			continue
		fi
		cd  ${SubFolder}
		echo "submit job"
		aSubmitJobList[$JobNum]=`qsub ./${TestYUV}.sge `
		echo "submit job is ${aSubmitJobList[$JobNum]} "
		let "JobNum ++" 
		touch ${TestSubmitFlagFile}		
		cd  ${CurrentDir}
	done
	return 0
}
#extract all SGE job ID by using command qstat 
runGetAllSGEJobID()
{
	SGEJObList="Job.list"	
	qstat >${SGEJObList}
	
	let "LineIndex=0"
	let "JobIDIndex=0"
	while read line
	do
		if [ ${LineIndex} -ge 2 ]
		then
			aAllSGEJobIDList[${JobIDIndex}]=`echo $line | awk '{print $1}'`
			let "JobIDIndex++"
		fi
		let "LineIndex++"
	done <${SGEJObList}
	
	let "CurrentSGEJobNum=${LineIndex}"
}
#comparison between  current SGE job list and the submitted list 
#to check that whether all submitted jobs are not in current running list
runSGEJobCheck()
{
	
	SGEJobSubmittedNum=${#aSubmitJobList[@]}
	
	let "RunningJobNum=0"
	for((i=0;i<${SGEJobSubmittedNum};i++))
	do	
		SubmitId=`echo ${aSubmitJobList[$i]} | awk '{print $3} ' `
		let "JonRunningFlag=0"
		for((j=0;j<${CurrentSGEJobNum};j++))
		do
		
			CurrenJobID=${aAllSGEJobIDList[$j]}					
			if [ ${SubmitId} -eq ${CurrenJobID} ]
			then
				let "JonRunningFlag=1"
				break
			fi
		done
		
		#job is still waiting or running 
		if [ ${JonRunningFlag} -eq 1 ]
		then
			echo  -e "\033[31m  Job ${SubmitId} is still running \033[0m"
			echo  -e "\033[31m        Job info is:----${aSubmitJobList[$i]} \033[0m"
			let "RunningJobNum++"
		else
			echo  -e "\033[32m  Job ${SubmitId} has been finished! \033[0m"
			echo  -e "\033[32m        Job info is:----${aSubmitJobList[$i]} \033[0m"
		fi
	done
	
	if [ ${RunningJobNum} -eq 0  ]
	then
		return 0
	else
		return 1
	fi
	
}
runSGETest()
{
	local SGEQueneName="Openh264SGE"	
	
	runSGEJobSubmit
	#check whether all job have finished
	let "AllJobFinishedFlag=0"
	while [ ${AllJobFinishedFlag} -eq 0 ]
	do
		CurrentTime=`date`
		CurrentTestStatus=`qstat  -q Openh264SGE`
		
		runGetAllSGEJobID
		runSGEJobCheck
		if [ $? -eq 0 ]
		then
			let "AllJobFinishedFlag=1"
			echo ""
			echo  -e "\033[32m *************************************************************** \033[0m"
			echo  -e "\033[32m  All jobs have be finished! \033[0m"
			echo  -e "\033[32m  Date: ${CurrentTime}   \033[0m"
			echo  -e "\033[32m *************************************************************** \033[0m"
			echo ""
		else
			let "AllJobFinishedFlag=0"
			echo ""
			echo  -e "\033[34m *************************************************************** \033[0m"
			echo  -e "\033[34m  Not all jobs have be finished yet! \033[0m"
			echo  -e "\033[34m  Please wait! SGE jobs' status will be updated after 60 minutes! \033[0m"
			echo  -e "\033[34m  Date: ${CurrentTime}   \033[0m"
			echo  -e "\033[34m *************************************************************** \033[0m"
			echo ""
			echo  -e "\033[34m *************************************************************** \033[0m"
			echo  -e "\033[34m Current SGE job for openh264 test are listed as below: \033[0m"
			qstat  -q  ${SGEQueneName}
			echo  -e "\033[34m *************************************************************** \033[0m"
			sleep 3600
		fi 
	done
	
	return 0
	
}
runLocalTest()
{
	let "Flag=0"
	for TestYUV in ${aTestYUVList[@]}
	do
		SubFolder="${AllTestDataDir}/${TestYUV}"
		TestFlagFile="${TestYUV}_Tested.flag"
		if [ -e   ${SubFolder}/${TestFlagFile} ]
		then
			continue
		fi
		cd  ${SubFolder}
		echo ""
		echo "test YUV is ${TestYUV}"
		echo ""
		./run_OneTestYUV.sh  ${TestYUV}  ${FinalResultDir}  ${ConfigureFile}
		if [  ! $? -eq 0 ]
		then
			echo -e "\033[31m not all test cases have been passed! \033[0m"
			let "Flag=1"
		fi
		#when test completed, generate flag file to avoid repeating test
		touch ${TestFlagFile}
		cd  ${CurrentDir}
	done
	
	return ${Flag}
	
}
runGetTestSummary()
{
	echo "">${AllTestSummary}
		
	let "AllPassedFlag=1"
	for TestYUV in ${aTestYUVList[@]}
	do
		
		if [ -e  ${FinalResultDir}/${TestYUV}.Summary ]
		then
	
			while read line
			do
				if [[  $line =~ ^Failed ]]
				then
					let "AllPassedFlag=0"
					break			
				fi
				break	
			done <${FinalResultDir}/${TestYUV}.Summary
			
			echo "">>${AllTestSummary}
			cat ${FinalResultDir}/${TestYUV}.Summary >>${AllTestSummary}
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
 
runCheck()
{
	#check test type
	if [ ${TestType} = "SGETest" ]
	then
		return 0
	elif [ ${TestType} = "LocalTest" ]
	then
		return 0
	else
		 runUsage
		 exit 1
	fi
	
	#check configure file
	if [  ! -f ${ConfigureFile} ]
	then
		echo "Configure file not exist!, please double check in "
		echo " usage may looks like:   ./run_Main.sh  ../CaseConfigure/case.cfg "
		exit 1
	fi
	return 0
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

