#!/bin/bash

#usage: runRenameOutPutYUV  ${OriginYUVName} ${OutputWidth}  ${OutputHeight}
#eg:
#      input:  runRenameOutPutYUV  ABC_1080X720_30fps.yuv   540  360
#      output: ABC_540X360_30fps.yuv
runRenameOutPutYUV()
{
    OriginYUVWidth="0"
    OriginYUVHeight="0"
    OutputYUVName=""
    declare -a aPicInfo
    Iterm=""
    Index=""
    Pattern_01="[xX]"
    Pattern_02="^[1-9][0-9]"
    Pattern_03="[0-9][0-9]$"
    Pattern_04="fps$"
    LastItermIndex=""

    aPicInfo=(`echo ${OriginYUVName} | awk 'BEGIN {FS="[_.]"} {for(i=1;i<=NF;i++) printf("%s  ",$i)}'`)
    let "LastItermIndex=${#aPicInfo[@]} - 1"

    #get PicW PicH info
    let "Index=0"
    for  Iterm in ${aPicInfo[@]}
    do
        if [[ $Iterm =~ $Pattern_01 ]] && [[ $Iterm =~ $Pattern_02 ]] && [[ $Iterm =~ $Pattern_03 ]]
        then
            Iterm="${OutputWidth}X${OutputHeight}"
        fi

        if [  $Index -eq 0 ]
        then
            OutputYUVName=${Iterm}
        elif [  $Index -eq ${LastItermIndex}  ]
        then
            OutputYUVName="${OutputYUVName}.${Iterm}"
        else
            OutputYUVName="${OutputYUVName}_${Iterm}"
        fi

        let "Index++"
    done

    echo "${OutputYUVName}"
}

#***************************************************************************************
if [ ! $# -eq 3  ]
then
    echo "usage: runRenameOutPutYUV  \${OriginYUVName} \${OutputWidth}  \${OutputHeight}"
    exit 1
fi
#***************************************************************************************

OriginYUVName=$1
OutputWidth=$2
OutputHeight=$3

runRenameOutPutYUV

