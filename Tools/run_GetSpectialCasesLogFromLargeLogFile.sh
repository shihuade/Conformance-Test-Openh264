#!/bin/bash
#***************************************************************************************
# brief:
#      --copy spectial case log from large test log file
#      --usage:  run_GetSpectialCasesLogFromLargeLogFile.sh  ${TestLogFile}     \
#                                                            \${OutputLogFile}  \
#                                                            \${CaseIndex_0}    \
#                                                            \${CaseIndex_1} ..
#
#date: 05/28/2015 Created
#***************************************************************************************

runUsage()
{
    echo ""
    echo -e "\033[32m usage:  run_GetSpectialCasesLogFromLargeLogFile.sh  \${TestLogFile}   \  \033[0m"
    echo -e "\033[32m                                                     \${OutputLogFile} \  \033[0m"
    echo -e "\033[32m                                                     \${CaseIndex_0}   \  \033[0m"
    echo -e "\033[32m                                                     \${CaseIndex_1} ..   \033[0m"
    echo ""

}

runInit()
{
    declare -a aCaseIndexList
    declare -a aInputParamList
    declare -a aIndexOutputFlagList
    LogFile=""
    OutputLogFile=""
    let "InputParamNum=0"
    let "CasesIndexNum=0"

    CurrentDir=`pwd`

}

runCheck()
{
    if [ ! -e ${LogFile} ]
    then
        echo ""
        echo -e "\033[31m log file ${LogFile} does not exist,please double check! \033[0m"
        echo ""
        exit 1
    fi

    for CaseIndex in ${aCaseIndexList[@]}
    do
        if [ $CaseIndex -lt 0 -o $CaseIndex -gt 100000 ]
        then
            echo ""
            echo Case index is ${CaseIndex}
            echo -e "\033[31m case index should be numeric,and the range is 1~100000,please double check! \033[0m"
            echo ""
            exit 1
        fi
    done
}

runGetSpectialCaseLog()
{
    #****************case index is 0************
    #
    #---------------Encode One Case-------------------------------------------
    #case line is :
    #./h264enc welsenc.cfg -utype 0 -frms -1 -numl 1 -lconfig 0 layer0.cfg -lconfig 1 layer1.cfg

    let "OutputFlag=0"
    let "FoundNum=0"
    while read line
    do

        for ((i=0;i<${CasesIndexNum}; i++))
        do
            CaseIndex=${aCaseIndexList[$i]}
            if [[ "$line" =~ "case index is ${CaseIndex}" ]]
            then
                let "OutputFlag=1"
                let "BoundIndex = ${CaseIndex} +1 "
                aIndexOutputFlagList[$i]=1
                let "FoundNum ++"
            fi

            if [[ "$line" =~ "case index is ${BoundIndex}" ]]
            then
                let "OutputFlag=0"
                if [ ${FoundNum} -eq ${CasesIndexNum} ]
                then
                    echo "FoundNum is ${FoundNum}"
                    return 0
                fi
            fi

        done

        if [ ${OutputFlag} -eq 1 ]
        then
            #echo $line
            echo $line >>${OutputLogFile}
        fi

    done <${LogFile}

}

runOutputSummary()
{
    for ((i=0;i<${CasesIndexNum}; i++))
    do
        if [  ${aIndexOutputFlagList[$i]} -eq 0 ]
        then
            echo ""
            echo -e "\033[31m case index ${aCaseIndexList[$i]} in ${LogFile} does not exist! \033[0m"
            echo ""
        else
            echo ""
            echo -e "\033[33m test log of case index ${aCaseIndexList[$i]} has been output to ${OutputLogFile} \033[0m"
            echo ""
        fi
    done
}

runMain()
{
    runInit
    aInputParamList=($@)
    LogFile=${aInputParamList[0]}
    OutputLogFile=${aInputParamList[1]}
    let "InputParamNum = ${#aInputParamList[@]}"
    let "CasesIndexNum = InputParamNum - 2"

    for((i=0;i<${CasesIndexNum};i++))
    do
        let "j=i+2"
        aCaseIndexList[$i]=${aInputParamList[$j]}
        aIndexOutputFlagList[$i]=0
    done

    echo "LogFile is ${LogFile}"
    echo "OutputLogFile is ${OutputLogFile}"
    echo " case index list is ${aCaseIndexList[@]}"
    runCheck

    echo "">${OutputLogFile}

    date
    runGetSpectialCaseLog
    date
    runOutputSummary

}

if [ $# -lt 3 ]
then
    runUsage
    exit 1
fi
runMain $@
