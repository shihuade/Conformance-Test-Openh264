#!/bin/bash
#***************************************************************************************
# brief:
#      --check that whether all submitted SGE jobs have been completed
#      --usage:  ./run_SGEJobStatusUpdate.sh  ${SGEJobSubmittedLogFile}
#
#
#date: 04/26/2015 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
	echo -e "\033[31m usage: usage:  ./run_SGEJobStatusUpdate.sh  \${SGEJobSubmittedLogFile} \033[0m"
 	echo ""
 }



#comparison between  current runnig SGE job list and the submitted job list
#to check that whether all submitted jobs are not in current running list
runSGEJobCheck()
{

	
    declare -a aSubmittedSGEJobIDList
    declare -a aSubmittedSGEJobNameList
    declare -a aRunningSGEJobIDList

    aSubmittedSGEJobIDList=(`./Scripts/run_ParseSGEJobIDs.sh     ${SGEJobSubmittedLogFile}`)
    aSubmittedSGEJobNameList=(`./Scripts/run_ParseSGEJobNames.sh ${SGEJobSubmittedLogFile}`)
    aRunningSGEJobIDList=(`./Scripts/run_ParseRunningSGEJobIDs.sh`)

    let "SubmittedJobNum      = ${#aSubmittedSGEJobIDList[@]}"
    let "CurrentRunningJobNum = ${#aRunningSGEJobIDList[@]}"

    echo  -e "\033[32m SubmittedJobNum          is ${SubmittedJobNum}              \033[0m"
    echo  -e "\033[32m CurrentRunningJobNum     is ${CurrentRunningJobNum}         \033[0m"
    echo  -e "\033[32m aSubmittedSGEJobIDList   is ${aSubmittedSGEJobIDList[@]}    \033[0m"
    echo  -e "\033[32m aSubmittedSGEJobNameList is ${aSubmittedSGEJobNameList[@]}  \033[0m"
    echo  -e "\033[32m aRunningSGEJobIDList     is ${aRunningSGEJobIDList[@]}      \033[0m"

	let "RunningJobNum=0"
	for((i=0;i<${SubmittedJobNum};i++))
	do	
        SubmitId=${aSubmittedSGEJobIDList[$i]}
		let "JonRunningFlag=0"
		for((j=0;j<${CurrentRunningJobNum};j++))
		do
		
			CurrentRunningJobID=${aRunningSGEJobIDList[$j]}
			if [ ${SubmitId} -eq ${CurrentRunningJobID} ]
			then
				let "JonRunningFlag=1"
				break
			fi
		done
		
		#job is still waiting or running 
		if [ ${JonRunningFlag} -eq 1 ]
		then
			echo  -e "\033[31m  Job ${SubmitId} is still running \033[0m"
			echo  -e "\033[31m        Job info is:----${aSubmittedSGEJobNameList[$i]} \033[0m"
			let "RunningJobNum++"
		else
			echo  -e "\033[32m  Job ${SubmitId} has been finished! \033[0m"
			echo  -e "\033[32m        Job info is:----${aSubmittedSGEJobNameList[$i]} \033[0m"
		fi
	done
	
	if [ ${RunningJobNum} -eq 0  ]
	then
        echo  -e "\033[32m  ****************************************************** \033[0m"
        echo  -e "\033[32m       All submitted SGE jobs have completed all test \033[0m"
        echo  -e "\033[32m  ****************************************************** \033[0m"

		return 0
	else
        echo  -e "\033[31m  ****************************************************** \033[0m"
        echo  -e "\033[31m       Not all submitted SGE jobs have completed yet \033[0m"
        echo  -e "\033[31m  ****************************************************** \033[0m"
		return 1
	fi

}

runMain()
{
	if [ ! $# -eq 1  ]
	then
		runUsage
		exit 1
	fi

	SGEJobSubmittedLogFile=$1

    if [ ! -e ${SGEJobSubmittedLogFile} ]
    then
        echo  -e "\033[31m  ${SGEJobSubmittedLogFile} does not exist, please double check!\033[0m"
        exit 1
    fi

    runSGEJobCheck
    return $?

}
SGEJobSubmittedLogFile=$1

runMain  ${SGEJobSubmittedLogFile}


