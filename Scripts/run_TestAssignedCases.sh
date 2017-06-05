#!/bin/bash
#***************************************************************************************
# brief:
#       --Test all cases for one sequence 
#       --output info can be found  in ../AllTestData/${TestSequence}/result/
#                                     or for SGE test, in /opt/$hostName/SGEJObID
#            pass case number, unpass case number total case number
#            ${TestSetIndex}_${TestYUVName}_AllCaseOutput.csv
#            ${AssignedCasesConsoleLogFile}
#            ${CaseSummaryFile}
#
#usage:  ./run_TestAssignedCases.sh $TestYUV  $InputYUV $GivenCaseFile
#
#
#date:  5/08/2014 Created
#***************************************************************************************
runGlobalVariableInitial()
{
	CurrentDir=`pwd`
	
	#for SGETest, add local data directory
	if [ ${LocalDataDir} != ${CurrentDir}  ]
	then
		#SGE test data space
		ResultPath="${LocalDataDir}/result";IssueDataPath="${LocalDataDir}/issue";TempDataPath="${LocalDataDir}/TempData"
	else
		#local test data space
		ResultPath="result";IssueDataPath="issue";TempDataPath="TempData"
	fi
	
    mkdir -p ${ResultPath}  ${IssueDataPath} ${TempDataPath}

    AssignedCasesPassStatusFile="${ResultPath}/${TestYUVName}_AllCasesOutput_SubCasesIndex_${SubCaseIndex}.csv"
	UnPassedCasesFile="${ResultPath}/${TestYUVName}_UnpassedCasesOutput_SubCasesIndex_${SubCaseIndex}.csv"
	AssignedCasesSHATableFile="${ResultPath}/${TestYUVName}_AllCases_SHA1_Table_SubCasesIndex_${SubCaseIndex}.csv"
	CaseSummaryFile="${ResultPath}/${TestYUVName}_SubCasesIndex_${SubCaseIndex}.Summary.log"
    AssignedCasesConsoleLogFile="${ResultPath}/${TestYUVName}_AssignedCases_SubCaseIndex_${SubCaseIndex}_0.TestLog"

	HeadLine1="TestTime, EncoderFlag, DecoderFlag, FPS, BitSreamSHA1, InputYUVSHA1,\
			-utype,  -frms,  -numl,  -numtl, -sw, -sh,\
			-dw 0, -dh 0, -dw 1, -dh 1, -dw 2, -dh 2, -dw 3, -dh 3,\
			-frout 0,  -frout 1, -frout 2, -frout 3,\
			-lqp 0, -lqp 1, -lqp 2, -lqp 3,\
			-rc, -fs, -tarb, -ltarb 0, -ltarb 1, -ltarb 2, -ltarb 3,\
            -lmaxb 0,   -lmaxb 1,  -lmaxb 2,  -lmaxb 3,\
			-slcmd 0, -slcnum 0, -slcmd 1, -slcnum 1,\
			-slcmd 2, -slcnum 2, -slcmd 3, -slcnum 3,\
			-nalsize,\
			-iper, -thread,  -loadbalancing, -ltr, -db, -denois,\
			-scene,  -bgd ,  -aq, Command"

	HeadLine2="BitSreamSHA1, InputYUVSHA1,\
			-utype,  -frms,  -numl,  -numtl, -sw, -sh,\
			-dw 0, -dh 0, -dw 1, -dh 1,-dw 2, -dh 2, -dw 3, -dh 3,\
			-frout 0,  -frout 1, -frout 2, -frout 3,\
			-lqp 0, -lqp 1, -lqp 2, -lqp 3,\
			-rc, -fs, -tarb, -ltarb 0, -ltarb 1, -ltarb 2, -ltarb 3,\
            -lmaxb 0,   -lmaxb 1,  -lmaxb 2,  -lmaxb 3,\
			-slcmd 0, -slcnum 0, -slcmd 1, -slcnum 1,\
			-slcmd 2, -slcnum 2, -slcmd 3, -slcnum 3,\
			-nalsize,\
			-iper, -thread, -loadbalancing, -ltr, -db, -denois,\
			-scene  , bgd  , -aq "

	echo  ${HeadLine1}>${AssignedCasesPassStatusFile}
	echo  ${HeadLine1}>${UnPassedCasesFile}
	echo  ${HeadLine2}>${AssignedCasesSHATableFile}

	let "YUVSizeLayer0=0";let "YUVSizeLayer1=0";let "YUVSizeLayer2=0";let "YUVSizeLayer3=0"
	let "Multiple16Flag=1";let "MultiLayerFlag=0"
	let "EncoderPassedNum=0";let "EncoderUnPassedNum=0"
	let "DecoderPassedNum=0";let "DecoderUpPassedNum=0";let "DecoderUnCheckNum=0"
    let "EncodedFrmNum = 0"

    TestPlatform="Linux"
    InputYUVSHA1String="NULL"
    CheckLogFile="${TempDataPath}/CaseCheck.log";EncoderLog="${TempDataPath}/encoder.log"
    RecYUVFile0="${TempDataPath}/${TestYUVName}_rec_0.yuv";RecYUVFile1="${TempDataPath}/${TestYUVName}_rec_1.yuv"
    RecYUVFile2="${TempDataPath}/${TestYUVName}_rec_2.yuv";RecYUVFile3="${TempDataPath}/${TestYUVName}_rec_3.yuv"
    RecCropYUV0="${TempDataPath}/${TestYUVName}_rec_0_cropped.yuv";RecCropYUV1="${TempDataPath}/${TestYUVName}_rec_1_cropped.yuv"
    RecCropYUV2="${TempDataPath}/${TestYUVName}_rec_2_cropped.yuv";RecCropYUV3="${TempDataPath}/${TestYUVName}_rec_3_cropped.yuv"
    JMDecoder="JMDecoder";JSVMDecoder="JSVMDecoder";WelsDecoder="h264dec"
}

