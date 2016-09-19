#!/bin/bash


#***************************************************************************************
# brief:
#   check item listed as below:
#       --extracted bit steam for multiple spatial layer case;
#       --decoded  by JSVM, failed or succeed;
#       --decoded by h264decc decoder, failed or succeed;
#       --check whether JSVMDecYUV is the same with RecYUV
#       --check whether JSVMDecYUV is the same with DecYUV
#
#date:  5/08/2014 Created
#***************************************************************************************

runIntialGlobalParam()
{
	declare -a aLayerBitStream
	declare -a aLayerJSVMYUV
	declare -a aLayerWelsDecYUV
	declare -a aRecCropYUVFileList

	#for sha1 comparison
	declare -a aRecYUVSHA1String
	declare -a aWelsDecYUVSHA1String
	declare -a aJSVMYUVSHA1String

	let "WelsDecodedFailedFlag=0"
	let "FinalCheckFlag=0"
	let "RecJSVMFlag=0"
	let "WelsDecJSVMFlag=0"
	let "SpatialLayerNum=0"

	BitStream=""

	BitStreamSHA1String="NULL"
	InputYUVSHA1String="NULL"

    EncoderCheckResult="NULL"
	DecoderCheckResult="NULL"

}
runSetGlobalParam()
{

	for((i=0;i<4;i++))
	do
		aLayerBitStream[$i]="${TempDataPath}/BitStream_Layer_${i}.264"
		aLayerJSVMYUV[$i]="${TempDataPath}/Dec_JSVM_${i}.yuv"
		aLayerWelsDecYUV[$i]="${TempDataPath}/Dec_WelsDec_${i}.yuv"
	done

	aRecYUVSHA1String=( NULL NULL NULL NULL )
	aWelsDecYUVSHA1String=( NULL NULL NULL NULL )
	aJSVMYUVSHA1String=( NULL NULL NULL NULL )

	let "EncoderPassedNum   = 0"
	let "EncoderUnPassedNum = 1"
	let "DecoderPassedNum   = 0"
	let "DecoderUpPassedNum = 0"
	let "DecoderUnCheckNum  = 1"

}
runOutputCheckLog()
{
	echo  "EncoderPassedNum:   ${EncoderPassedNum}"
	echo  "EncoderUnPassedNum: ${EncoderUnPassedNum}"
	echo  "DecoderPassedNum:   ${DecoderPassedNum}"
	echo  "DecoderUpPassedNum: ${DecoderUpPassedNum}"
	echo  "DecoderUnCheckNum:  ${DecoderUnCheckNum}"

	echo "BitStreamSHA1String: ${BitStreamSHA1String}"
	echo "InputYUVSHA1String:  ${InputYUVSHA1String}"
	echo "EncoderCheckResult: ${EncoderCheckResult}"
	echo "DecoderCheckResult: ${DecoderCheckResult}"
}
runJSVMDecodedFailedCheck()
{
	for((i=0; i<${SpatialLayerNum}; i++))
	do
		echo " JSVM decoding, layer $i....................."
		./${JSVMDecoder}   ${aLayerBitStream[$i]}  ${aLayerJSVMYUV[$i]}

		if [ ! $? -eq 0  -o  ! -e ${aLayerJSVMYUV[$i]} ]
		then
			echo -e "\033[31m \n JSVM decoded failed!  \n\033[0m"
			return 1
		fi
	done

	return 0
}

runJMDecodedFailedCheck()
{
    for((i=0; i<${SpatialLayerNum}; i++))
    do
        echo " JM decoding, layer $i....................."
        ./${JMDecoder}  -p InputFile="${aLayerBitStream[$i]}" -p OutputFile="${aLayerJSVMYUV[$i]}"

        if [ ! $? -eq 0  -o  ! -e ${aLayerJSVMYUV[$i]} ]
        then
            echo -e "\033[31m \n JM decoded failed!  \n\033[0m"
            return 1
        fi
    done
    return 0
}

