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

	BitStreamFile=""

	EncoderLog="${TempDataPath}/encoder.log"
	FPS="NULL"

	let "EncoderNum=-1"
	let "SpatailLayerNum=1"
	let "RCMode=0"
    let "MultiThreadFlag=0"

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
	aEncoderCommandSet=( -utype  -frms  -numl   -numtl \
					-sw -sh  "-dw 0"  "-dh 0" "-dw 1" "-dh 1" "-dw 2" "-dh 2" "-dw 3" "-dh 3" \
					"-frout 0" "-frout 1" "-frout 2" "-frout 3" \
					"-lqp 0" "-lqp 1" "-lqp 2" "-lqp 3" \
					-rc -fs -tarb "-ltarb 0" 	"-ltarb 1" "-ltarb 2" "-ltarb 3" \
					"-slcmd 0" "-slcnum 0" "-slcmd 1" "-slcnum 1"\
					"-slcmd 2" "-slcnum 2" "-slcmd 3" "-slcnum 3"\
					-nalsize \
					-iper   -thread  " -loadbalancing "  -ltr \
					-db  -denois    -scene    -bgd    -aq )
	aEncoderCommandName=(usagetype  frms  numl   numtl \
					sw sh  dw0 dh0 dw1 dh1 dw2 dh2 dw3 dh3 \
					frout0 frout1 frout2 frout3 \
					lqp0 lqp1 lqp2 lqp3 \
					rc FrSkip tarb ltarb0 	ltarb1 ltarb2 ltarb3 \
					slcmd0 slcnum0 slcmd1 slcnum1 \
					slcmd2 slcnum2 slcmd3 slcnum3 \
					MaxNalSZ  \
					iper   thread  ltr \
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
    local CaseData=$@
	aEncoderCommandValue=(`echo $CaseData |awk 'BEGIN {FS="[,\r]"} {for(i=1;i<=NF;i++) printf(" %s",$i)} ' `)
}

runSetCaseGlobalParam()
{
    BitStreamFile=${TempDataPath}/${TestYUVName}_SubCaseIndex_${SubCaseIndex}_CaseIndex_${CaseIndex}wels.264
	let "EncoderNum      = ${aEncoderCommandValue[1]}"
	let "SpatailLayerNum = ${aEncoderCommandValue[2]}"
	let "RCMode          = ${aEncoderCommandValue[22]}"
    let "MultiThreadFlag = ${aEncoderCommandValue[38]}"

	for((i=0;i<4;i++))
	do
		aRecYUVFileList[$i]="${TempDataPath}/${TestYUVName}_rec${i}.yuv"
		aRecCropYUVFileList[$i]="${TempDataPath}/${TestYUVName}_rec${i}_cropped.yuv"
	done

	aInputYUVSizeLayer=( ${YUVSizeLayer0} ${YUVSizeLayer1} ${YUVSizeLayer2} ${YUVSizeLayer3} )

	aEncodedPicW=( ${aEncoderCommandValue[6]} ${aEncoderCommandValue[8]} ${aEncoderCommandValue[10]} ${aEncoderCommandValue[12]})
	aEncodedPicH=( ${aEncoderCommandValue[7]} ${aEncoderCommandValue[9]} ${aEncoderCommandValue[11]} ${aEncoderCommandValue[13]})

}
#call by  runAllCaseTest
#usage  runEncodeOneCase
runEncodeOneCase()
{

	local ParamCommand=""
	for ((i=4; i<${NumParameter}; i++))
	do
		ParamCommand="${ParamCommand} ${aEncoderCommandSet[$i]}  ${aEncoderCommandValue[$i]} "
	done


	ParamCommand="${aEncoderCommandSet[0]} ${aEncoderCommandValue[0]} ${aEncoderCommandSet[1]}  ${aEncoderCommandValue[1]} \
				 ${aEncoderCommandSet[2]}  ${aEncoderCommandValue[2]} \
				-lconfig 0 layer0.cfg -lconfig 1 layer1.cfg -lconfig 2 layer2.cfg  -lconfig 3 layer3.cfg  \
				${aEncoderCommandSet[3]}  ${aEncoderCommandValue[3]}  \
				${ParamCommand}"
	echo ""
	echo "---------------Encode One Case-------------------------------------------"
	echo "case line is :"
	EncoderCommand="./h264enc  welsenc.cfg    ${ParamCommand} -bf   ${BitStreamFile} \
				-drec 0 ${RecYUVFile0} -drec 1 ${RecYUVFile1} \
				-drec 2 ${RecYUVFile2} -drec 3 ${RecYUVFile3}  -org ${InputYUV}"
	echo ${EncoderCommand}
	./h264enc  welsenc.cfg    ${ParamCommand} -bf   ${BitStreamFile} \
				-drec 0 ${RecYUVFile0} -drec 1 ${RecYUVFile1} \
				-drec 2 ${RecYUVFile2} -drec 3 ${RecYUVFile3}  -org ${InputYUV}>${EncoderLog}

	if [ $? -eq 0  ]
	then
		let "EncoderFlag=0"
	else
		let "EncoderFlag=1"
	fi
	
	#delete the core down file as core down files for disk space limitation
	for file in  ./core*
	do
		if [ -e ${file} ]
		then
			./run_SafeDelete.sh  ${file}
		fi
	done
	
	cat  ${EncoderLog}
	return 0

}

