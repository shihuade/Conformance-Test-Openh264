#!/bin/bash
#***************************************************************************************
# brief: test one case and check whether this case pass conformance test with JSVM decoder
#
#
#usage: run_TestOneCase.sh \${CaseInfo}
#
#date:  5/08/2014 Created
#***************************************************************************************
runGlobalVariableInitial()
{
	#initial command line parameters
	declare -a aEncoderCommandSet
	declare -a aEncoderCommandName
	declare -a aEncoderCommandValue
	declare -a aInputYUVSizeLayer
	declare -a aRecYUVFileList
	declare -a aRecCropYUVFileList
	declare -a aEncodedPicW
	declare -a aEncodedPicH
	BitstreamPrefix=""
	BitStreamFile=""
	EncoderLog="${TempDataPath}/encoder.log"
	let "EncoderNum=-1"
	let "SpatailLayerNum=1"
	let "RCMode=0"
	ActualFPS="NULL"
	BitRate="NULL"
	BitStreamSHA1String="NULL"
	BitStreamMD5String="NULL"
	InputYUVSHA1String="NULL"
	InputYUVMD5String="NULL"
	EncoderCheckResult="NULL"
	DecoderCheckResult="NULL"
	EncoderCommand="NULL"
	let "EncoderFlag=0"
}
#called by runGlobalVariableInitial
#usage runEncoderCommandInital
runEncoderCommandInital()
{
	aEncoderCommandSet=(-scrsig  -frms  -numl   -numtl \
				-sh -sw  "-sw 0"  "-sh 0" "-sw 1" "-sh 1" "-sw 2" "-sh 2" "-sw 3" "-sh 3" \
				"-frout 0" "-frout 1" "-frout 2" "-frout 3" \
				"-lqp 0" "-lqp 1" "-lqp 2" "-lqp 3" \
				-rc -tarb "-ltarb 0" 	"-ltarb 1" "-ltarb 2" "-ltarb 3" \
				"-slcmd 0" "-slcnum 0" "-slcmd 1" "-slcnum 1"\
				"-slcmd 2" "-slcnum 2" "-slcmd 3" "-slcnum 3"\
				"-slcsize 0"  "-slcsize 1" "-slcsize 2" "-slcsize 3" \
				-iper  -gop  -thread    -ltr \
				-db  -denois    -scene    -bgd    -aq )
	aEncoderCommandName=(scrsig  frms  numl   numtl \
				sw sh  sw0 sh0 sw1 sh1 sw2 sh2 sw3 sh3 \
				frout0 frout1 frout2 frout3 \
				lqp0 lqp1 lqp2 lqp3 \
				rc tarb ltarb0 	ltarb1 ltarb2 ltarb3 \
				slcmd0 slcnum0 slcmd1 slcnum1 \
				slcmd2 slcnum2 slcmd3 slcnum3 \
				slcsz0 slcsz1  slcsz2 slcsz3  \
				iper gop   thread  ltr \
				db  denois  scene  bgd  aq )
	NumParameter=${#aEncoderCommandSet[@]}
	for ((i=0;i<NumParameter; i++))
	do
		aEncoderCommandValue[$i]=0
	done
}
#***********************************************************
#call by  runAllCaseTest
# parse case info --encoder preprocess
#usage  runGetaEncoderCommandValue $CaseData
runParseCaseInfo()
{
	if [ $#  -lt 1  ]
	then
		echo "no parameter!"
		return 1
	fi
	local TempData=""
	local CaseData=$@
	declare -a aTempParamIndex=( 6 7 8 9 10 11 12 13    15 16 17   19 20 21     24 25 26 27   30 31 32 33 34 35  37 38 39 )
	TempData=`echo $CaseData |awk 'BEGIN {FS="[,\r]"} {for(i=1;i<=NF;i++) printf(" %s",$i)} ' `
	aEncoderCommandValue=(${TempData})
	let "TempParamFlag=0"
	for((i=0; i<$NumParameter; i++))
	do
		for ParnmIndex in ${aTempParamIndex[@]}
		do
		  if [  $i -eq ${ParnmIndex} ]
		  then
				let "TempParamFlag=1"
		  fi
		done
		if [ ${TempParamFlag} -eq 0 ]
		then
			BitstreamPrefix=${BitstreamPrefix}_${aEncoderCommandName[$i]}_${aEncoderCommandValue[$i]}
		fi
		let "TempParamFlag=0"
	done
}
runSetCaseGlobalParam()
{
	BitStreamFile=${TempDataPath}/${TestYUVName}_${BitstreamPrefix}_welsrubyenc.264
	let "EncoderNum      = ${aEncoderCommandValue[1]}"
	let "SpatailLayerNum = ${aEncoderCommandValue[2]}"
	let "RCMode          = ${aEncoderCommandValue[22]}"
	for((i=0;i<4;i++))
	do
		aRecYUVFileList[$i]="${TempDataPath}/${TestYUVName}_rec${i}.yuv"
		aRecCropYUVFileList[$i]="${TempDataPath}/${TestYUVName}_rec${i}_cropped.yuv"
	done
	declare -a aTempInputYUVSize
	aTempInputYUVSize=( ${YUVSizeLayer0} ${YUVSizeLayer1} ${YUVSizeLayer2} ${YUVSizeLayer3} )
	aInputYUVSizeLayer=( 0 0 0 0 )
	for((i=0;i<${SpatailLayerNum};i++))
	do
		let "InputYUVSizeIndex=$i + 4 - ${SpatailLayerNum}"
		aInputYUVSizeLayer[$i]=${aTempInputYUVSize[$InputYUVSizeIndex]}
	done
	aEncodedPicW=( ${aEncoderCommandValue[6]} ${aEncoderCommandValue[8]} ${aEncoderCommandValue[10]} ${aEncoderCommandValue[12]})
	aEncodedPicH=( ${aEncoderCommandValue[7]} ${aEncoderCommandValue[9]} ${aEncoderCommandValue[11]} ${aEncoderCommandValue[12]})
}
#call by  runAllCaseTest
#usage  runEncodeOneCase
runEncodeOneCase()
{
	local ParamCommand=""
	local InputYUVCommand=""
	local CfgFileCommand=""
	let "FPS=${aEncoderCommandValue[14]}"
	declare -a aConfigureFile
	declare -a aLayerInputYUV
	aConfigureFile=(layer0.cfg layer1.cfg layer2.cfg layer3.cfg  )
	aLayerInputYUV=(${YUVFileLayer0} ${YUVFileLayer1} ${YUVFileLayer2} ${YUVFileLayer3} )
	CfgFileCommand="-numl ${SpatailLayerNum}  "
	for((i=0;i<${SpatailLayerNum};i++))
	do
		let "InputIndex=$i + 4 - ${SpatailLayerNum}"
		CfgFileCommand="${CfgFileCommand} ${aConfigureFile[$i]} "
		InputYUVCommand="$InputYUVCommand  -org $i ${aLayerInputYUV[$InputIndex]} "
	done
	for ((i=6; i<${NumParameter}; i++))
	do
		ParamCommand="${ParamCommand} ${aEncoderCommandSet[$i]}  ${aEncoderCommandValue[$i]} "
	done
	ParamCommand="${aEncoderCommandSet[0]} ${aEncoderCommandValue[0]} ${aEncoderCommandSet[1]}  ${aEncoderCommandValue[1]} \
				${aEncoderCommandSet[3]}  ${aEncoderCommandValue[3]} -frin 0 ${FPS} -frin 1 ${FPS} -frin 2 ${FPS} -frin 3 ${FPS} \
				${ParamCommand}"
	echo ""
	echo "---------------Encode One Case-------------------------------------------"
	echo "case line is :"
	EncoderCommand="./welsenc.exe  wbxenc.cfg  ${CfgFileCommand}   ${ParamCommand} -bf   ${BitStreamFile} \
				-drec 0 ${aRecYUVFileList[0]} -drec 1 ${aRecYUVFileList[1]} \
				-drec 2 ${aRecYUVFileList[2]} -drec 3 ${aRecYUVFileList[3]}  ${InputYUVCommand}"
	echo ${EncoderCommand}
	./welsenc.exe  wbxenc.cfg  ${CfgFileCommand}   ${ParamCommand} -bf   ${BitStreamFile} \
				-drec 0 ${aRecYUVFileList[0]} -drec 1 ${aRecYUVFileList[1]} \
				-drec 2 ${aRecYUVFileList[2]} -drec 3 ${aRecYUVFileList[3]}  ${InputYUVCommand}>${EncoderLog}
	if [ $? -eq 0  ]
	then
		let "EncoderFlag=0"
	else
		let "EncoderFlag=1"
	fi
	echo ""
	cat ${EncoderLog}
}
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
runParseEncoderLog()
{
	while read line
	do
		if [[ $line =~ ^Performance  ]]
		then
			#Performance capability by FPS: 416.542
			ActualFPS=`echo $line | awk 'BEGIN {FS="FPS:"} {print $2}'`
			echo "ActualFPS line is  $line"
			echo "ActualFPS ${ActualFPS}"
		elif [[ $line =~ ^Actual  ]]
		then
			#Actual bitrate (kbps):   304.332
			BitRate=`echo $line | awk '{print $4}'`
			echo "BitRate line is $line "
			echo "BitRate ${BitRate}"
		fi
	done <${EncoderLog}
}
#usage runParsetCaseCheckLog  ${CheckLog}
runParsetCaseCheckLog()
{
	if [  ! $# -eq 1  ]
	then
		echo "usage: runParsetCaseCheckLog  \${CheckLog}"
		return 1
	fi
	local CheckLog=$1
	if [ ! -e ${CheckLog}  ]
	then
		echo "check log does not exist!"
		return 1
	fi
	while read line
	do
		if [[  "$line" =~ ^EncoderCheckResult  ]]
		then
			EncoderCheckResult=`echo $line | awk 'BEGIN {FS="[:\r]"} {print $2}'`
		elif [[ "$line" =~ ^DecoderCheckResult ]]
		then
			DecoderCheckResult=`echo $line | awk 'BEGIN {FS="[:\r]"} {print $2}'`
		elif [[ "$line" =~ ^BitStreamSHA1String ]]
		then
			BitStreamSHA1String=`echo $line | awk 'BEGIN {FS="[:\r]"} {print $2}'`
		elif [[ "$line" =~ ^BitStreamMD5String ]]
		then
			BitStreamMD5String=`echo $line | awk 'BEGIN {FS="[:\r]"} {print $2}'`
		elif [[ "$line" =~ ^InputYUVSHA1String ]]
		then
			InputYUVSHA1String=`echo $line | awk 'BEGIN {FS="[:\r]"} {print $2}'`
		elif [[ "$line" =~ ^InputYUVMD5String ]]
		then
			InputYUVMD5String=`echo $line | awk 'BEGIN {FS="[:\r]"} {print $2}'`
		fi
	done <${CheckLog}
}
runOutputCaseCheckStatus()
{
	 echo " ${BitStreamSHA1String}, ${BitStreamMD5String}, ${InputYUVSHA1String},${InputYUVMD5String}, ${CaseInfo}">>${AllCasesSHATableFile}
	 echo " ${EncoderCheckResult},${DecoderCheckResult},${ActualFPS},${BitRate},${BitStreamSHA1String}, ${BitStreamMD5String}, ${InputYUVSHA1String},${InputYUVMD5String}, ${TestCaseInfo}, ${EncoderCommand} ">>${AllCasesPassStatusFile}
	if [ ${BasicCheckFlag} -eq 1 -o  ${JSVMCheckFlag} -eq 1 ]
	then
		echo " ${EncoderCheckResult},${DecoderCheckResult},${ActualFPS},${BitRate},${BitStreamSHA1String}, ${BitStreamMD5String}, ${InputYUVSHA1String},${InputYUVMD5String}, ${TestCaseInfo}, ${EncoderCommand}">>${UnPassedCasesFile}
	fi
}
runOutputCaseInfo()
{
	echo "YUVFileLayer3:  ${YUVFileLayer3}"
	echo "YUVSizeLayer3:  ${YUVSizeLayer3}"
	echo "YUVFileLayer2:  ${YUVFileLayer2}"
	echo "YUVSizeLayer2:  ${YUVSizeLayer2}"
	echo "YUVFileLayer1:  ${YUVFileLayer1}"
	echo "YUVSizeLayer1:  ${YUVSizeLayer1}"
	echo "YUVFileLayer0:  ${YUVFileLayer0}"
	echo "YUVSizeLayer0:  ${YUVSizeLayer0}"
	echo ""
	echo "EncoderNum ${EncoderNum}"
	echo "EncoderNum  ${EncoderNum}"
	echo "SpatailLayerNum:  ${SpatailLayerNum}"
	echo "RCMode   ${RCMode}"
	for((i=0;i<4;i++))
	do
		echo "aInputYUVSizeLayer  $i : ${aInputYUVSizeLayer[$i]}"
		echo "aRecYUVFileList     $i : ${aRecYUVFileList[$i]}"
		echo "aRecCropYUVFileList $i :${aRecCropYUVFileList[$i]}"
		echo "PicWxPicH:  ${aEncodedPicW[$i]}x${aEncodedPicH[$i]}"
	done
}
runBasicCheck()
{
	./run_CheckBasicCheck.sh  ${EncoderFlag}  ${EncoderLog} ${EncoderNum}  ${SpatailLayerNum} ${RCMode} ${CheckLogFile} \
							${aInputYUVSizeLayer[@]} ${aRecYUVFileList[@]} ${aRecCropYUVFileList[@]}  ${aEncodedPicW[@]} ${aEncodedPicH[@]}
	#copy bit stream file to ./issue folder
	#$? = 2 are those cases RecYUV does not exist!
	if [ ! $? -eq 0  -a ! $? -eq 2 ]
	then
		if [ -e ${BitStreamFile}  ]
		then
			cp ${BitStreamFile}  ${IssueDataPath}
		fi
		return 1
	else
		return 0
	fi
}
runJSVMCheck()
{
	./run_CheckByJSVMDecoder.sh ${CheckLogFile} ${TempDataPath}  ${InputYUV} ${BitStreamFile}  ${SpatailLayerNum}  ${aRecYUVFileList[@]}
	#copy bit stream file to ./issue folder
	if [ ! $? -eq 0 ]
	then
		if [ -e ${BitStreamFile}  ]
		then
			cp ${BitStreamFile}  ${IssueDataPath}
		fi
		return 1
	else
		return 0
	fi
}
# usage: runMain $TestYUV  $InputYUV $AllCaseFile
runMain()
{
	if [  $# -lt 10  ]
	then
		echo "usage: run_TestOneCase.sh \${CaseInfo}"
		return 1
	fi
	#for test sequence info
	TestCaseInfo=$@
	runGlobalVariableInitial
	runEncoderCommandInital
	runParseCaseInfo ${TestCaseInfo}
	runSetCaseGlobalParam
	runEncodeOneCase
	echo ""
	let "BasicCheckFlag=0"
	let "JSVMCheckFlag=0"
	runBasicCheck
	if [ ! $? -eq 0  ]
	then
		echo  -e "\033[31m  case failed! \033[0m"
		let "BasicCheckFlag=1"
		runParsetCaseCheckLog ${CheckLogFile}
		runOutputCaseCheckStatus
		exit 1
	fi
	runJSVMCheck
	if [ ! $? -eq 0  ]
	then
		echo  -e "\033[31m  case failed! \033[0m"
		let "JSVMCheckFlag=1"
		runParsetCaseCheckLog ${CheckLogFile}
		runOutputCaseCheckStatus
		exit 1
	fi
	runParseEncoderLog
	runParsetCaseCheckLog ${CheckLogFile}
	runOutputCaseCheckStatus
	return 0
}
CaseInfo=$@
runMain  ${CaseInfo}