runParseConfigure()
{
    Multiple16Flag=(`cat ${ConfigureFile} | grep "Multiple16Flag"    | awk 'BEGIN {FS="[#:]"} {print $2}' `)
    MultiLayerFlag=(`cat ${ConfigureFile} | grep "MultiLayer"        | awk 'BEGIN {FS="[#:]"} {print $2}' `)
    Platform=(`cat ${ConfigureFile}       | grep "TestPlatform"      | awk 'BEGIN {FS="[#:]"} {print $2}' `)
    FrameNum=`cat ${ConfigureFile}        | grep "FramesToBeEncoded" | awk 'BEGIN {FS="[#:]"} {print $2}' `

    TestPlatform=${Platform}
    EncodedFrmNum=${FrameNum}
}

runParseInputYUVPrepareLog()
{
    local PrepareLog=$1

    SizeLayer0=(`cat ${PrepareLog} | grep "LayerSize_0"    | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    SizeLayer1=(`cat ${PrepareLog} | grep "LayerSize_1"    | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    SizeLayer2=(`cat ${PrepareLog} | grep "LayerSize_2"    | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    SizeLayer3=(`cat ${PrepareLog} | grep "LayerSize_3"    | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    LayerNum=(`cat ${PrepareLog}   | grep "NumberLayer"    | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    FrameNum=(`cat ${PrepareLog}   | grep "EncodedFrmNum"  | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    InputYUVName=(`cat ${PrepareLog}  | grep "InputYUV"    | awk 'BEGIN {FS="[:\r]"} {print $2}' `)

    aLayerSizeList=(${SizeLayer0} ${SizeLayer1} ${SizeLayer2} ${SizeLayer3})
    TopLayerSize=${aLayerSizeList[${LayerNum}-1]}
    YUVSizeLayer0=${SizeLayer0};  YUVSizeLayer1=${SizeLayer1};  YUVSizeLayer2=${SizeLayer2};  YUVSizeLayer3=${SizeLayer3}
    EncodedFrmNum=${FrameNum}
}

runParseCaseCheckLog()
{
    local Flag="0"
    Flag=(`cat ${CheckLogFile}    | grep "EncoderPassedNum"   | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    let "EncoderPassedNum +=${Flag}"

    Flag=(`cat ${CheckLogFile}    | grep "EncoderUnPassedNum" | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    let "EncoderUnPassedNum +=${Flag}"

    Flag=(`cat ${CheckLogFile}    | grep "DecoderPassedNum"   | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    let "DecoderPassedNum +=${Flag}"

    Flag=(`cat ${CheckLogFile}    | grep "DecoderUpPassedNum" | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    let "DecoderUpPassedNum +=${Flag}"

    Flag=(`cat ${CheckLogFile}    | grep "DecoderUnCheckNum"  | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    let "DecoderUnCheckNum +=${Flag}"
}

runToolCheck()
{
    if [ "${TestPlatform}" = "Mac" ]
    then
        [ ! -e ${JMDecoder} ]   && echo "JMDecoder   ${JMDecoder} does not exist!"     && exit 1
    else
        [ ! -e ${JSVMDecoder} ] && echo "JSVMDecoder ${JSVMDecoder} does not exist!"   && exit 1
    fi

    [ ! -e ${WelsDecoder} ]   && echo "WelsDecoder   ${WelsDecoder} does not exist!"   && exit 1
}

runPrepareInputYUV()
{
	local PrepareLog="${LocalDataDir}/${TestYUVName}_InputYUVPrepare_SubCaseIndex_${SubCaseIndex}.log"

    #prepare input YUV, change resolution to be multiple of 16 and rename file name if Multiple16Flag=1
    #copy YUV file to LocalDataDir
    ./run_PrepareInputYUV.sh  ${LocalDataDir}  ${InputYUV}  ${PrepareLog} ${Multiple16Flag} ${EncodedFrmNum}
	if [ ! $? -eq 0 ]
	then
		echo -e "\033[31m \n multilayer input YUV preparation failed! \n\033[0m"
		exit 1
	fi

	#parse multilayer YUV's name and size info
    runParseInputYUVPrepareLog ${PrepareLog}
    echo "rename YUV name due to Multiple16Flag=1, actual value is Multiple16Flag=${Multiple16Flag}"
    echo "InputYUVName update: ${TestYUVName} to ${InputYUVName}"
    echo "copy InputYUV to:    ${LocalDataDir}/${InputYUVName}"
	echo "YUVSizeLayer0:  ${YUVSizeLayer0}"
	echo "YUVSizeLayer1:  ${YUVSizeLayer1}"
	echo "YUVSizeLayer2:  ${YUVSizeLayer2}"
	echo "YUVSizeLayer3:  ${YUVSizeLayer3}"

    #update YUV name and input YUV dir info
    TestYUVName=${InputYUVName}
    InputYUV=${LocalDataDir}/${InputYUVName}
    InputYUVSHA1String=`openssl sha1  ${InputYUV} | awk '{print $2}' `
}

runExportVariable()
{
    #to do: need to validate expart variables
    export TestPlatform
    export SubCaseIndex; export EncodedFrmNum
    export JMDecoder;    export JSVMDecoder;  export WelsDecoder
    export IssueDataPath;export TempDataPath
    export EncoderLog;   export CheckLogFile
    export InputYUV;     export TestYUVName;  export InputYUVSHA1String
    export YUVSizeLayer0;export YUVSizeLayer1
    export YUVSizeLayer2;export YUVSizeLayer3
    export TopLayerSize

    export RecYUVFile0;  export RecYUVFile1;  export RecYUVFile2;  export RecYUVFile3
    export RecCropYUV0;  export RecCropYUV1;  export RecCropYUV2;  export RecCropYUV3
    export AssignedCasesPassStatusFile;       export UnPassedCasesFile;export AssignedCasesSHATableFile
}

runTestAndCheckOneCase()
{
    echo -e "\n\n\n****************case index is ${TotalCaseNum}************"
    ./run_TestOneCase.sh  ${CaseData}
    echo -e "\n---------------parse and Cat Check Log file--------------------"
    [ -e ${CheckLogFile} ] && cat ${CheckLogFile} && runParseCaseCheckLog
}

# run all test case based on XXXcase.csv file
#usage  runAllCaseTest
runAllCaseTest()
{
    let "TotalCaseNum=0";let "LineIndex=0";let "LogFileIndex=0"

    echo  -e "\033[32m *****************************************************************************************************  \033[0m"
    echo  -e "\033[32m        testing all cases, please wait!......    \033[0m"
    echo  -e "\033[32m *****************************************************************************************************\n\033[0m"
	while read CaseData
	do
		if [ ${LineIndex} -gt 0  ]
		then
			#to limit log file's size,each log file only records 200 cases' log
			let "NewLogFileFlag = ${TotalCaseNum}%200"
			if [ ${NewLogFileFlag} -eq 0 ]
			then
				AssignedCasesConsoleLogFile="${ResultPath}/${TestYUVName}_AssignedCases_SubCaseIndex_${SubCaseIndex}_${LogFileIndex}.TestLog"
				let "LogFileIndex++"
                echo " LocalDataDir is: ${LocalDataDir}" >${AssignedCasesConsoleLogFile}

                ./run_SafeDelete.sh ${TempDataPath} >>DeletedFile.list
                mkdir -p ${TempDataPath}
			fi

            let "CaseIndex=$TotalCaseNum"
            export CaseIndex;
#runTestAndCheckOneCase  >>${AssignedCasesConsoleLogFile} 2>&1
			echo "TempDataPath is : ${TempDataPath}"
			echo "LogFileIndex is : ${LogFileIndex}"
			echo "LineIndex is ${LineIndex}"
			echo "ResultPath is ${ResultPath}"
            runTestAndCheckOneCase

			let "TotalCaseNum++"
		fi

		let "LineIndex++"
		
	done <$GivenCaseFile

    echo  -e "\033[32m *****************************************************************************************************   \033[0m"
    echo  -e "\033[32m        All assigned cases have been checked, will generate test report/summary soon!    \033[0m"
    echo  -e "\033[32m ***************************************************************************************************** \n\033[0m"

    ./run_SafeDelete.sh ${TempDataPath} >>DeletedFile.list
}

runOutputPassNum()
{
	# output file locate in ../result
	TestFolder=`echo $CurrentDir | awk 'BEGIN {FS="/"} { i=NF; print $i}'`
    echo  -e "\033[34m ***************************************************************************************************** \033[0m"
    echo  -e "\033[34m               Test summary for ${TestYUVName}      \033[0m"
	echo  -e "\033[34m ***************************************************************************************************** \033[0m"
    echo  -e "\033[33m    TestStartTime    is: ${StartTime}               \033[0m"
    echo  -e "\033[33m    TestEndTime      is: ${EndTime}                 \033[0m"
    echo  -e "\033[34m ***************************************************************************************************** \033[0m"
	echo  -e "\033[32m    total case  Num     is : ${TotalCaseNum}        \033[0m"
	echo  -e "\033[32m    EncoderPassedNum    is : ${EncoderPassedNum}    \033[0m"
	echo  -e "\033[31m    EncoderUnPassedNum  is : ${EncoderUnPassedNum}  \033[0m"
	echo  -e "\033[32m    DecoderPassedNum    is : ${DecoderPassedNum}    \033[0m"
	echo  -e "\033[31m    DecoderUpPassedNum  is : ${DecoderUpPassedNum}  \033[0m"
	echo  -e "\033[31m    DecoderUnCheckNum   is : ${DecoderUnCheckNum}   \033[0m"
	echo  -e "\033[34m ***************************************************************************************************** \033[0m"
	echo  -e "\033[32m     --issue bitstream can be found in ${LocalDataDir}/issue         \033[0m"
	echo  -e "\033[32m     --detail result can be found in   ${LocalDataDir}/${ResultPath} \033[0m"
	echo  -e "\033[34m ***************************************************************************************************** \033[0m"
	echo ""
}

#***********************************************************
runMain()
{
    runGlobalVariableInitial
    runParseConfigure
    runToolCheck

    runPrepareInputYUV
    runExportVariable

    StartTime=`date`
    runAllCaseTest
    EndTime=`date`

    runOutputPassNum >${CaseSummaryFile}
    #cat ${CaseSummaryFile}
    #echo "StartTime is $StartTime"
    #echo "EndTime   is $EndTime"

    if [  ! ${EncoderUnPassedNum} -eq 0  ]
    then
        FlagFile="${ResultPath}/${TestYUVName}.unpassFlag"
        touch ${FlagFile}
        return 1
    else
        FlagFile="${ResultPath}/${TestYUVName}.passFlag"
        touch ${FlagFile}
        return 0
    fi
}

runExampleInput()
{
    LocalDataDir=`pwd`
    ConfigureFile="../CaseConfigure/case_for_Mac_fast_test.cfg"
    TestYUVName="horse_riding_640x512_30.yuv"
    InputYUV="../../YUV/horse_riding_640x512_30.yuv"
    SubCaseIndex=0
    GivenCaseFile="./case.csv"
}
runExampleTest()
{
    runExampleInput
    runMain
}
#****************************************************************************************************************
# example test
#runExampleTest
#****************************************************************************************************************
#main entry
echo -e "\n*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo -e "*********************************************************\n"

if [ ! $# -eq 6  ]
then
    echo "usage: run_TestAssignedCases.sh \${LocalDataDir}  \${ConfigureFile}  \${TestYUVName}   "
    echo "                                \${InputYUV}       \${SubCaseIndex}  \${GivenCaseFile} "
    return 1
fi

LocalDataDir=$1
ConfigureFile=$2
TestYUVName=$3
InputYUV=$4
SubCaseIndex=$5
GivenCaseFile=$6

runMain
#****************************************************************************************************************


#****************************************************************************************************************
