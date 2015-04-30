#!/bin/bash
#***************************************************************************************
# brief:
#      --print all running SGE jobs' IDs
#      --usage:  run_ParseRunningSGEJobIDs.sh
#
#date: 04/26/2015 Created
#***************************************************************************************

#extract all SGE job ID by using command qstat 
runGetRunningSGEJobID()
{
	SGEJobList="SGEJobList.Temp"

    if [ ! -e ${SGEJobList} ]
    then
        touch ${SGEJobList}
    fi

	qstat > ${SGEJobList}
	
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
	done <${SGEJobList}
	
}

runMain()
{

    declare -a aAllSGEJobIDList

    runGetRunningSGEJobID

    echo ${aAllSGEJobIDList[@]}

}

runMain