runWelsDecodedFailedCheck()
{
	for((i=0; i<${SpatialLayerNum}; i++))
	do
		echo " WelsDecoder decoding, layer $i..................... "
		./${WelsDecoder}  ${aLayerBitStream[$i]}  ${aLayerWelsDecYUV[$i]}
		if [ ! $? -eq 0  -o  ! -e ${aLayerWelsDecYUV[$i]} ]
		then
			echo -e "\033[31m \n WelsDecoder decoded failed! \n\033[0m"
			let "WelsDecodedFailedFlag=1"
			return 1
		fi
	done
	return 0
}
runGenerateSHA1String()
{
	for((i=0; i<${SpatialLayerNum}; i++))
	do
		[ -e ${aLayerJSVMYUV[$i]} ]    && aJSVMYUVSHA1String[$i]=`openssl sha1  ${aLayerJSVMYUV[$i]} | awk '{print $2}' `

		[ -e ${aLayerWelsDecYUV[$i]} ] && aWelsDecYUVSHA1String[$i]=`openssl sha1  ${aLayerWelsDecYUV[$i]} | awk '{print $2}' `

        [ -e ${aRecCropYUVFileList[$i]} ]     && aRecYUVSHA1String[$i]=`openssl sha1  ${aRecCropYUVFileList[$i]} | awk '{print $2}' `

	done

	[ -e ${BitStream} ] && BitStreamSHA1String=`openssl sha1  ${BitStream} | awk '{print $2}' `

	[ -e ${InputYUV} ] && InputYUVSHA1String=`openssl sha1  ${InputYUV} | awk '{print $2}' `

}
runRecYUVJSVMDecYUCompare()
{

	let "RecJSVMFlag=0"
	let "WelsDecJSVMFlag=0"
	for((i=0; i<${SpatialLayerNum}; i++))
	do
		if [  ! "${aRecYUVSHA1String[$i]}" = "${aJSVMYUVSHA1String[$i]}"  ]
		then
			let "RecJSVMFlag=1"
		fi

		if [  ! "${aWelsDecYUVSHA1String[$i]}" = "${aJSVMYUVSHA1String[$i]}"  ]
		then
			let "WelsDecJSVMFlag=1"
		fi
	done

	#for encoder check result
	if [ ${RecJSVMFlag} -eq 0  ]
	then
		EncoderCheckResult="0-Encoder passed!"
		let "EncoderPassedNum   = 1"
		let "EncoderUnPassedNum = 0"
	else
		EncoderCheckResult="1-Encoder failed!--RecYUV--JSVMDecYUV does not match!"
		let "EncoderPassedNum   = 0"
		let "EncoderUnPassedNum = 1"
	fi

	#for decoder check result
	if [ ${WelsDecodedFailedFlag} -eq 1 -a  ${RecJSVMFlag} -eq 1  ]
	then
		let "DecoderPassedNum   = 0"
		let "DecoderUpPassedNum = 0"
		let "DecoderUnCheckNum  = 1"
		DecoderCheckResult="3-Decoder failed due to error bit stream,cannot be checked!"
	elif [  ${WelsDecodedFailedFlag} -eq 1 -a  ${RecJSVMFlag} -eq 0 ]
	then
		let "DecoderPassedNum   = 0"
		let "DecoderUpPassedNum = 1"
		let "DecoderUnCheckNum  = 0"
		DecoderCheckResult="2-Decoder failed!"
	elif [  ${WelsDecodedFailedFlag} -eq 0  ]
	then
		if [ ${WelsDecJSVMFlag}  -eq 0 ]
		then
			let "DecoderPassedNum   = 1"
			let "DecoderUpPassedNum = 0"
			let "DecoderUnCheckNum  = 0"
			DecoderCheckResult="0-Decoder passed!"
		else
			let "DecoderPassedNum   = 0"
			let "DecoderUpPassedNum = 1"
			let "DecoderUnCheckNum  = 0"
			DecoderCheckResult="2-Decoder failed!"
		fi
	fi

	if [ ${RecJSVMFlag} -eq 0  -a   ${WelsDecodedFailedFlag} -eq 0  -a ${WelsDecJSVMFlag}  -eq 0 ]
	then
		let "FinalCheckFlag=0"
	else
		let "FinalCheckFlag=1"
	fi
	return 0
}
runCheckParameter()
{

	if [ ! -e ${BitStream}  ]
	then
		echo ""
		echo -e "\033[31m bit stream  ${BitStream} does not exist! \033[0m"
		echo ""
		return 1
	fi

	if [ ${SpatialLayerNum} -lt 1 -o  ${SpatialLayerNum} -gt 4 ]
	then
		echo ""
		echo -e "\033[31m  SpatialNum is not correct, should be 1<=SpatialNum<=4 \033[0m"
		echo ""
		return 1
	fi

	if [ ! -d ${TempDataPath}  ]
	then
		echo ""
		echo -e "\033[31m TempDataPath  ${TempDataPath} does not exist !\033[0m"
		echo ""
		return 1
	fi

	for((i=0; i<${SpatialLayerNum}; i++))
	do
		if [ ! -e ${aRecCropYUVFileList[$i]}  ]
		then
			echo ""
			echo -e "\033[31m RecYUV ${aRecCropYUVFileList[$i]}  does not exist! \033[0m"
			echo ""
			return 1
		fi

	done


	if [ ! -e ${InputYUV}  ]
	then
		echo ""
		echo -e "\033[31m  InputYUV ${InputYUV} does not exist!\033[0m"
		echo ""
		return 1
	fi

	return 0
}
runOutputCheckInfo()
{
	echo "-------------------5. JSVM Check--Check Result"
	echo ""
	echo "aRecYUVSHA1String      ${aRecYUVSHA1String[@]}"
	echo "aWelsDecYUVSHA1String  ${aWelsDecYUVSHA1String[@]}"
	echo "aJSVMYUVSHA1String     ${aJSVMYUVSHA1String[@]}"
	echo "BitStreamSHA1String    ${BitStreamSHA1String}"
	echo "InputYUVSHA1String     ${InputYUVSHA1String}"

	echo ""
	echo "WelsDecodedFailedFlag  ${WelsDecodedFailedFlag}"
	echo "FinalCheckFlag         ${FinalCheckFlag}"
	echo "RecJSVMFlag            ${RecJSVMFlag} "
	echo "WelsDecJSVMFlag        ${WelsDecJSVMFlag}"
	echo "SpatialLayerNum        ${SpatialLayerNum}"
}

