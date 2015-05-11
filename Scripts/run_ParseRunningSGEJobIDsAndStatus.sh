#!/bin/bash
#***************************************************************************************
# brief:
#      --print all running SGE jobs' IDs
#      --usage:  run_ParseRunningSGEJobIDsAndStatus.sh ${Option}
#
#      --e.g.:  1) get all job IDs
#                  run_ParseRunningSGEJobIDsAndStatus.sh JobID
#
#      --e.g.:  2) get all job status
#                  run_ParseRunningSGEJobIDsAndStatus.sh JobStatus
#
#      --e.g.:  3) get all job IDs and status
#                  run_ParseRunningSGEJobIDsAndStatus.sh IDAndStatus
#
#
#date: 04/26/2015 Created
#***************************************************************************************

runUsage()
{
    echo ""
    echo -e "\033[31m usage:  ./run_ParseRunningSGEJobIDsAndStatus.sh \${Option}   \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  1) get all job IDs  \033[0m"
    echo -e "\033[32m          ./run_ParseRunningSGEJobIDsAndStatus.sh JobID        \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  2) get all job status  \033[0m"
    echo -e "\033[32m          ./run_ParseRunningSGEJobIDsAndStatus.sh JobStatus    \033[0m"
    echo ""
    echo -e "\033[32m e.g.:  3) get all job IDs  \033[0m"
    echo -e "\033[32m          ./run_ParseRunningSGEJobIDsAndStatus.sh IDAndStatus  \033[0m"
    echo ""

}
#extract all SGE job ID and Status by using command qstat
runGetRunningSGEJobID()
{
	SGEJobList="SGEJobList_running.log"

    if [ ! -e ${SGEJobList} ]
    then
        touch ${SGEJobList}
    fi

	qstat > ${SGEJobList}
	
	let "LineIndex=0"
	let "JobIDIndex=0"
    let "IDAndStatusIndex=0"

	while read line
	do
		if [ ${LineIndex} -ge 2 ]
		then
			aAllSGEJobIDList[${JobIDIndex}]=`echo $line | awk '{print $1}'`
            aAllSGEJobStatusList[${JobIDIndex}]=`echo $line | awk '{print $5}'`

            let "IDAndStatusIndex = 2 * JobIDIndex"
            aAllSGEJobIDAndStatusList[${IDAndStatusIndex}]=aAllSGEJobIDList[${JobIDIndex}]
            let "IDAndStatusIndex ++"
            aAllSGEJobIDAndStatusList[${IDAndStatusIndex}]=aAllSGEJobStatusList[${JobIDIndex}]

            let "JobIDIndex++"
		fi
		let "LineIndex++"
	done <${SGEJobList}
	
}

runCheck()
{
    if [ "${Option}" = "JobID"  ]
    then
        return 0
    elif  [ "${Option}" = "JobStatus"  ]
    then
        return 0
    elif  [ "${Option}" = "IDAndStatus"  ]
    then
        return 0
    else
        runUsage
        exit 1
    fi

}

runOutputParseInfo()
{
    if [ "${Option}" = "JobID"  ]
    then
        echo ${aAllSGEJobIDList[@]}
    elif  [ "${Option}" = "JobStatus"  ]
    then
        echo ${aAllSGEJobStatusList[@]}
    elif  [ "${Option}" = "IDAndStatus"  ]
    then
        echo ${aAllSGEJobIDAndStatusList[@]}
    fi

}

runMain()
{

    declare -a aAllSGEJobIDList
    declare -a aAllSGEJobStatusList
    declare -a aAllSGEJobIDAndStatusList
    runCheck
    runGetRunningSGEJobID
    runOutputParseInfo

}

Option=$1
if [ ! $# -eq 1 ]
then
    runUsage
    exit 1
fi
runMain