#!/bin/bash
#***************************************************************************************
# brief:
#      --parse all submitted SGE name lists from submitted log file
#      --usage:  ./run_ParseSGEJobIDs.sh ${SGEJobSubmittedLogFile}
#
#date: 05/08/2014 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
	echo -e "\033[31m usage: ./run_ParseSGEJobIDs.sh \${SGEJobSubmittedLogFile}\033[0m"
 	echo ""
 }

#extract all SGE job ID by parsing the SGE submit log file
runGetAllSGEJobNames()
{

	let "LineIndex=0"
	let "JobIDIndex=0"
    let "ExampleLineJobInfoFlag = 0"

	while read line
	do
        # for line contian the job ID info
        # e.g.: Your job 534 ("CREW_176x144_30.yuvCREW_176x144_30.yuv_SGE_Test_SubCaseIndex_1") has been submitted
		if [[ "$line" =~ "Your job"  ]]
		then

            # skip the first info which is e.g. info for SGE job
            if [ ${ExampleLineJobInfoFlag} -eq 0]
            then
                let "ExampleLineJobInfoFlag = 1"
            else
                TempName=`echo $line | awk '{print $4}'`
                aAllSGEJobNameList[${JobIDIndex}]=`echo $TempName | awk 'BEGIN {FS="[()]"} {print $2 }'`
                let "JobIDIndex++"
            fi
		fi
        #echo "line is  $line"
        #echo "LineIndex is ${LineIndex}"
		let "LineIndex++"
	done <${SGEJobSubmittedInfoFile}
	
}

runMain()
{
	if [ ! $# -eq 1  ]
	then
		runUsage
		exit 1
	fi

    SGEJobSubmittedInfoFile=$1

    if [ ! -e ${SGEJobSubmittedInfoFile} ]
    then
        echo -e "\033[31m ${SGEJobSubmittedInfoFile} does not exist! please double check!\033[0m"
        echo -e "\033[31m \033[0m"
        exit 1
    fi

	declare -a aAllSGEJobNameList

    runGetAllSGEJobNames

    echo ${aAllSGEJobNameList[@]}

}

SGEJobSubmittedInfoFile=$1

runMain ${SGEJobSubmittedInfoFile}
