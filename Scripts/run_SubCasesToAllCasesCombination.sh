#!/bin/bash
#***************************************************************************************
# brief:
#      --combine subcase files into single files for all test cases
#      --usage:  run_SubCasesToAllCasesCombination.sh ${SubCasesFileDir} \
#                                                          ${TestYUVName}     \
#                                                          ${FileIndex}#
#
#date: 05/08/2014 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
    echo -e "\033[31m usage:  ./run_SubCasesToAllCasesCombination.sh \${SubCasesFileDir}  \033[0m"
    echo -e "\033[31m                                                \${TestYUVName}      \033[0m"
    echo -e "\033[31m                                                \${FileIndex}        \033[0m"
	echo -e "\033[31m   FileIndex: 0--AssignedCasesPassStatusFile    \033[0m"
    echo -e "\033[31m   FileIndex: 1--UnPassedCasesFile              \033[0m"
    echo -e "\033[31m   FileIndex: 2--AssignedCasesSHATableFile      \033[0m"
    echo -e "\033[31m   FileIndex: 3--CaseSummaryFile                \033[0m"
 }

runCopySubCaseFileToAllCasesFile()
{
    if [ ! $# -eq 1 ]
    then
        echo -e "\033[31m usage: runCopySubCaseFileToAllCasesFile \${SubCasesFile}  \033[0m"
        return 0
    fi

    SubCasesFile=$1
    let "LineIndex=0"
    while read line
    do
        if [ ${LineIndex} -eq 0 ]
        then
            HeadLine=${line}
        fi

        if [ ${NewFileFlag} -eq 0 ]
        then
            echo ${HeadLine}  >${OutputFile}
            let "NewFileFlag  = 1"
        fi

        if [ ${LineIndex} -gt 0 ]
        then
            echo ${line}  >>${OutputFile}
        fi

        let "LineIndex ++"
    done < ${SubCasesFile}

}

runGetTestSummary()
{
    let "SubFileIndex =0"
    for file in ${SubCasesFileDir}/${FileNamePrefix}*
    do
        echo -e "\033[32m ********************************************************* \033[0m"
        echo "      Combine file type is ${FileIndex}"
        echo "      SubFileIndex is ${SubFileIndex}"
        echo "      SubFile      is ${file}"
        echo -e "\033[32m ********************************************************* \033[0m"
        runCopySubCaseFileToAllCasesFile ${file}

        let "SubFileIndex ++"
    done
}


runGenerateFilePreFixBasedIndex()
{

    AssignedCasesPassStatusFile="${TestYUVName}_AllCasesOutput"
    UnPassedCasesFile="${TestYUVName}_UnpassedCasesOutput"
    AssignedCasesSHATableFile="${TestYUVName}_AllCases_SHA1_Table"
    CaseSummaryFile="${TestYUVName}"

    if [ ${FileIndex}  -eq 0 ]
    then
        FileNamePrefix="${AssignedCasesPassStatusFile}_SubCasesIndex_"
        OutputFileName=${AssignedCasesPassStatusFile}.csv
    elif [ ${FileIndex}  -eq 1 ]
    then
        FileNamePrefix="${UnPassedCasesFile}_SubCasesIndex_"
        OutputFileName=${UnPassedCasesFile}.csv
    elif [ ${FileIndex}  -eq 2 ]
    then
        FileNamePrefix="${AssignedCasesSHATableFile}_SubCasesIndex_"
        OutputFileName=${AssignedCasesSHATableFile}.csv
    elif [ ${FileIndex}  -eq 3 ]
    then
        FileNamePrefix="${CaseSummaryFile}_SubCasesIndex_"
        OutputFileName=${CaseSummaryFile}_AllCasesAllSlaves.Summary
    fi

    OutputFile=${SubCasesFileDir}/${OutputFileName}

}

runCheck()
{
    if [ ! -d ${SubCasesFileDir} ]
    then
        echo -e "\033[31m File directory ${SubCasesFileDir} does not exist,please double check! \033[0m"
        exit 1
    fi

    if [ ${FileIndex} -lt 0 -o ${FileIndex} -gt 3 ]
    then
        echo -e "\033[31m File index shoule be chosen from 0~3 \033[0m"
        runUsage
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
    FileIndex=$3

    FileNamePrefix=""
    HeadLine=""
    OutputFileName=""
    OutputFile=""
    CurrentDir=`pwd`

    let "SubFileIndex = 0"
    let "NewFileFlag  = 0"

    runCheck
    runGenerateFilePreFixBasedIndex

    runGetTestSummary

    return 0


}
SubCasesFileDir=$1
TestYUVName=$2
FileIndex=$3
runMain  ${SubCasesFileDir}  ${TestYUVName}  ${FileIndex}

