#!/bin/bash
#***************************************************************************************
# SHA1 table generation model:
#      This model is part of Cisco openh264 project for encoder binary comparison test.
#      The output of this test are those SHA1 tables for all test bit stream, and will
#      be used in openh264/test/encoder_binary_comparison/SHA1Table.
#
#      1.Test case configure file: ./CaseConfigure/case.cfg.
#
#      2.Test result: ./FinalResult  and ./SHA1Table
#
#      3 For more detail, please refer to READE.md
#
# brief:
#      --enable reconstructed YUV macro in  codec/encoder/core/inc/as264_common.h
#      --build codec
#      --copy h264ecn and h264dec, layerXX.cfg, welsenc.cfg file to ./Codec
#      --usage: run_UpdateCodecAndTestBitStream.sh  $Openh264Dir
#        eg: run_UpdateCodecAndTestBitStream.sh  ../openh264
#
#
#date:  10/06/2014 Created
#***************************************************************************************
runYUVDumpMacroOpen()
{
	if [ ! $# -eq 1 ]
	then
		echo "useage:  runYUVDumpMacroOpen   \${Openh264Dir}"
		return 1
	fi
	local File=$1
	local TempFile="${File}.Team.h"
	local OpenLine="#define WELS_TESTBED"
	local PreviousLine=""
	if [ ! -f  "$File"   ]
	then
		echo "file ${File} does not exist! when tring to open YUV dump macro "
		return 1
	fi
	echo "">${TempFile}
	while read line
	do
		if [[  ${PreviousLine} =~ "#define AS264_COMMON_H_"  ]]
		then
			echo "${OpenLine}">>${TempFile}
		fi
		echo "${line}">>${TempFile}
		PreviousLine=$line
	done < ${File}
	rm -f ${File}
	mv  ${TempFile}  ${File}
}
#useage: ./runBuildCodec  ${Openh264Dir}
runBuildCodec()
{
  if [ ! $# -eq 1 ]
  then
    echo "useage: ./runBuildCodec  \${Openh264Dir}"
    return 1
  fi
  local OpenH264Dir=$1
  local CurrentDir=`pwd`
  local BuildLog="${CurrentDir}/build.log"
  if [  ! -d ${OpenH264Dir} ]
  then
    echo "openh264 dir is not right!"
    return 1
  fi
  cd ${OpenH264Dir}
  make clean  >${BuildLog}
  make >>${BuildLog}
  if [ ! -e h264enc  ]
  then
    echo "encoder build failed"
    cd ${CurrentDir}
    return 1
  elif [ ! -e h264dec  ]
  then
    echo "decoder build failed"
    cd ${CurrentDir}
    return 1
  else
    cd ${CurrentDir}
    return 0
  fi
}
#useage:  runCopyFile  ${Openh264Dir}
runCopyFile()
{
	if [ ! $# -eq 1 ]
	then
		echo "useage:  runCopyFile  \${Openh264Dir}"
		return 1
	fi
	local OpenH264Dir=$1
	local CodecDir="Codec"
	cp -f ${OpenH264Dir}/h264enc  ${CodecDir}
	cp -f ${OpenH264Dir}/h264dec  ${CodecDir}
	cp -f ${OpenH264Dir}/testbin/layer2.cfg      ${CodecDir}/layer0.cfg
	cp -f ${OpenH264Dir}/testbin/layer2.cfg      ${CodecDir}/layer1.cfg
	cp -f ${OpenH264Dir}/testbin/layer2.cfg      ${CodecDir}/layer2.cfg
	cp -f ${OpenH264Dir}/testbin/layer2.cfg      ${CodecDir}/layer3.cfg
	cp -f ${OpenH264Dir}/testbin/welsenc.cfg     ${CodecDir}
}
#useage: ./run_CodecBitStreamUpdate.sh   ${Openh264Dir}
runMain()
{
	if [ ! $# -eq 1 ]
	then
		echo "useage: ./run_CodecBitStreamUpdate.sh   \${Openh264Dir}"
		return 1
	fi
	local Openh264Dir=$1
	local CurrentDir=`pwd`
	local YUVDumpMacroFileName="as264_common.h"
	local YUVDumpMacroFileDir="codec/encoder/core/inc"
	local TestBitStreamFileDir=""
	local YUVDumpMacroFile=""
	if [ ! -d  ${Openh264Dir} ]
	then
		echo "openh264 dir  ${Openh264Dir}  does not exist!"
		echo "useage: ./run_CodecBitStreamUpdate.sh   \${Openh264Dir}"
		exit 1
	fi
	cd ${Openh264Dir}
	Openh264Dir=`pwd`
	cd ${CurrentDir}
	YUVDumpMacroFile="${Openh264Dir}/${YUVDumpMacroFileDir}/${YUVDumpMacroFileName}"
	echo ""
	echo "enable macro for Rec YUV dump!"
	echo "file is ${YUVDumpMacroFile}"
	echo ""
	runYUVDumpMacroOpen  "${YUVDumpMacroFile}"
	if [ ! $? -eq 0 ]
	then
		echo "YUV Dump file failed!"
		exit 1
	fi
	echo ""
	echo "building codec"
	echo ""
	runBuildCodec  ${Openh264Dir}
	if [ ! $? -eq 0 ]
	then
		echo "Codec Build failed"
		exit 1
	fi
	echo ""
	echo "copying h264 codec"
	echo ""
	runCopyFile  ${Openh264Dir}
	if [ ! $? -eq 0 ]
	then
		echo "copy files failed"
		exit 1
	fi
	return 0
}
Openh264Dir=$1
runMain ${Openh264Dir}


