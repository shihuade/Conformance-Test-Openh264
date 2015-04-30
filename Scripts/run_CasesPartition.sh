#!/bin/bash
#********************************************************************************
# Brief: split all cases set into small sets and generate sub-set cases files
#
# Usage: run_CasesPartition.sh  ${AllCasesFile} ${SubCasesNum}
#                               ${TestYUVName}
# e.g.:
#       inputt: run_CasesPartition.sh  ABC.YUV_AllCases.csv  1000  ABC.YUV
#       output: ABC.YUV_SubCases_0.csv   ABC.YUV_SubCases_1.csv
#       output: ABC.YUV_SubCases_2.csv   ABC.YUV_SubCases_3.csv
#       (suppose there are 3800 cases)
#
#
#date:  12/10/2014 Created
#*********************************************************************************


runUsage()
{
    echo ""
    echo -e "\033[31m Usage: \033[0m"
    echo -e "\033[31m    --./run_CasesPartition.sh \${AllCasesFile} \${SubCasesNum}    \033[0m"
    echo -e "\033[31m                              \${TestYUVName}  \${SubCaseInfoLog} \033[0m"
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

    if [ ${SubCasesNum} -le 5  ]
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

    echo ""
    echo -e "\033[32m ********************************************************************* \033[0m"
    echo -e "\033[32m partition all cases into small cases set for ${TestYUVName} \033[0m"

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
        let "NewFileFlag = CaseIndex % ${SubCasesNum}"
        if [ ${NewFileFlag} -eq 0 ]
        then
            SubCasesFileName="${TestYUVName}_SubCases_${SubCasesFileIndex}.csv"
            let "SubCasesFileIndex ++"
            #echo ${HeadLine}
            #echo ${LineIndex}
            #echo ${CaseIndex}
            #echo $line
            echo ${HeadLine} >${SubCasesFileName}
            echo ${SubCasesFileName}>>${SubCaseInfoLog}
        fi
        echo ${line} >>${SubCasesFileName}

        let "LineIndex ++"

    done < ${AllCasesFile}

    echo -e "\033[32m Total sub cases file num is ${SubCasesFileIndex}"
    echo -e "\033[32m ********************************************************************* \033[0m"


}

runMain()
{
    if [ ! $# -eq 4 ]
    then
        runUsage
        exit 1
    fi

    AllCasesFile=$1
    SubCasesNum=$2
    TestYUVName=$3
    SubCaseInfoLog=$4
    let "SubCasesFileIndex = 0"

    runCheck

    runPartitionAllCasesIntoSubCasesFile
    echo ${SubCasesFileIndex}>>${SubCaseInfoLog}

    return 0
}

AllCasesFile=$1
SubCasesNum=$2
TestYUVName=$3
SubCaseInfoLog=$4
runMain ${AllCasesFile} ${SubCasesNum}  ${TestYUVName} ${SubCaseInfoLog}






