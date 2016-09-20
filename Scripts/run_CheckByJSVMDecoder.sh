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
	let "RecJSVMFlag=1"
	let "WelsDecJSVMFlag=1"

    DiffInfo="diff.log"

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

   [ ${SpatialLayerNum} -eq 1 ] && aLayerBitStream[0]=${BitStream}

    aRecCropYUVFileList=($RecCropYUV0 $RecCropYUV1 $RecCropYUV2 $RecCropYUV3)

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
            echo -e "\033[31m\n JM decoded failed!  \n\033[0m"
            return 1
        fi
    done
    return 0
}

runJMJSVMDecodedCheck()
{
    if [  "${TestPlatform}" = "Mac" ]
    then
        runJMDecodedFailedCheck   >${TempDataPath}/JM_Decode_Temp.log
    else
        runJSVMDecodedFailedCheck >${TempDataPath}/JSVM_Decode_Temp.log
    fi

    if [  ! $? -eq 0 ]
    then
        echo -e "\033[31m\n JSVM decoded failed ! \n\033[0m"
        EncoderCheckResult="1-Encoder failed!-JSVM decode failed!"
        DecoderCheckResult="3-Decoder cannot be checked!"
        runOutputCheckLog >${CheckLogFile}
        exit 1
    fi
}

runWelsDecodedFailedCheck()
{
	for((i=0; i<${SpatialLayerNum}; i++))
	do
		echo " WelsDecoder decoding, layer $i..................... "
		./${WelsDecoder}  ${aLayerBitStream[$i]}  ${aLayerWelsDecYUV[$i]}

		if [ ! $? -eq 0  -o  ! -e ${aLayerWelsDecYUV[$i]} ]
		then
			echo -e "\033[31m\n WelsDecoder decoded failed! \n\033[0m"
			let "WelsDecodedFailedFlag=1"
			return 1
		fi
	done
	return 0
}

runGenerateSHA1StringAndCheckDiff()
{

	for((i=0; i<${SpatialLayerNum}; i++))
	do
        diff ${aLayerJSVMYUV[$i]} ${aLayerWelsDecYUV[$i]}    >${DiffInfo} && [ ! -s ${DiffInfo} ] && let "RecJSVMFlag=0"
        diff ${aLayerJSVMYUV[$i]} ${aRecCropYUVFileList[$i]} >${DiffInfo} && [ ! -s ${DiffInfo} ] && let "WelsDecJSVMFlag=0"
    done
}

runRecYUVJSVMDecYUCompare()
{
    #before this check,has passed JM/JSVM decoded test
	#for encoder check result
	if [ ${RecJSVMFlag} -eq 0  ]
	then
		let "EncoderPassedNum   = 1"
		let "EncoderUnPassedNum = 0"
        EncoderCheckResult="0-Encoder passed!"
	else
		let "EncoderPassedNum   = 0"
		let "EncoderUnPassedNum = 1"
        EncoderCheckResult="1-Encoder failed!--RecYUV--JSVMDecYUV does not match!"
	fi

	#for decoder check result
	if [  ${WelsDecodedFailedFlag} -eq 0  ]
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
			DecoderCheckResult="2-Decoder failed! DecYUV--JSVMDecYUV does not match"
		fi
    elif [ ${WelsDecodedFailedFlag} -eq 1 -a  ${RecJSVMFlag} -eq 1  ]
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
        echo -e "\033[31m\n bit stream  ${BitStream} does not exist! \n\033[0m"
        EncoderCheckResult="1-Encoder failed!--bit stream  ${BitStream} does not exist!!"
        DecoderCheckResult="3-Decoder cannot be checked!"
        runOutputCheckLog >${CheckLogFile}
        exit 1
	fi

	return 0
}
runOutputCheckInfo()
{
	echo "-------------------6. JSVM Check--Check Result"
	echo ""
	echo "WelsDecodedFailedFlag  ${WelsDecodedFailedFlag}"
	echo "FinalCheckFlag         ${FinalCheckFlag}"
	echo "RecJSVMFlag            ${RecJSVMFlag} "
	echo "WelsDecJSVMFlag        ${WelsDecJSVMFlag}"
	echo "SpatialLayerNum        ${SpatialLayerNum}"
}

runMain()
{
    runIntialGlobalParam
    runSetGlobalParam

    echo "---------------JSVM Check--------------------------------------------"
	echo "-------------------1. JSVM Check--extract bit stream"
    ./run_ExtractLayerBitStream.sh  ${SpatialLayerNum} ${BitStream}  ${aLayerBitStream[@]}
    if [  ! $? -eq 0 ]
    then
        echo -e "\033[31m\n failed to extract  bit stream ! \n\033[0m"
        EncoderCheckResult="1-Encoder failed!--Failed to extracted bit stream!"
        DecoderCheckResult="3-Decoder cannot be checked!"
        runOutputCheckLog >${CheckLogFile}
        exit 1
    fi

	echo "-------------------2. JSVM Check--JSVM Decode Check"
    runJMJSVMDecodedCheck

	echo "-------------------3. JSVM Check--WelsDecoder Decode Check"
    runWelsDecodedFailedCheck  >${TempDataPath}/WelsDecTemp.log

    echo "-------------------4. Generate SHA1"
    runGenerateSHA1StringAndCheckDiff

	echo "-------------------5. JSVM Check--RecYUV-JSVMDecYUV-WelsDecYUV Comparison"
	runRecYUVJSVMDecYUCompare
    runOutputCheckLog >${CheckLogFile}
    runOutputCheckInfo

    if [ ${FinalCheckFlag} -eq 0 ]
	then
		echo -e "\033[32m\n  Passed!:RecYUV--JSVMDecYUV WelsDecYUV--JSVMDecYUV \n\033[0m"
		return 0
	else
		echo -e "\033[31m\n Failed!:RecYUV--JSVMDecYUV WelsDecYUV--JSVMDecYUV \n\033[0m"
		return 1
	fi

}

#*****************************************************************
echo -e "\n*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
date
echo -e "\n*********************************************************\n"
if [  ! $# -eq 2  ]
then
    echo ""
    echo -e "\033[31m Usage: run_CheckByJSVMDecoder.sh   \${BitStream}  \${SpatialNum}  \033[0m"
    echo ""
    exit 1
fi

BitStream=$1
let "SpatialLayerNum=$2"

runMain

