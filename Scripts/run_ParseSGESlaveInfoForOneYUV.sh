#!/bin/bash
#***************************************************************************************
# brief:
#      --combine subcase files into single files for all test cases
#      --usage:  run_SubCasesToAllCasesCombination.sh ${SubCasesFileDir}  \
#                                                     ${TestYUVName}      \
#                                                     ${SGESlaveInfoFile}
#
#
#date: 05/08/2014 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
    echo -e "\033[31m usage:  ./run_SubCasesToAllCasesCombination.sh \${SubCasesFileDir}  \033[0m"
    echo -e "\033[31m                                                \${TestYUVName}      \033[0m"
    echo -e "\033[31m                                                \${SGESlaveInfoFile} \033[0m"
 }


runParseSubCaseFile()
{

    if [ ! $# -eq 2 ]
    then
        echo "usage: runParseSubCaseFile \${SubCasesFile} \${FileIndex}  "
        return 1
    fi

    SubCasesFile=$1
    FileIndex=$2

    aSubCaseIndexList[${FileIndex}]=`echo ${SubFile} | awk 'BEGINE {FS="_SubCasesIndex_"} {print $2}'`
    aSubCaseIndexList[${FileIndex}]=`echo ${SubFile} | awk 'BEGINE {FS=".Summary.log"} {print $1}'`

    while read line
    do
        if [[ "$line" =~ "TestStartTime" ]]
        then
            aStartTimeList[${FileIndex}]=`echo ${line} | awk 'BEGINE {FS="is"} {print $2}'`
        elif [[ "$line" =~ "TestEndTime" ]]
        then
            aEndTimeList[${FileIndex}]=`echo ${line} | awk 'BEGINE {FS="is"} {print $2}'`
        elif [[ "$line" =~ "result" ]]
        then
            #e.g.: --detail result  can be found in   /home/HuangZhong/SGEJobID_207/result
            aDataDirList[${FileIndex}]=`echo  ${line} | awk 'BEGINE {FS="in"} {print $2}'`
            aSGEJobIDList[${FileIndex}]=`echo ${line} | awk 'BEGINE {FS="/"} {print $4}'`
            aSGEJobIDList[${FileIndex}]=`echo ${aSGEJobIDList[${FileIndex}]} | awk 'BEGINE {FS="_"} {print $2}'`
            aSlaveList[${FileIndex}]=`echo ${line} | awk 'BEGINE {FS="/"} {print $3}'`

        fi

    done < ${SubCasesFile}
}


runGetTestSummary()
{
    let "SubFileIndex =0"
    for file in ${SubCasesFileDir}/${FileNamePrefix}*
    do
        echo -e "\033[32m ********************************************************* \033[0m"
        echo "      SubFileIndex is ${SubFileIndex}"
        echo "      SubFile      is ${file}"
        echo -e "\033[32m ********************************************************* \033[0m"
        runParseSubCaseFile ${file} ${SubFileIndex}
        let "SubFileIndex ++"
    done
}

runOutputSlaveInfo()
{
    HeadLine="Index, SGEJobID, SubCaseIndex, Slave, ResultDir, StartTime, EndTime"
    TotalNum=${SubFileIndex}
    echo "*************************************************************"
    echo "*************************************************************"
    echo ${HeadLine}

    for (( i=0; i<${TotalNum});i++)
    do
        SubCaseInfo="${i}, ${aSGEJobIDList[$i]}, ${aSubCaseIndexList[$i]}, ${aSlaveList[$i]}, ${aDataDirList[$i]}, ${aStartTimeList[$i]}, ${aEndTimeList[$i]}"
        echo ${SubCaseInfo}
    done

    echo "*************************************************************"
    echo "*************************************************************"
}

runCheck()
{
    if [ ! -d ${SubCasesFileDir} ]
    then
        echo -e "\033[31m File directory ${SubCasesFileDir} does not exist,please double check! \033[0m"
        exit 1
    fi

    cd ${SubCasesFileDir}
    SubCasesFileDir=`pwd`
    cd ${CurrentDir}
}

runMain()
{
    if [ ! $# -eq 3 ]
	then
		runUsage
		exit 1
	fi
	
    SubCasesFileDir=$1
    TestYUVName=$2
    SGESlaveInfoFile=$3

    FileNamePrefix="${TestYUVName}_SubCasesIndex_"
    CurrentDir=`pwd`

    declare -a aSGEJobIDList
    declare -a aSubCaseIndexList
    declare -a aSlaveList
    declare -a aDataDirList
    declare -a aStartTimeList
    declare -a aEndTimeList

    let "SubFileIndex = 0"

    runCheck

    runGetTestSummary

    runOutputSlaveInfo >${SGESlaveInfoFile}

    return 0


}
SubCasesFileDir=$1
TestYUVName=$2
SGESlaveInfoFile=$3
runMain  ${SubCasesFileDir}  ${TestYUVName}  ${SGESlaveInfoFile}

