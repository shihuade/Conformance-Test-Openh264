#!/bin/bash
#***************************************************************************************
# brief:
#      --check that whether all submitted SGE jobs have been completed
#      --usage:  ./run_SGEJobStatusUpdate.sh  ${SGEJobSubmittedLogFile}
#                                             ${SGEJobsFinishFlagFile}
#
#
#date: 04/26/2015 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
    echo -e "\033[31m usage: usage:  ./run_SGEJobStatusUpdate.sh  \${SGEJobSubmittedLogFile} \033[0m"
    echo -e "\033[31m usage: usage:                               \${SGEJobsFinishFlagFile}  \033[0m"
    echo -e "\033[32m when all SGE test jobs have been completd, \${SGEJobsFinishFlagFile} will be generated! \033[0m"
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
    echo  ""
    echo  -e "\033[32m aSubmittedSGEJobIDList   is ${aSubmittedSGEJobIDList[@]}    \033[0m"
    echo  ""
    echo  -e "\033[32m aRunningSGEJobIDList     is ${aRunningSGEJobIDList[@]}      \033[0m"
    echo  ""
    echo  -e "\033[32m aSubmittedSGEJobNameList is ${aSubmittedSGEJobNameList[@]}  \033[0m"
    echo  ""

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
	if [ ! $# -eq 2  ]
	then
		runUsage
		exit 1
	fi

	SGEJobSubmittedLogFile=$1
    SGEJobsFinishFlagFile=$2

    if [ ! -e ${SGEJobSubmittedLogFile} ]
    then
        echo  -e "\033[31m  SGEJobSubmittedLogFile ${SGEJobSubmittedLogFile} does not exist! \033[0m"
        echo  -e "\033[31m  Please double check!\033[0m"
        echo  -e "\033[32m  --Submit SGE jobs before you detect the SGE jobs status!  \033[0m"
        echo  -e "\033[32m  --or check the the SGE submitted log file!\033[0m"
        touch ${SGEJobsFinishFlagFile}
        return 0
    fi

    if [ -e ${SGEJobsFinishFlagFile} ]
    then
        ./Scripts/run_SafeDelete.sh  ${SGEJobsFinishFlagFile}
    fi

    runSGEJobCheck

    if [ $? -eq 0 ]
    then
        touch ${SGEJobsFinishFlagFile}
    fi
    return 0

}
SGEJobSubmittedLogFile=$1
SGEJobsFinishFlagFile=$2
runMain  ${SGEJobSubmittedLogFile} ${SGEJobsFinishFlagFile}