runMain()
{
	if [  ! $# -eq 2  ]
	then
		echo ""
		echo -e "\033[31m Usage: run_CheckByJSVMDecoder.sh   \${BitStream}  \${SpatialNum}  \033[0m"
		echo ""
		exit 1
	fi

	runIntialGlobalParam

	BitStream=$1
	let "SpatialLayerNum=$2"
    aRecCropYUVFileList=($RecCropYUV0 $RecCropYUV1 $RecCropYUV2 $RecCropYUV3)

    echo "---------------JSVM Check--------------------------------------------"
	runCheckParameter
	if [  ! $? -eq 0 ]
	then
		echo ""
		echo -e "\033[31m run_CheckByJSVMDecoder.sh parameters are not correct,please double check! \033[0m"
		echo ""
		EncoderCheckResult="1-Encoder failed!--Parameters for JSVM check are not correct!"
		DecoderCheckResult="3-Decoder cannot be checked!"
		runOutputCheckLog >${CheckLogFile}
		exit 1
	fi

	runSetGlobalParam
	echo "-------------------1. JSVM Check--extract bit stream"
    date
    if [ ${NumberLayer} -gt 1 ]
    then
        ./run_ExtractMultiLayerBItStream.sh  ${SpatialLayerNum} ${BitStream}  ${aLayerBitStream[@]}
        if [  ! $? -eq 0 ]
        then
            echo ""
            echo -e "\033[31m failed to extract  bit stream ! \033[0m"
            echo ""
            EncoderCheckResult="1-Encoder failed!--Failed to extracted bit stream!"
            DecoderCheckResult="3-Decoder cannot be checked!"
            runOutputCheckLog >${CheckLogFile}
            exit 1
        fi
    fi

	echo "-------------------2. JSVM Check--JSVM Decode Check"
    date
    if [  "${TestPlatform}" = "Mac" ]
    then
        runJMDecodedFailedCheck
    else
	    runJSVMDecodedFailedCheck
    fi

	if [  ! $? -eq 0 ]
	then
		echo ""
		echo -e "\033[31m JSVM decoded failed ! \033[0m"
		echo ""
		EncoderCheckResult="1-Encoder failed!-JSVM decode failed!"
		DecoderCheckResult="3-Decoder cannot be checked!"
		runOutputCheckLog >${CheckLogFile}
		exit 1
	fi

	#check RecYUV--JSVMDecYUV WelsDecYUV--JSVMDecYUV
	echo "-------------------3. JSVM Check--WelsDecoder Decode Check"
    date
	runWelsDecodedFailedCheck  >${TempDataPath}/WelsDecTemp.log

	runGenerateSHA1String
	echo "-------------------4. JSVM Check--RecYUV-JSVMDecYUV-WelsDecYUV Comparison"
    date
	runRecYUVJSVMDecYUCompare
	if [ ${FinalCheckFlag} -eq 0 ]
	then
		echo ""
		echo -e "\033[32m  Passed!:RecYUV--JSVMDecYUV WelsDecYUV--JSVMDecYUV \033[0m"
		echo ""
		runOutputCheckLog >${CheckLogFile}
		runOutputCheckInfo
		return 0
	else
		echo ""
		echo -e "\033[31m Failed!:RecYUV--JSVMDecYUV WelsDecYUV--JSVMDecYUV \033[0m"
		echo ""
		runOutputCheckLog >${CheckLogFile}
		runOutputCheckInfo
		return 1
	fi

}
runTestExample()
{
    #test input paramter, and part of these params have been expored in run_TestOneCase.sh
    CheckLogFile="TempData/CaseCheck.log"
    TempDataPath="TempData"
    InputYUV="./horse_riding_640x512_30.yuv"
    BitStream="TempData/horse_riding_640x512_30.yuv_SubCaseIndex_0_CaseIndex_12wels.264"
    let "SpatialLayerNum=1"

    aRecCropYUVFileList[0]="TempData/horse_riding_640x512_30.yuv_rec0.yuv"
    aRecCropYUVFileList[1]="TempData/horse_riding_640x512_30.yuv_rec1.yuv"
    aRecCropYUVFileList[2]="TempData/horse_riding_640x512_30.yuv_rec2.yuv"
    aRecCropYUVFileList[3]="TempData/horse_riding_640x512_30.yuv_rec3.yuv"
}

#*****************************************************************
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo "*********************************************************"
echo ""
runMain $@


