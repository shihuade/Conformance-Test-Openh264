#!/bin/bash
#*******************************************************************************************************************
# brief:  truncate yuv file with given output frame num
#
# Usage: ./run_TruncateGivenDirYUV.sh  ${InputYUVDir}  ${OutputDir} ${OutputFrmNum} ${TruncateApp}
#
# e.g.:
#        ./run_TruncateGivenDirYUV.sh InputYUVDir  ./TruncateOutputDir 200 DownConvertStatic
#
# date: 2015/07/15  huashi@ciscocom
#*******************************************************************************************************************

runUsage()
{
    echo  -e "\n\n"
    echo  -e "\033[31m Usage: ./run_TruncateGivenDirYUV.sh \${InputYUVDir} \${OutputDir} \${OutputFrmNum} \${TruncateApp}  \033[0m"
    echo  -e "\033[31m e.g.:                                                                                               \033[0m"
    echo  -e "\033[31m  ./run_TruncateGivenDirYUV.sh Test_1280X720.yuv  ./TruncateOutputDir 200 DownConvertStatic          \033[0m"
    echo  -e "\n\n"

}

runInit()
{

    declare -a aYUVInfo
    declare -a aScriptFile

    CurrentDir=`pwd`
    aScriptFile=(run_ParseYUVInfo.sh  run_TruncateYUV.sh run_TruncateAndGetSubDir.sh )

    YUVFullPathLog="GivenInputYUVFullPath.log"

    date >${YUVFullPathLog}

}

runGenerateAllFilesFullPath()
{

    for file1 in ${InputYUVDir}/*
    do
        if [ -d ${file1} ]
        then
            SubFolder2=${file1}
            for file2 in ${SubFolder2}/*
            do
				if [ -d ${file2} ]
                then
                    SubFolder3=${file2}

                    for file3 in ${SubFolder3}/*
                    do
                        echo ${file3} >>${YUVFullPathLog}
                    done
                else
                    echo ${file2} >>${YUVFullPathLog}
                fi
            done
        else
            echo ${file1} >>${YUVFullPathLog}
        fi
    done

}

runTruncateAllYUVs()
{
    while read line
    do
        if [[  "$line" =~ ".yuv" ]]
        then
            vInputYUV="$line"
            vYUVName=`echo $line  | awk ' BEGIN {FS="/"} {print $NF}'`

            vSubFoler=`./run_TruncateAndGetSubDir.sh ${InputYUVDir} ${vInputYUV}`

            vOutputDir="${OutputDir}/${vSubFoler}"

            echo "vSubFoler  is ${vSubFoler}"
            echo "vOutputDir is ${vOutputDir}"

            if [ ! -d ${vOutputDir} ]
            then
                mkdir ${vOutputDir}
            fi

            #./run_TruncateYUV.sh ${vInputYUV} ${vOutputDir} ${OutputFrmNum} ${TruncateApp}
        fi

    done <${YUVFullPathLog}


}


runCheck()
{
    if [ ! -e ${InputYUVDir} ]
    then
        echo  -e "\033[31m  Input YUV file ${InputYUVDir} does not exist,please double check! \033[0m"
        exit 1
    else
        cd ${InputYUVDir}
        InputYUVDir=`pwd`
        cd ${CurrentDir}
    fi


    if [ ! -d ${OutputDir} ]
    then
        echo  -e "\033[31m  Output dir ${OutputDir} does not exist,please double check! \033[0m"
        exit 1
    else
        cd ${OutputDir}
        OutputDir=`pwd`
        cd ${CurrentDir}
    fi

    if [  ${OutputFrmNum} -lt 1 ]
    then
        echo  -e "\033[31m  Output frame num ${OutputFrmNum} is incorrect! \033[0m"
        exit 1
    fi


    for ScriptFile in ${aScriptFile[@]}
    do

        if [  ! -e ${ScriptFile} ]
        then
            echo  -e "\033[31m  YUV info parser script file ${ScriptFile} does not exist,please double check! \033[0m"
            echo  -e "\033[31m   Please copy to current working dir ${CurrentDir}                             \033[0m"
            exit 1
        fi
    done

}


runMain()
{

    runInit
    runCheck

    runGenerateAllFilesFullPath
    runTruncateAllYUVs

}

if [ ! $# -eq 4 ]
then
    runUsage
    exit 1
fi

echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo "*********************************************************"
echo ""

InputYUVDir=$1
OutputDir=$2
OutputFrmNum=$3
TruncateApp=$4

runMain
