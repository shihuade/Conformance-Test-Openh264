#!/bin/bash
#***************************************************************************************
#brief:  build and copy  codec to Codec folder
#
#  usage: run_UpdateCodec.sh  ${CodecDir}
#       
#date:  5/08/2014 Created
#***************************************************************************************
runUsage()
{
    echo -e "\033[32m ******************************************** \033[0m"
    echo -e "\033[32m usage:                                       \033[0m"
    echo -e "\033[32m  ./run_UpdateCodec.sh  \${Openh264SrcDir}    \033[0m"
    echo -e "\033[32m ******************************************** \033[0m"
}

runGlobalVariableInitial()
{
    CurrentDir=`pwd`

    [ ! -d  ${Openh264SrcDir} ] && echo "openh264 dir ${Openh264SrcDir}  does not exist!" && exit 1
    cd ${Openh264SrcDir} && Openh264SrcDir=`pwd` && cd ${CurrentDir}

    YUVDumpMacroFileName="as264_common.h"
    YUVDumpMacroFile="${Openh264SrcDir}/codec/encoder/core/inc/${YUVDumpMacroFileName}"
    [ ! -f "$YUVDumpMacroFile" ] && echo "file ${YUVDumpMacroFile} does not exist! " && exit 1

    CodecDir="Codec"
    [ ! -d ${CodecDir} ] && mkdir -p ${CodecDir}
    BuildLog="${CurrentDir}/CodecBuildInfo.log"
}

runYUVDumpMacroOpen()
{
	TempFile="${YUVDumpMacroFile}.Team.h"
	OpenLine="#define WELS_TESTBED"

	PreviousLine=""
    echo "">${TempFile}
	while read line
	do
		if [[  ${PreviousLine} =~ "#define AS264_COMMON_H_"  ]]
		then
			echo "${OpenLine}">>${TempFile}
		fi
		echo "${line}">>${TempFile}
		PreviousLine=$line
	done < ${YUVDumpMacroFile}

	mv -f  ${TempFile}  ${YUVDumpMacroFile}
}

#useage: ./runBuildCodec  ${Openh264SrcDir}
runBuildCodec()
{
	cd ${Openh264SrcDir}
	make clean  >${BuildLog}
	make       >>${BuildLog} 2>&1
	[ ! -e h264enc ] || [ ! -e h264dec  ] && echo "encoder build failed" && let " Flag = 1 "
    cd ${CurrentDir}

    return ${Flag}
}

#useage:  runCopyFile  ${Openh264SrcDir}
runCopyFile()
{
	cp -f ${Openh264SrcDir}/h264enc  ${CodecDir}
	cp -f ${Openh264SrcDir}/h264dec  ${CodecDir}
	cp -f ${Openh264SrcDir}/testbin/layer2.cfg      ${CodecDir}/layer0.cfg
	cp -f ${Openh264SrcDir}/testbin/layer2.cfg      ${CodecDir}/layer1.cfg
	cp -f ${Openh264SrcDir}/testbin/layer2.cfg      ${CodecDir}/layer2.cfg
	cp -f ${Openh264SrcDir}/testbin/layer2.cfg      ${CodecDir}/layer3.cfg
	cp -f ${Openh264SrcDir}/testbin/welsenc.cfg     ${CodecDir}
}

#useage: ./run_UpdateCodec.sh   ${Openh264SrcDir}
runMain()
{

    runGlobalVariableInitial

    echo -e "\033[32m ******************************************** \033[0m"
    echo -e "\033[32m ****  enable macro for Rec YUV dump!    **** \033[0m"
    echo -e "\033[32m ******************************************** \033[0m"
	runYUVDumpMacroOpen

    echo -e "\033[32m ******************************************** \033[0m"
    echo -e "\033[32m ****  building codec!                   **** \033[0m"
    echo -e "\033[32m ******************************************** \033[0m"
	runBuildCodec
	[ ! $? -eq 0 ] && echo "Codec Build failed" && exit 1

    echo -e "\033[32m ******************************************** \033[0m"
    echo -e "\033[32m  copying codec and .cfg files to ${CodecDir} \033[0m"
    echo -e "\033[32m ******************************************** \033[0m"
	runCopyFile
    [ ! $? -eq 0 ] && echo "copy files failed" && exit 1

    return 0
}

#****************************************************************************************
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters is:"
echo "        $0 $@"
echo "*********************************************************"
echo ""
if [ ! $# -eq 1 ]
then
    runUsage
    exit 1
fi

Openh264SrcDir=$1

runMain
#****************************************************************************************


