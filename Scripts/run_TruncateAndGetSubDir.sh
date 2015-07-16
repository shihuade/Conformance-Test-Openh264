#!/bin/bash
#*******************************************************************************************************************
# brief:  get sub folder
#
# Usage: ./run_TruncateAndGetSubDir.sh  ${ParentDir} ${FullPath}
#
# e.g.:
#        ./run_TruncateAndGetSubDir.sh Test_1280X720.yuv  /A/B/C  /A/B/C/D/E/xxx.txt
#        output:  D/E/
#
# date: 2015/07/15  huashi@ciscocom
#*******************************************************************************************************************

runUsage()
{
    echo  -e "\n\n"
    echo  -e "\033[31m Usage: ./run_TruncateAndGetSubDir.sh \${ParentDir} \${FullPath}                    \033[0m"
    echo  -e "\033[31m e.g.:                                                                              \033[0m"
    echo  -e "\033[31m        ./run_TruncateAndGetSubDir.sh Test_1280X720.yuv  /A/B/C  /A/B/C/D/E/xxx.txt \033[0m"
    echo  -e "\033[31m        output:  D/E/                                                               \033[0m"
    echo  -e "\n\n"

}


runGetSubFolder()
{

    FullDirDepth=`echo $FullPath    |awk 'BEGIN {FS="/"} {print NF}'`
    ParentDirDepth=`echo $ParentDir |awk 'BEGIN {FS="/"} {print NF}'`

    let "SubDirDepth = ${FullDirDepth}   - ${ParentDirDepth}"
    let "StartIndex  = ${ParentDirDepth} + 1"

    SubDir=`echo ${FullPath}   \
            | awk -v Start=${StartIndex} -v End=${FullDirDepth} \
                  'BEGIN {FS="/"} {for(i=Start; i< End;i++) printf("%s/",$i)}'`

}

runOutputTaskInfo()
{
     echo "${SubDir}"
}

runMain()
{
    runGetSubFolder

    runOutputTaskInfo

}

if [ ! $# -eq 2 ]
then
    runUsage
    exit 1
fi
ParentDir=$1
FullPath=$2

runMain
