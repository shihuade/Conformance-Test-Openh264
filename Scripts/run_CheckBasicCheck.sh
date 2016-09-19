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
    aRecYUVLayerSize=(0 0 0 0)
    if [ ${RCMode} -eq -1 ]
    then
        let "SizeMatchFlag=0"
        for((i=0;i<${SpatailLayerNum};i++))
        do
            [ -e ${aRecYUVFileList[$i]} ] && aRecYUVLayerSize[$i]=`ls -l ${aRecYUVFileList[$i]} | awk '{print $5}'`

            echo "RecYUV   size: ${aRecYUVLayerSize[$i]}"
            echo "InputYUV size: ${aInputYUVSizeLayer[$i]}"

            [ ! ${aRecYUVLayerSize[$i]} -eq ${aInputYUVSizeLayer[$i]} ] && return 1
        done
    fi

    return 0
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
#Usage: run_CheckBasicCheck.sh  $EncoderFlag   $SpatailLayerNum $RCMode
runMain()
{
    aInputYUVSizeLayer=($YUVSizeLayer0 $YUVSizeLayer1 $YUVSizeLayer2 $YUVSizeLayer3)
    aRecYUVFileList=($RecYUVFile0 $RecYUVFile1 $RecYUVFile2 $RecYUVFile3)
    aRecCropYUVFileList=($RecCropYUV0 $RecCropYUV1 $RecCropYUV2 $RecCropYUV3)
    aEncodedPicW=($PicW0 $PicW1 $PicW2 $PicW3)
    aEncodedPicH=($PicH0 $PicH1 $PicH2 $PicH3)

	EncoderCheckResult="NULL"
	DecoderCheckResult="NULL"
    echo "CheckLog is ${CheckLog}"
    echo ""
	echo "---------------Basic Check--------------------------------------------"
	echo "-------------------1. Basic Check--Encoded Failed Check"
    date
	runEncoderFailedCheck
	if [ ! $? -eq 0 ]
	then
		echo -e "\033[31m  encode failed! \033[0m"
		return 1
	fi
	echo "-------------------2. Basic Check--RecYUV Check"
    date
	runRecYUVCheck
	if [ ! $? -eq 0 ]
	then
		echo -e "\033[31m RecYUV does not exist! \033[0m"
		return 2
	fi

	echo "-------------------3. Basic Check--Crop RecYUV for JSVM comparison"
    date
	runCropRecYUV
	if [ ! $? -eq 0 ]
	then
		echo -e "\033[31m  cropped failed \033[0m"
		return 3
	fi

	echo "-------------------4. Basic Check--Encoded Number Check"
    date
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

#*****************************************************************************************************************************
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo "*********************************************************"
echo ""

if [ ! $# -eq 3 ]
then
    echo  -e "\033[31m \n Usage: run_CheckBasicCheck.sh  \$EncoderFlag \$SpatailLayerNum \$RCMode \n\033[0m"
    exit 1
fi
#*****************************************************************************************************************************

EncoderFlag=$1
SpatailLayerNum=$2
RCMode=$3

runMain


