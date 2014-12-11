#!/bin/sh

#  Script.sh
#  
#
#  Created by huashi on 12/10/14.
#




runUsage()
{
    echo ""
    echo -e "\033[31m Usage: \033[0m"
    echo -e "\033[31m    --./run_CasesPartition.sh \${AllCasesFile} \${SubCasesNum} \${TestYUVName}\033[0m"
    echo ""
}

runCheck()
{
    if [ ! -e  ${AllCasesFile} ]
    then
        echo -e "\033[31m All cases file does not exist, please double check!  \033[0m"
        echo -e "\033[31m      --All cases file----${AllCasesFile} \033[0m"
        exit 1
    fi

    if [ ${SubCasesNum} -le 10  ]
    then
        echo -e "\033[31m sub cases number should larger than 10!  \033[0m"
        exit 1
    fi

    return 0

}
runPartitionAllCasesIntoSubCasesFile()
{

    local SubCasesFileName=""
    local HeadLine=""

    let "SubCasesFileIndex = 0"
    let "CaseIndex   = 0"
    let "LineIndex   = 0"
    let "NewFileFlag = 0"

    SubCasesFileName="${TestYUVName}_SubCases_${SubCasesFileIndex}.csv"
    while read line
    do
        if [ ${LineIndex} -eq 0 ]
        then
            HeadLine="${line}"
            let "LineIndex ++"
            continue
        fi

        let "CaseIndex = LineIndex -1"
        let "NewFileFlag = CaseIndex% ${SubCasesNum}"
        if [ ${NewFileFlag} -eq 0 ]
        then
            SubCasesFileName="${TestYUVName}_SubCases_${SubCasesFileIndex}.csv"
            let "SubCasesFileIndex ++"
            echo ${HeadLine}
            echo ${LineIndex}
            echo ${CaseIndex}
            echo $line
            echo ${HeadLine} >${SubCasesFileName}
        fi
        echo ${line} >>${SubCasesFileName}

        let "LineIndex ++"

    done < ${AllCasesFile}

}

runMian()
{
    if [ ! $# -eq 3 ]
    then
        runUsage
        exit 1
    fi

    AllCasesFile=$1
    SubCasesNum=$2
    TestYUVName=$3

    runCheck

    runPartitionAllCasesIntoSubCasesFile

    return 0
}

AllCasesFile=$1
SubCasesNum=$2
TestYUVName=$3
runMian ${AllCasesFile} ${SubCasesNum}  ${TestYUVName}






