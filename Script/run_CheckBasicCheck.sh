#!/bin/bash
#**************************************************************************
#Brief: to check whether the encoded number is the same with given setting
#
# Usage: run_CheckBasicCheck.sh  $EncoderFlag  $EncoderLog $EncodedNum \
#                                $SpatailLayerNum $RCMode $CheckLog    \
#		                 $aInputYUVSizeLayer  $aRecYUVFileList \
#                                $aRecCropYUVFileList $aEncodedPicW    \
#                                $aEncodedPicH
#
#date:  5/08/2014 Created
#**************************************************************************
runOutputFailedCheckLog()
{
	echo  "EncoderPassedNum:   0"
	echo  "EncoderUnPassedNum: 1"
	echo  "DecoderPassedNum:   0"
	echo  "DecoderUpPassedNum: 0"
	echo  "DecoderUnCheckNum:  1"

	echo "BitStreamSHA1String: NULL"
	echo "BitStreamMD5String:  NULL"
	echo "InputYUVSHA1String:  NULL"
	echo "InputYUVMD5String:   NULL"
	echo "EncoderCheckResult: ${EncoderCheckResult}"
	echo "DecoderCheckResult: ${DecoderCheckResult}"
}
runEncoderFailedCheck()
{
	if [ ! ${EncoderFlag} -eq 0 ]
	then
		EncoderCheckResult="1-Encoder failed!"
		DecoderCheckResult="3-Decoder cannot be checked!"
		runOutputFailedCheckLog>${CheckLog}
		return 1
	fi
	return 0
}
runRecYUVCheck()
{
	let "RecFlag=0"
	for((i=0;i<${SpatailLayerNum};i++))
	do
		if [ ! -e ${aRecYUVFileList[$i]} ]
		then
			echo -e "\033[31m ${aRecYUVFileList[$i]} \033[0m"
			let "RecFlag=1"
		fi
	done
	if [ ! ${RecFlag} -eq 0  ]
	then
		EncoderCheckResult="1-Encoder failed!--RecYUV does not exist"
		DecoderCheckResult="3-Decoder cannot be checked!"
		runOutputFailedCheckLog>${CheckLog}
		return 1
	fi
	return 0
}
runEncodedNumCheck()
{
	if [ ${RCMode} -eq -1 ]
	then
		./run_CheckEncodedNum.sh  ${EncodedNum} ${SpatailLayerNum} ${EncoderLog} ${aInputYUVSizeLayer[@]} ${aRecCropYUVFileList[@]}

		if [ ! $? -eq 0 ]
		then
			EncoderCheckResult="1-Encoder failed!"
			DecoderCheckResult="3-Decoder cannot be checked!"
			runOutputFailedCheckLog >${CheckLog}
			return 1
		fi
	else
		echo -e "\033[32m no need to check encoded number when rc is on!  \033[0m"
		return 0
	fi
}
runCropRecYUV()
{
	let "CropFlag=0"
	let "CropRetFlag=0"
	for((i=0;i<${SpatailLayerNum};i++))
	do
		echo "${aRecYUVFileList[$i]}  ${aRecCropYUVFileList[$i]}  ${aEncodedPicW[$i]}  ${aEncodedPicH[$i]}"
		./run_CropYUV.sh  ${aRecYUVFileList[$i]}  ${aRecCropYUVFileList[$i]}  ${aEncodedPicW[$i]}  ${aEncodedPicH[$i]}
		let "CropRetFlag=$?"
		if [ $CropRetFlag -eq 2 ]
		then
			let "CropFlag=1"
		fi

		if [ $CropRetFlag  -eq 1 ]
		then
			cp -f ${aRecYUVFileList[$i]}  ${aRecCropYUVFileList[$i]}
		fi
	done

	if [ !  ${CropFlag} -eq 0 ]
	then
		EncoderCheckResult="1-Encoder RecYUV file cropped failed!"
		DecoderCheckResult="3-Decoder cannot be checked!"
		runOutputFailedCheckLog >${CheckLog}
		return 1
	fi

	return 0
}
runOutputParameter()
{
	echo ""
	echo "aParameterSet ${aParameterSet[@]}"
	echo "aInputYUVSizeLayer  ${aInputYUVSizeLayer[@]}"
	echo "aRecYUVFileList     ${aRecYUVFileList[@]}"
	echo "aRecCropYUVFileList ${aRecCropYUVFileList[@]}"
	echo "aEncodedPicW        ${aEncodedPicW[@]}"
	echo "aEncodedPicH        ${aEncodedPicH[@]}"
	echo ""

}
#Usage: run_CheckBasicCheck.sh  $EncoderFlag  $EncoderLog $EncodedNum  $SpatailLayerNum $RCMode CheckLog
#		                        $aInputYUVSizeLayer  $aRecYUVFileList  $aRecCropYUVFileList  $aEncodedPicW aEncodedPicH
runMain()
{
	if [ ! $# -eq 26 ]
	then
		echo ""
		echo  -e "\033[31m Usage: run_CheckBasicCheck.sh  \$EncoderFlag  \$EncoderLog \$EncodedNum  \$SpatailLayerNum \$RCMode \$CheckLog \033[0m"
		echo  -e "\033[31m                   \$aInputYUVSizeLayer  \$aRecYUVFileList \$aRecCropYUVFileList  \$aEncodedPicW \$aEncodedPicH \033[0m"
		echo ""
		exit 1
	fi

	declare -a aParameterSet
	declare -a aInputYUVSizeLayer
	declare -a aRecYUVFileList
	declare -a aRecCropYUVFileList
	declare -a aEncodedPicW
	declare -a aEncodedPicH

	aParameterSet=($@)

	EncoderFlag=${aParameterSet[0]}
	EncoderLog=${aParameterSet[1]}
	EncodedNum=${aParameterSet[2]}
	SpatailLayerNum=${aParameterSet[3]}
	RCMode=${aParameterSet[4]}
	CheckLog=${aParameterSet[5]}

	for((i=0;i<4;i++))
	do
		let "YUVSizeIndex=    $i + 6 "
		let "RecYUVFileIndex= $i + 10"
		let "CropYUVIndex=    $i + 14"
		let "EncPicWIndex=    $i + 18"
		let "EncPicHIndex=    $i + 22"

		aInputYUVSizeLayer[$i]=${aParameterSet[${YUVSizeIndex}]}
		aRecYUVFileList[$i]=${aParameterSet[${RecYUVFileIndex}]}
		aRecCropYUVFileList[$i]=${aParameterSet[${CropYUVIndex}]}
		aEncodedPicW[$i]=${aParameterSet[${EncPicWIndex}]}
		aEncodedPicH[$i]=${aParameterSet[${EncPicHIndex}]}
	done

	EncoderCheckResult="NULL"
	DecoderCheckResult="NULL"

	echo "---------------Basic Check--------------------------------------------"
	echo "-------------------1. Basic Check--Encoded Failed Check"
	runEncoderFailedCheck
	if [ ! $? -eq 0 ]
	then
		echo -e "\033[31m  encode failed! \033[0m"
		return 1
	fi
	echo "-------------------2. Basic Check--RecYUV Check"
	runRecYUVCheck
	if [ ! $? -eq 0 ]
	then
		echo -e "\033[31m RecYUV does not exist! \033[0m"
		return 2
	fi

	echo "-------------------3. Basic Check--Crop RecYUV for JSVM comparison"
	runCropRecYUV
	if [ ! $? -eq 0 ]
	then
		echo -e "\033[31m  cropped failed \033[0m"
		return 3
	fi

	echo "-------------------4. Basic Check--Encoded Number Check"
	runEncodedNumCheck
	if [ ! $? -eq 0 ]
	then
		echo -e "\033[31m  encoded number not equal to setting  \033[0m"
		return 4
	fi

	echo ""
	echo -e "\033[32m  basic check passed!  \033[0m"
	echo -e "\033[32m    1.encoded failed check passed!   \033[0m"
	echo -e "\033[32m    2.cropped YUV check passed!      \033[0m"
	echo -e "\033[32m    3.encoded number check  passed!  \033[0m"
	echo ""
	return 0
}
runMain $@


