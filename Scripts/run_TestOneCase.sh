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

	let "SpatailLayerNum=1"
	let "RCMode=0"
    let "MultiThreadFlag=0"
    let "EncoderFlag=0"
    let "FPS=30"

    BitStreamFile=""
	BitStreamSHA1String="NULL"
	EncoderCheckResult="NULL"
	DecoderCheckResult="NULL"
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

    BitStreamFile=${TempDataPath}/${TestYUVName}_SubCaseIndex_${SubCaseIndex}_CaseIndex_${CaseIndex}_openh264.264
}

runExportedCaseVariable()
{
    export PicW0;export PicW1;export PicW2;export PicW3
    export PicH0;export PicH1;export PicH2;export PicH3
}

#usage  runGetaEncoderCommandValue $CaseData
runParseCaseInfo()
{
    local CaseData=$@
	aEncoderCommandValue=(`echo $CaseData |awk 'BEGIN {FS="[,\r]"} {for(i=1;i<=NF;i++) printf(" %s",$i)} ' `)

    let "PicW0 = ${aEncoderCommandValue[6]}"
    let "PicW1 = ${aEncoderCommandValue[8]}"
    let "PicW2 = ${aEncoderCommandValue[10]}"
    let "PicW3 = ${aEncoderCommandValue[12]}"
    let "PicH0 = ${aEncoderCommandValue[7]}"
    let "PicH1 = ${aEncoderCommandValue[9]}"
    let "PicH2 = ${aEncoderCommandValue[11]}"
    let "PicH3 = ${aEncoderCommandValue[13]}"
    let "SpatailLayerNum = ${aEncoderCommandValue[2]}"
    let "RCMode          = ${aEncoderCommandValue[22]}"
    let "MultiThreadFlag = ${aEncoderCommandValue[38]}"
}