runParseEncoderLog()
{
    #encoded log looks like:
    #*********************************
    #Width:		640
    #Height:		480
    #Frames:		445
    #encode time:	2.440146 sec
    #FPS:		182.366137 fps
    #*********************************

    FPS=(`cat ${EncoderLog} | grep "FPS" | awk '{print $2}' `)
}

#usage runParseCaseCheckLog  ${CheckLog}
runParseCaseCheckLog()
{
	if [  ! $# -eq 1  ]
	then
		echo "usage: runParseCaseCheckLog  \${CheckLog}"
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
	
	#generate SHA1 string for bit stream and input YUV no matter failed or not
	if [ -e ${BitStreamFile} ]
	then
		BitStreamSHA1String=`openssl sha1  ${BitStreamFile}`
		BitStreamSHA1String=`echo ${BitStreamSHA1String}  | awk '{print $2}' `

		BitStreamMD5String=`openssl md5   ${BitStreamFile}`
		BitStreamMD5String=`echo ${BitStreamMD5String}  | awk '{print $2}' `
	fi
	if [ -e  ${InputYUV} ]
	then
		InputYUVSHA1String=`openssl sha1  ${InputYUV} `
		InputYUVSHA1String=`echo ${InputYUVSHA1String}  | awk '{print $2}' `

		InputYUVMD5String=`openssl md5  ${InputYUV}`
		InputYUVMD5String=`echo ${InputYUVMD5String}  | awk '{print $2}' `
	fi
	
}
runOutputCaseCheckStatus()
{
	#date info
	date
	local TestTime=`date`

    echo "line writed to SHA1 talbe is:"
    echo " ${BitStreamSHA1String}, ${BitStreamMD5String}, ${InputYUVSHA1String},${InputYUVMD5String}, ${CaseInfo}"

    echo "line writed to AllCases file is:"
    echo " ${EncoderCheckResult},${DecoderCheckResult}, ${FPS}, ${BitStreamSHA1String}, ${BitStreamMD5String}, ${InputYUVSHA1String},${InputYUVMD5String}, ${TestCaseInfo}, ${TestTime},${EncoderCommand} "


    echo " ${BitStreamSHA1String}, ${BitStreamMD5String}, ${InputYUVSHA1String},${InputYUVMD5String}, ${CaseInfo}">>${AssignedCasesSHATableFile}
    echo " ${EncoderCheckResult},${DecoderCheckResult}, ${FPS}, ${BitStreamSHA1String}, ${BitStreamMD5String}, ${InputYUVSHA1String},${InputYUVMD5String}, ${TestCaseInfo}, ${TestTime},${EncoderCommand} ">>${AssignedCasesPassStatusFile}

	if [ ${BasicCheckFlag} -eq 1 -o  ${JSVMCheckFlag} -eq 1 ]
	then
		echo " ${EncoderCheckResult},${DecoderCheckResult}, ${FPS}, ${BitStreamSHA1String}, ${BitStreamMD5String}, ${InputYUVSHA1String},${InputYUVMD5String}, ${TestCaseInfo}, ${EncoderCommand}">>${UnPassedCasesFile}
	fi
}
runOutputCaseInfo()
{
	echo ""
	echo "EncoderNum ${EncoderNum}"
	echo "EncoderNum  ${EncoderNum}"
	echo "SpatailLayerNum:  ${SpatailLayerNum}"
	echo "RCMode   ${RCMode}"

	for((i=0;i<4;i++))
	do
		echo "aInputYUVSizeLayer $i : ${aInputYUVSizeLayer[$i]}"
		echo "PicW x PicH           : ${aEncodedPicW[$i]}x${aEncodedPicH[$i]}"
	done

}
runBasicCheck()
{
	./run_CheckBasicCheck.sh  ${EncoderFlag}  ${EncoderLog} ${EncoderNum}  ${SpatailLayerNum} ${RCMode} ${CheckLogFile} \
							${aInputYUVSizeLayer[@]} ${aRecYUVFileList[@]} ${aRecCropYUVFileList[@]}  ${aEncodedPicW[@]} ${aEncodedPicH[@]}
	#copy bit stream file to ./issue folder;do not copy those cases which RecYUV does not exist!
    if [ $? -eq 0  ]
    then
        return 0
    elif [ $? -eq 2  ]  #  $?==2: means rec yuv doest not exist
    then
        return 1
    else
		if [ -e ${BitStreamFile}  ]
		then
            #currently, only copy when multi thread is enable
            if [ ${MultiThreadFlag} -gt 1 ]
            then
                cp ${BitStreamFile}  ${IssueDataPath}
            fi
        fi
		return 1
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
			#cp ${BitStreamFile}  ${IssueDataPath}
			Action="you can open the annotation to save the issue bit stream"
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
	CheckLogFile="${TempDataPath}/CaseCheck.log"
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
		runParseCaseCheckLog ${CheckLogFile}
		runOutputCaseCheckStatus
		exit 1
	fi

	runJSVMCheck
	if [ ! $? -eq 0  ]
	then
		echo  -e "\033[31m  case failed! \033[0m"
		let "JSVMCheckFlag=1"
		runParseCaseCheckLog ${CheckLogFile}
		runOutputCaseCheckStatus
		exit 1
	fi

	#get FPS info from encoder log
	runParseEncoderLog
    echo "FPS is $FPS"
	runParseCaseCheckLog ${CheckLogFile}
	runOutputCaseCheckStatus
    echo "main end"
#return 0
}

TestCaseExample()
{
    TestPlatform="Mac"
    JMDecoder="JMDecoder"
    JSVMDecoder="H264AVCDecoderLibTestStatic"
    IssueDataPath="issue"
    TempDataPath="TempData"

    mkdir -p ${IssueDataPath} ${TempDataPath}
    TestYUVName="horse_riding_640x512_30.yuv"
    InputYUV="./horse_riding_640x512_30.yuv"
    AssignedCasesPassStatusFile="Example_TestOneCase_AssignedCasesPassStatusFile.csv"
    UnPassedCasesFile="Example_TestOneCase_UnPassedCasesFile.csv"
    AssignedCasesSHATableFile="Example_TestOneCase_AssignedCasesSHATableFile.csv"

    EncodedFrmNum=65
    NumberLayer=1

    YUVSizeLayer0=31948800
    YUVSizeLayer1=0
    YUVSizeLayer2=0
    YUVSizeLayer3=0

    RecYUVFile0="${TempDataPath}/${TestYUVName}_rec_0.yuv"
    RecYUVFile1="${TempDataPath}/${TestYUVName}_rec_1.yuv"
    RecYUVFile2="${TempDataPath}/${TestYUVName}_rec_2.yuv"
    RecYUVFile3="${TempDataPath}/${TestYUVName}_rec_3.yuv"

    RecCropYUV0="${TempDataPath}/${TestYUVName}_rec_0_cropped.yuv"
    RecCropYUV1="${TempDataPath}/${TestYUVName}_rec_1_cropped.yuv"
    RecCropYUV2="${TempDataPath}/${TestYUVName}_rec_2_cropped.yuv"
    RecCropYUV3="${TempDataPath}/${TestYUVName}_rec_3_cropped.yuv"

    SubCaseIndex=0
    CaseIndex=12

    #export variables have been export in run_TestAssignedCases.sh
    export SubCaseIndex
    export CaseIndex
    export TestPlatform
    export JMDecoder
    export JSVMDecoder
    export WelsDecoder
    export IssueDataPath
    export TempDataPath

    export NumberLayer
    export YUVSizeLayer0
    export YUVSizeLayer1
    export YUVSizeLayer2
    export YUVSizeLayer3

    export RecYUVFile0
    export RecYUVFile1
    export RecYUVFile2
    export RecYUVFile3

    export RecCropYUV0
    export RecCropYUV1
    export RecCropYUV2
    export RecCropYUV3



    CaseInfo="0, 65 , 1, 1, 640, 512, 640,512,0,0,0,0,0,0, 10, 10,10,10, 26, 26, 26, 26, -1, 0, 400.00,400.00,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0"
    date >Example_Test.log
    StartTime=`date`
    for((k=0; k<2; k++))
    do
       echo -e "\n example index is $k \n"
       runMain  ${CaseInfo}
    done
    EndTime=`date`
    echo "StartTime: ${StartTime}"
    echo "EndTime  : ${EndTime}"
}

Temp(){
CaseInfo=$@
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo "*********************************************************"
echo ""
runMain  ${CaseInfo}

}

TestCaseExample