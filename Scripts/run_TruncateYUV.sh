#!/bin/bash
#*******************************************************************************************************************
# brief:  truncate yuv file with given output frame num
#
# Usage: ./run_TruncateYUV.sh  ${InputYUV}  ${OutputDir} ${OutputFrmNum} ${TruncateApp}
#
# e.g.:
#        ./run_TruncateYUV.sh Test_1280X720.yuv  ./TruncateOutputDir 200 DownConvertStatic
#
# date: 2015/07/15  huashi@ciscocom
#*******************************************************************************************************************

runUsage()
{
    echo  -e "\n\n"
    echo  -e "\033[31m Usage: ./run_TruncateYUV.sh \${InputYUV} \${OutputDir} \${OutputFrmNum} \${TruncateApp}  \033[0m"
    echo  -e "\033[31m e.g.:                                                                                    \033[0m"
    echo  -e "\033[31m  ./run_TruncateYUV.sh Test_1280X720.yuv  ./TruncateOutputDir 200 DownConvertStatic       \033[0m"
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

    TestYUVName=`echo $InputYUV  | awk 'BEGIN {FS="/"} {print $NF}'`
    vTempName=`echo $TestYUVName | awk 'BEGIN {FS=".yuv"} {print $1}'`
    OutputYUV="${OutputDir}/${vTempName}_FrmNum_${OutputFrmNum}.yuv"

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
    ${TruncateApp} ${PicW} ${PicH} ${InputYUV} ${PicW} ${PicH} ${OutputYUV}  0 0 0 ${OutputFrmNum}

    if [ ! $? -eq 0 ]
    then
        echo  -e "\033[31m  Trunscate file ${InputYUV} failed! \033[0m"
        exit 1

    fi
}

runOutputTaskInfo()
{
    echo  -e "\n\n"
    echo  -e "\033[32m  ************************************************************ \033[0m"
    echo  -e "\033[32m  ${InputYUV} has been trunscate ${OutputYUV}                  \033[0m"
    echo  -e "\033[32m   Succeed!                                                     \033[0m"
    echo  -e "\033[32m  ************************************************************ \033[0m"
    echo  -e "\n\n"

}

runCheck()
{
    if [ ! -e ${InputYUV} ]
    then
        echo  -e "\033[31m  Input YUV file ${InputYUV} does not exist,please double check! \033[0m"
        exit 1
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
    exit 1
fi

echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo "*********************************************************"
echo ""

InputYUV=$1
OutputDir=$2
OutputFrmNum=$3
TruncateApp=$4

runMain