#usage  runEncodeOneCase
runEncodeOneCase()
{
	EncoderCommand=""
	for ((i=0; i<${NumParameter}; i++))
	do
		EncoderCommand="${EncoderCommand} ${aEncoderCommandSet[$i]}  ${aEncoderCommandValue[$i]} "
	done

	EncoderCommand="./h264enc  welsenc.cfg  -lconfig 0 layer0.cfg -lconfig 1 layer1.cfg -lconfig 2 layer2.cfg  -lconfig 3 layer3.cfg \
                    ${EncoderCommand} -bf ${BitStreamFile}  -org ${InputYUV} \
                    -drec 0 ${RecYUVFile0} -drec 1 ${RecYUVFile1} -drec 2 ${RecYUVFile2} -drec 3 ${RecYUVFile3}"
    echo -e "\n---------------Encode One Case-------------------------------------------\n"
    echo "Encoded command line is:"
    echo ${EncoderCommand}
    ${EncoderCommand} >${EncoderLog}
    [ ! $? -eq 0  ] && let "EncoderFlag=1"

	#delete the core down file as core down files for disk space limitation
	for file in  ./core*
	do
		[ -e ${file} ] && ./run_SafeDelete.sh  ${file}
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

runParseCaseCheckLog()
{
	if [ ! -e ${CheckLogFile}  ]
	then
		echo "check log does not exist!"
		return 1
	fi

    #case check log looks like:
    #*********************************
    #EncoderPassedNum:   1
    #EncoderUnPassedNum: 0
    #DecoderPassedNum:   1
    #DecoderUpPassedNum: 0
    #DecoderUnCheckNum:  0
    #EncoderCheckResult: 0-Encoder passed!
    #DecoderCheckResult: 0-Decoder passed!
    #*********************************
    EncoderCheckResult=`cat ${EncoderLog} | grep "EncoderCheckResult" | awk 'BEGIN {FS="[:\r]"} {print $2}'`
    DecoderCheckResult=`cat ${EncoderLog} | grep "DecoderCheckResult" | awk 'BEGIN {FS="[:\r]"} {print $2}'`
	
	#generate SHA1 string for bit stream
   [ -e ${BitStreamFile} ] && BitStreamSHA1String=`openssl sha1  ${BitStreamFile} | awk '{print $2}' `

}

runOutputCaseCheckStatus()
{
	#date info
	date
	local TestTime=`date`
    SHA1TableData="${BitStreamSHA1String}, ${InputYUVSHA1String}, ${TestCaseInfo}"
    TestCaseStatusInfo="${TestTime}, ${EncoderCheckResult},${DecoderCheckResult}, ${FPS}, ${SHA1TableData},${EncoderCommand}"

    echo " ${SHA1TableData}">>${AssignedCasesSHATableFile}
    echo " ${TestCaseStatusInfo}">>${AssignedCasesPassStatusFile}

	if [ ${BasicCheckFlag} -eq 1 -o  ${JSVMCheckFlag} -eq 1 ]
	then
		echo "${TestCaseStatusInfo}">>${UnPassedCasesFile}
	fi
}

runBasicCheck()
{
	./run_CheckBasicCheck.sh  ${EncoderFlag}  ${SpatailLayerNum} ${RCMode}
    if [ ! $? -eq 0  ]
    then
        #currently, only copy multi thread faled cases' bit stream
        [ -e ${BitStreamFile}  ] && [ ${MultiThreadFlag} -gt 1 ] && cp ${BitStreamFile}  ${IssueDataPath}
		return 1
    fi
    return 0
}

runJSVMCheck()
{
	./run_CheckByJSVMDecoder.sh ${BitStreamFile}  ${SpatailLayerNum}
	if [ ! $? -eq 0 ]
	then
        #[ -e ${BitStreamFile}  ] && cp ${BitStreamFile}  ${IssueDataPath}
        Action="you can open the annotation to save the issue bit stream"
        return 1
	fi

    return 0
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
    runExportedCaseVariable

    runEncodeOneCase

	echo ""
	let "BasicCheckFlag=0"
	let "JSVMCheckFlag=0"
	runBasicCheck
	if [ ! $? -eq 0  ]
	then
		echo  -e "\033[31m  case failed! \033[0m"
		let "BasicCheckFlag=1"
		runParseCaseCheckLog
		runOutputCaseCheckStatus
		exit 1
	fi

	runJSVMCheck
	if [ ! $? -eq 0  ]
	then
		echo  -e "\033[31m  case failed! \033[0m"
		let "JSVMCheckFlag=1"
		runParseCaseCheckLog
		runOutputCaseCheckStatus
		exit 1
	fi

	#get FPS info from encoder log
	runParseEncoderLog
	runParseCaseCheckLog
	runOutputCaseCheckStatus
    return 0
}

TestCaseExample()
{
    TestPlatform="Mac"
    JMDecoder="JMDecoder"
    JSVMDecoder="H264AVCDecoderLibTestStatic"
    WelsDecoder="h264dec"
    IssueDataPath="issue"
    TempDataPath="TempData"

    mkdir -p ${IssueDataPath} ${TempDataPath}
    TestYUVName="horse_riding_640x512_30.yuv"
    InputYUV="./horse_riding_640x512_30.yuv"
    CheckLogFile="${TempDataPath}/CaseCheck.log"
    EncoderLog="${TempDataPath}/encoder.log"
    AssignedCasesPassStatusFile="Example_TestOneCase_AssignedCasesPassStatusFile.csv"
    UnPassedCasesFile="Example_TestOneCase_UnPassedCasesFile.csv"
    AssignedCasesSHATableFile="Example_TestOneCase_AssignedCasesSHATableFile.csv"

    EncodedFrmNum=65;
    PicW0=640;PicW1=0;PicW2=0;PicW3=0
    PicH0=512;PicH1=0;PicH2=0;PicH3=0
    YUVSizeLayer0=31948800;YUVSizeLayer1=0;YUVSizeLayer2=0;YUVSizeLayer3=0

    RecYUVFile0="${TempDataPath}/${TestYUVName}_rec_0.yuv"
    RecYUVFile1="${TempDataPath}/${TestYUVName}_rec_1.yuv"
    RecYUVFile2="${TempDataPath}/${TestYUVName}_rec_2.yuv"
    RecYUVFile3="${TempDataPath}/${TestYUVName}_rec_3.yuv"

    RecCropYUV0="${TempDataPath}/${TestYUVName}_rec_0_cropped.yuv"
    RecCropYUV1="${TempDataPath}/${TestYUVName}_rec_1_cropped.yuv"
    RecCropYUV2="${TempDataPath}/${TestYUVName}_rec_2_cropped.yuv"
    RecCropYUV3="${TempDataPath}/${TestYUVName}_rec_3_cropped.yuv"

   [ -e ${InputYUV} ] && InputYUVSHA1String=`openssl sha1  ${InputYUV} | awk '{print $2}' `

    SubCaseIndex=0
    CaseIndex=12

    #export variables have been export in run_TestAssignedCases.sh
    export SubCaseIndex; export CaseIndex;export EncodedFrmNum
    export TestPlatform
    export JMDecoder;    export JSVMDecoder;export WelsDecoder
    export IssueDataPath;export TempDataPath
    export EncoderLog;   export CheckLogFile
    export InputYUV;     export InputYUVSHA1String;export TestYUVName
    export YUVSizeLayer0;export YUVSizeLayer1;export YUVSizeLayer2;export YUVSizeLayer3
    export RecYUVFile0;  export RecYUVFile1;  export RecYUVFile2;  export RecYUVFile3
    export RecCropYUV0;  export RecCropYUV1;  export RecCropYUV2;  export RecCropYUV3

    CaseInfo="0, 65 , 1, 1, 640, 512, 640,512,0,0,0,0,0,0, 10, 10,10,10, 26, 26, 26, 26, -1, 0, 400.00,400.00,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0"
    StartTime=`date`
    for((k=0; k<10; k++))
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