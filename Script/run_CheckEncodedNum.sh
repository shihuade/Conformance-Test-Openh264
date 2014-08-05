#!/bin/bash
#************************************************************************************************
#
# Usage:   run_CheckEncodedNum.sh  $EncoderNum  $SpatailLayerNum \
#                                  ${EncoderLog}  ${aInputLayerYUVSize} $aRecYUVFile
#
# e.g:    --run_CheckEncodedNum.sh  32  3  Encoder.log  400 800  1600  0 \
#                                          320X180.yuv 640X360.yuv 1280X720.yuv NuLL.yuv
#         --run_CheckEncodedNum.sh  32  2  Encoder.log   800  1600 0 0 \
#                                          640X360.yuv 1280X720.yuv  NuLL01.yuv NULL02.yuv
#
#************************************************************************************************
#usage: runGetFileSize  $FileName
runGetFileSize()
{
	if [ ! -e $1   ]
	then
		echo ""
		echo "file $1 does not exist!"
		echo "usage: runGetFileSize  $FileName!"
		echo ""
		return 1
	fi
	local FileName=$1
	local FileSize=""
	local TempInfo=""
	TempInfo=`ls -l $FileName`
	FileSize=`echo $TempInfo | awk '{print $5}'`
	echo $FileSize

}
#usage: runCheckActulLayerSize ${ActualSpatialNum}
runCheckActulLayerSize()
{
	if [ ! $# -eq 1 ]
	then
		echo "usage: runCheckActulLayerSize ${ActualSpatialNum}"
		exit 1
	fi

	local ActualSpatialNum=$1

	aRecYUVLayerSize=(0 0 0 0)
	let "SizeMatchFlag=0"
	for((i=0;i<${ActualSpatialNum};i++))
	do
		if [ -e ${aRecYUVFile[$i]} ]
		then
			aRecYUVLayerSize[$i]=`runGetFileSize  ${aRecYUVFile[$i]}`
			echo "${aRecYUVFile[$i]} size: ${aRecYUVLayerSize[$i]}"
		fi

		echo "Rec--Input:  ${aRecYUVLayerSize[$i]} ---- ${aInputLayerYUVSize[$i]}"
		if [ ! ${aRecYUVLayerSize[$i]} -eq ${aInputLayerYUVSize[$i]}  ]
		then
			let "SizeMatchFlag=1"
		fi
	done

	echo "RecYUV   size: ${aRecYUVLayerSize[@]}"
	echo "InputYUV size: ${aInputLayerYUVSize[@]}"
	echo ""

	if [ ! ${SizeMatchFlag} -eq 0 ]
	then
		echo ""
		echo  -e "\033[31m RecYUV size does not match with input YUV size  \033[0m"
		echo ""
		return 1
	else
		echo ""
		echo  -e "\033[32m All layer size match with input YUV size \033[0m"
		echo ""
		return 0
	fi
}
#usage: runGetEncodedNum  ${EncoderLog}
runGetEncodedNum()
{
	if [ $#  -lt 1  ]
	then
		echo "usage: runGetEncodedNum  \${EncoderLog}"
		return 1
	fi
	local EncoderLog=$1
	local EncodedNum="0"
	while read line
	do
		if [[  ${line}  =~ ^Frames  ]]
		then
			EncodedNum=`echo $line | awk 'BEGIN {FS="[:\r]"} {print $2}'`
			break
		fi
	done <${EncoderLog}
	echo ${EncodedNum}
}
#Usage runCheckActualEncodedNum ${ConfiguredEncodedNum}
runCheckActualEncodedNum()
{
	if [ ! $# -eq 1  ]
	then
		echo "Usage: runCheckActualEncodedNum \${ConfiguredEncodedNum}"
		exit 1
	fi
	local ConfiguredEncodedNum=$1
	local ActualEncodedNum=""
	ActualEncodedNum=`runGetEncodedNum  ${EncoderLog}`
	echo ""
	echo "Config--Actual: ${ActualEncodedNum}----${ConfiguredEncodedNum}"
	echo ""
	if [  ${ActualEncodedNum} -eq ${ConfiguredEncodedNum} ]
	then
		echo ""
		echo  -e "\033[32m Actual encoded number matches with configured number   \033[0m"
		echo ""
		return 0
	else
		echo ""
		echo  -e "\033[31m  Actual encoded number does not match with configured number  \033[0m"
		echo ""
		return 1
	fi
}
runMain()
{
	if [ ! $# -eq 11  ]
	then
		echo	""
		echo  -e "\033[31m Usage: run_CheckEncodedNum.sh  \${EncoderNum} \${SpatailLayerNum} \${EncoderLog} \${aInputLayerYUVSize[@]} \${aRecYUVFile[@]}\033[0m"
		echo ""
		exit 1
	fi
	declare -a aParameterSet
	declare -a aInputLayerYUVSize
	declare -a aRecYUVLayerSize
	declare -a aRecYUVFile

	aParameterSet=($@)

	EncoderNum=${aParameterSet[0]}
	SpatailLayerNum=${aParameterSet[1]}
	EncoderLog=${aParameterSet[2]}

	for((i=0;i<4;i++))
	do
		let "YUVSizeIndex=    $i + 3 "
		let "RecYUVFileIndex= $i + 7"
		aInputLayerYUVSize[$i]=${aParameterSet[${YUVSizeIndex}]}
		aRecYUVFile[$i]=${aParameterSet[${RecYUVFileIndex}]}
	done

	if [ ${SpatailLayerNum} -lt 1 -o ${SpatailLayerNum} -gt 4 ]
	then
		echo ""
		echo  -e "\033[31m spatial layer number is not correct, should be 1<=SpatialNum<=4  \033[0m"
		echo ""
		exit 1
	fi

	if [ ${EncoderNum} -eq -1 ]
	then
		runCheckActulLayerSize ${SpatailLayerNum}
		let "CheckFlag=$?"
	elif [ ${EncoderNum} -gt 0 ]
	then
		runCheckActualEncodedNum ${EncoderNum}
		let "CheckFlag=$?"
	fi

	if [  ${CheckFlag} -eq 0 ]
	then
		echo ""
		echo  -e "\033[32m Actual encoded number matches with configured number   \033[0m"
		echo ""
		return 0
	else
		echo ""
		echo  -e "\033[31m Actual encoded number does not match with configured number   \033[0m"
		echo ""
		return 1
	fi
}
runMain $@


