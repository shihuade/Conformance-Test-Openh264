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
    PicW=""
    PicH=""
    FPS=""

    CurrentDir=`pwd`
    ScriptFileForYUVParser="run_ParseYUVInfo.sh"

    TestYUVName=`echo $InputYUVDir | awk 'BEGIN {FS="/"} {print $NF}'`
    OutputYUV="${OutputDir}/${TestYUVName}"

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
runGetSubFolder()
{

    local FullPath="/home/Video/YUV/YUVCollection/Desktop/Desktop03_SCC_2884x1802.yuv"
    local InputYUVDir=/home/Video/YUV
    FullDirDepth=`echo $FullPath      |awk 'BEGIN {FS="/"} {print NF}'`
    ParentDirDepth=`echo $InputYUVDir |awk 'BEGIN {FS="/"} {print NF}'`
    let "SubDirDepth=${FullDirDepth} -${ParentDirDepth}"

    let "StartIndex=${ParentDirDepth} +1"
    SubDir=`echo ${FullPath}   \
            | awk -v Start=${StartIndex} -v End=${FullDirDepth} 'BEGIN {FS="/"} {for(i=Start; i< End;i++) printf("%s/",$i)}'`
    echo "FullDirDepth   is ${FullDirDepth}"
    echo "ParentDirDepth is ${ParentDirDepth}"
    echo "SubDirDepth    is ${SubDirDepth}"

    echo "SubDir is ${SubDir}"
}

runTruncateAllYUVs()
{
    while read line
    do
        if [[  "$line" =~ ".yuv" ]]
        then
            vInputYUV="$line"
            vYUVName=`echo $line  | awk ' BEGIN {FS="/"} {print $NF}'`
            vSubFoler=`echo $line | awk ' BEGIN {FS="${InputYUVDir}"} {print $2}'`
            echo "vSubFoler is ${vSubFoler}"
            vSubFoler=`echo $vSubFoler | awk ' BEGIN {FS="${vYUVName}"} {print $1}'`
            echo "vSubFoler is ${vSubFoler}"
        fi

    done <${YUVFullPathLog}


}

runParseYUVInfo()
{
    
    aYUVInfo=(`./run_ParseYUVInfo.sh  ${TestYUVName}`)
    PicW=${aYUVInfo[0]}
    PicH=${aYUVInfo[1]}
    FPS=${aYUVInfo[2]}

}


runTruncateYUV()
{
    ${TruncateApp} ${PicW} ${PicH} ${InputYUVDir} ${PicW} ${PicH} ${OutputYUV}  0 0 0 ${OutputFrmNum}

    if [ ! $? -eq 0 ]
    then
        echo  -e "\033[31m  Trunscate file ${InputYUVDir} failed! \033[0m"
        exit 1

    fi
}

runOutputTaskInfo()
{
    echo  -e "\n\n"
    echo  -e "\033[32m  ************************************************************ \033[0m"
    echo  -e "\033[32m  ${InputYUVDir} has been trunscate ${OutputYUV}                  \033[0m"
    echo  -e "\033[32m   Succeed!                                                     \033[0m"
    echo  -e "\033[32m  ************************************************************ \033[0m"
    echo  -e "\n\n"

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

    if [  ! -e ${TruncateApp} ]
    then
        echo  -e "\033[31m  Truncate App ${TruncateApp} does not exist,please double check! \033[0m"
        exit 1
    fi


    if [  ! -e ${ScriptFileForYUVParser} ]
    then
        echo  -e "\033[31m  YUV info parser script file ${ScriptFileForYUVParser} does not exist,please double check! \033[0m"
        echo  -e "\033[31m   Please copy to current working dir ${CurrentDir} \033[0m"
        exit 1
    fi

}


runMain()
{

    runInit
    runCheck

    runParseYUVInfo
    runTruncateYUV

    runOutputTaskInfo

}

if [ ! $# -eq 4 ]
then
    runUsage
#exit 1
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

#runMain
#runInit
#runGenerateAllFilesFullPath
#runTruncateAllYUVs
runGetSubFolder

