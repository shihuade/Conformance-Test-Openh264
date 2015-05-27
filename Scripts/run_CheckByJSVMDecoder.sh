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
	declare -a aParameter
	declare -a aLayerBitStream
	declare -a aLayerJSVMYUV
	declare -a aLayerWelsDecYUV
	declare -a aLayerRecYUV

	#for sha1 comparison
	declare -a aRecYUVSHA1String
	declare -a aWelsDecYUVSHA1String
	declare -a aJSVMYUVSHA1String

	let "WelsDecodedFailedFlag=0"
	let "FinalCheckFlag=0"
	let "RecJSVMFlag=0"
	let "WelsDecJSVMFlag=0"
	let "SpatialLayerNum=0"

	JSVMDecoderLog=""
	WelsDecoderLog=""
	OringInputYUV=""
	BitStream=""
	TempDir=""
	CheckLogFile=""
	JSVMDecoder="H264AVCDecoderLibTestStatic"
	JMDecoder="JMDecoder"
	WelsDecoder="h264dec"

	BitStreamSHA1String="NULL"
	InputYUVSHA1String="NULL"
	BitStreamMD5String="NULL"
	InputYUVMD5String="NULL"

	EncoderCheckResult="NULL"
	DecoderCheckResult="NULL"

}
runSetGlobalParam()
{
	CurrentDir=`pwd`
	cd ${TempDir}
	TempDir=`pwd`
	cd ${CurrentDir}

	JSVMDecoderLog="${TempDir}/JSVMDecoder.log"
	WelsDecoderLog="${TempDir}/WelsDecoder.log"

	for((i=0;i<4;i++))
	do
		aLayerBitStream[$i]="${TempDir}/BitStream_Layer_${i}.264"
		aLayerJSVMYUV[$i]="${TempDir}/Dec_JSVMr_${i}.yuv"
		aLayerWelsDecYUV[$i]="${TempDir}/Dec_WelsDec_${i}.yuv"
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
	echo "BitStreamMD5String:  ${BitStreamMD5String}"
	echo "InputYUVSHA1String:  ${InputYUVSHA1String}"
	echo "InputYUVMD5String:   ${InputYUVMD5String}"
	echo "EncoderCheckResult: ${EncoderCheckResult}"
	echo "DecoderCheckResult: ${DecoderCheckResult}"
}
runJSVMDecodedFailedCheck()
{
	echo "">${JSVMDecoderLog}
	for((i=0; i<${SpatialLayerNum}; i++))
	do
		echo " JSVM decoding, layer $i.....................">>${JSVMDecoderLog}
		./${JSVMDecoder}   ${aLayerBitStream[$i]}  ${aLayerJSVMYUV[$i]} >>${JSVMDecoderLog}

		if [ ! $? -eq 0  -o  ! -e ${aLayerJSVMYUV[$i]} ]
		then
			echo ""
			echo -e "\033[31m JSVM decoded failed!  \033[0m"
			echo ""
			cat ${JSVMDecoderLog}
			return 1
		fi
	done

	cat ${JSVMDecoderLog}
	return 0
}
runWelsDecodedFailedCheck()
{
	echo "">${WelsDecoderLog}
	for((i=0; i<${SpatialLayerNum}; i++))
	do
		echo " WelsDecoder decoding, layer $i..................... ">>${WelsDecoderLog}
		./${WelsDecoder}  ${aLayerBitStream[$i]}  ${aLayerWelsDecYUV[$i]}  2>>${WelsDecoderLog}

		if [ ! $? -eq 0  -o  ! -e ${aLayerWelsDecYUV[$i]} ]
		then
			echo ""
			echo -e "\033[31m WelsDecoder decoded failed! \033[0m"
			echo ""
			let "WelsDecodedFailedFlag=1"
			cat ${WelsDecoderLog}
			return 1
		fi
	done
	cat ${WelsDecoderLog}
	return 0
}
runGenerateSHA1String()
{
	for((i=0; i<${SpatialLayerNum}; i++))
	do
		if [ -e  ${aLayerJSVMYUV[$i]}  ]
		then
			aJSVMYUVSHA1String[$i]=`openssl sha1  ${aLayerJSVMYUV[$i]}`
			aJSVMYUVSHA1String[$i]=`echo ${aJSVMYUVSHA1String[$i]}  | awk '{print $2}' `
		fi

		if [ -e  ${aLayerWelsDecYUV[$i]}  ]
		then
			aWelsDecYUVSHA1String[$i]=`openssl sha1  ${aLayerWelsDecYUV[$i]}`
			aWelsDecYUVSHA1String[$i]=`echo ${aWelsDecYUVSHA1String[$i]}  | awk '{print $2}' `
		fi

		if [ -e  ${aLayerRecYUV[$i]}  ]
		then
			aRecYUVSHA1String[$i]=`openssl sha1  ${aLayerRecYUV[$i]}`
			aRecYUVSHA1String[$i]=`echo ${aRecYUVSHA1String[$i]}  | awk '{print $2}' `
		fi
	done

	if [ -e ${BitStream} ]
	then
		BitStreamSHA1String=`openssl sha1  ${BitStream}`
		BitStreamSHA1String=`echo ${BitStreamSHA1String}  | awk '{print $2}' `

		BitStreamMD5String=`openssl md5   ${BitStream}`
		BitStreamMD5String=`echo ${BitStreamMD5String}  | awk '{print $2}' `
	fi
	if [ -e ${OringInputYUV} ]
	then
		InputYUVSHA1String=`openssl sha1  ${OringInputYUV} `
		InputYUVSHA1String=`echo ${InputYUVSHA1String}  | awk '{print $2}' `

		InputYUVMD5String=`openssl md5  ${OringInputYUV}`
		InputYUVMD5String=`echo ${InputYUVMD5String}  | awk '{print $2}' `
	fi

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

	if [ ! -d ${TempDir}  ]
	then
		echo ""
		echo -e "\033[31m TempDir  ${TempDir} does not exist !\033[0m"
		echo ""
		return 1
	fi

	for((i=0; i<${SpatialLayerNum}; i++))
	do
		if [ ! -e ${aLayerRecYUV[$i]}  ]
		then
			echo ""
			echo -e "\033[31m RecYUV ${aLayerRecYUV[$i]}  does not exist! \033[0m"
			echo ""
			return 1
		fi

	done

	if [  ! -e ${JSVMDecoder}  -o ! -e ${JMDecoder} -o ! -e ${WelsDecoder}   ]
	then
		echo ""
		echo -e "\033[31m  ${JSVMDecoder}  or ${JMDecoder} or  ${WelsDecoder} does not exist !\033[0m"
		echo ""
		return 1
	fi

	if [ ! -e ${OringInputYUV}  ]
	then
		echo ""
		echo -e "\033[31m  OringInputYUV ${OringInputYUV} does not exist!\033[0m"
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
	echo "BitStreamMD5String     ${BitStreamMD5String} "
	echo "InputYUVMD5String      ${InputYUVMD5String}"

	echo ""
	echo "WelsDecodedFailedFlag  ${WelsDecodedFailedFlag}"
	echo "FinalCheckFlag         ${FinalCheckFlag}"
	echo "RecJSVMFlag            ${RecJSVMFlag} "
	echo "WelsDecJSVMFlag        ${WelsDecJSVMFlag}"
	echo "SpatialLayerNum        ${SpatialLayerNum}"
}
#usage: run_CheckByJSVMDecoder.sh ${CheckLogFile} ${TempDir}  ${OringInputYUV} ${BitStream}  ${SpatialNum} ${aRecYUVList[@]}
runMain()
{
	if [  ! $# -eq 9  ]
	then
		echo ""
		echo -e "\033[31m Usage: run_CheckByJSVMDecoder.sh  \${CheckLogFile} \${TempDir}  \${OringInputYUV} \${BitStream}  \${SpatialNum} \${aRecYUVList[@]}  \033[0m"
		echo ""
		exit 1
	fi

	runIntialGlobalParam

	aParameter=( $@ )
	CheckLogFile=${aParameter[0]}
	TempDir=${aParameter[1]}
	OringInputYUV=${aParameter[2]}
	BitStream=${aParameter[3]}
	let "SpatialLayerNum=${aParameter[4]}"

	for((i=0;i<4;i++))
	do
		let "RecINdex =  5 + $i"
		aLayerRecYUV[$i]=${aParameter[$RecINdex]}
	done

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

	echo "-------------------2. JSVM Check--JSVM Decode Check"
	runJSVMDecodedFailedCheck
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
	runWelsDecodedFailedCheck  >${TempDir}/WelsDecTemp.log

	runGenerateSHA1String
	echo "-------------------4. JSVM Check--RecYUV-JSVMDecYUV-WelsDecYUV Comparison"
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
runMain $@


