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
		#test data space
		ResultPath="${LocalDataDir}/result"
		IssueDataPath="${LocalDataDir}/issue"
		TempDataPath="${LocalDataDir}/TempData"
	else
		#test data space
		ResultPath="result"
		IssueDataPath="issue"
		TempDataPath="TempData"	
	fi
	
	mkdir -p ${ResultPath}
	mkdir -p ${IssueDataPath}
	mkdir -p ${TempDataPath}
	#test cfg file and test info output file
	AssignedCasesPassStatusFile="${ResultPath}/${TestYUVName}_AllCasesOutput_SubCasesIndex_${SubCaseIndex}.csv"
	UnPassedCasesFile="${ResultPath}/${TestYUVName}_UnpassedCasesOutput_SubCasesIndex_${SubCaseIndex}.csv"
	AssignedCasesSHATableFile="${ResultPath}/${TestYUVName}_AllCases_SHA1_Table_SubCasesIndex_${SubCaseIndex}.csv"
	AssignedCasesConsoleLogFile="${ResultPath}/${TestYUVName}__SubCasesIndex_${SubCaseIndex}.TestLog"
	CaseSummaryFile="${ResultPath}/${TestYUVName}_SubCasesIndex_${SubCaseIndex}.Summary"
	HeadLine1="EncoderFlag, DecoderFlag, FPS, BitSreamSHA1, BitSreamMD5, InputYUVSHA1, InputYUVMD5,\
			-utype,  -frms,  -numl,  -numtl, -sw, -sh,\
			-dw 0, -dh 0, -dw 1, -dh 1, -dw 2, -dh 2, -dw 3, -dh 3,\
			-frout 0,  -frout 1, -frout 2, -frout 3,\
			-lqp 0, -lqp 1, -lqp 2, -lqp 3,\
			-rc,-fs, -tarb, -ltarb 0, -ltarb 1, -ltarb 2, -ltarb 3,\
			-slcmd 0, -slcnum 0, -slcmd 1, -slcnum 1,\
			-slcmd 2, -slcnum 2, -slcmd 3, -slcnum 3,\
			-nalsize,\
			-iper, -thread, -ltr, -db, -denois,\
			-scene,  -bgd ,  -aq, "

	HeadLine2="BitSreamSHA1, BitSreamMD5, InputYUVSHA1, InputYUVMD5,\
			-utype,  -frms,  -numl,  -numtl, -sw, -sh,\
			-dw 0, -dh 0, -dw 1, -dh 1,-dw 2, -dh 2, -dw 3, -dh 3,\
			-frout 0,  -frout 1, -frout 2, -frout 3,\
			-lqp 0, -lqp 1, -lqp 2, -lqp 3,\
			-rc, -fs, -tarb, -ltarb 0, -ltarb 1, -ltarb 2, -ltarb 3,\
			-slcmd 0, -slcnum 0, -slcmd 1, -slcnum 1,\
			-slcmd 2, -slcnum 2, -slcmd 3, -slcnum 3,\
			-nalsize,\
			-iper, -thread, -ltr, -db, -denois,\
			-scene  , bgd  , -aq "

	echo  ${HeadLine1}>${AssignedCasesPassStatusFile}
	echo  ${HeadLine1}>${UnPassedCasesFile}

	echo  ${HeadLine2}>${AssignedCasesSHATableFile}
	let "YUVSizeLayer0=0"
	let "YUVSizeLayer1=0"
	let "YUVSizeLayer2=0"
	let "YUVSizeLayer3=0"

	let "Multiple16Flag=1"
	let "MultiLayerFlag=0"

	#encoder parameters  change based on the case info
	let "EncoderPassedNum=0"
	let "EncoderUnPassedNum=0"
	let "DecoderPassedNum=0"
	let "DecoderUpPassedNum=0"
	let "DecoderUnCheckNum=0"
    let "EncodedFrmNum = 0"
}

runParseConfigure()
{
   Multiple16Flag=(`cat ${ConfigureFile} | grep "Multiple16Flag"    | awk 'BEGIN {FS="[#:]"} {print $2}' `)
   MultiLayerFlag=(`cat ${ConfigureFile} | grep "MultiLayer"        | awk 'BEGIN {FS="[#:]"} {print $2}' `)
   EncodedFrmNum=(`cat ${ConfigureFile}  | grep "FramesToBeEncoded" | awk 'BEGIN {FS="[#:]"} {print $2}' `)

}

runParseInputYUVPrepareLog()
{
    local PrepareLog=$1

    YUVSizeLayer0=(`cat ${PrepareLog} | grep "LayerSize_0"  | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    YUVSizeLayer1=(`cat ${PrepareLog} | grep "LayerSize_1"  | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    YUVSizeLayer2=(`cat ${PrepareLog} | grep "LayerSize_2"  | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    YUVSizeLayer3=(`cat ${PrepareLog} | grep "LayerSize_3"  | awk 'BEGIN {FS="[:\r]"} {print $2}' `)

    InputYUVName=(`cat ${PrepareLog}  | grep "InputYUV"     | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    NumberLayer=(`cat ${PrepareLog}   | grep "NumberLayer"  | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
}

runParseCaseCheckLog()
{
    local CheckLog=$1
    local Flag="0"

    YUVSizeLayer0=(`cat ${CheckLog}    | grep "EncoderPassedNum"   | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    let "EncoderPassedNum +=${Flag}"

    YUVSizeLayer1=(`cat ${CheckLog}    | grep "EncoderUnPassedNum" | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    let "EncoderUnPassedNum +=${Flag}"

    YUVSizeLayer2=(`cat ${CheckLog}    | grep "DecoderPassedNum"   | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    let "DecoderPassedNum +=${Flag}"

    YUVSizeLayer3=(`cat ${CheckLog}    | grep "DecoderUpPassedNum" | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    let "DecoderUpPassedNum +=${Flag}"

    YUVSizeLayer3=(`cat ${CheckLog}    | grep "DecoderUnCheckNum"  | awk 'BEGIN {FS="[:\r]"} {print $2}' `)
    let "DecoderUnCheckNum +=${Flag}"

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
}

# run all test case based on XXXcase.csv file
#usage  runAllCaseTest
runAllCaseTest()
{
    local CheckLogFile="${TempDataPath}/CaseCheck.log"
    let "TotalCaseNum=0"
	let "LineIndex=0"
	let "LogFileIndex=0"
	while read CaseData
	do
		if [ ${LineIndex} -gt 0  ]
		then
			#to limit log file's size,each log file only records 200 cases' log
			let "NewLogFileFlag = ${TotalCaseNum}%200"
			if [ ${NewLogFileFlag} -eq 0 ]
			then
				AssignedCasesConsoleLogFile="${ResultPath}/${TestYUVName}_SubCaseIndex_${SubCaseIndex}_${LogFileIndex}.TestLog"
				let "LogFileIndex++"
				echo "">${AssignedCasesConsoleLogFile}
                ./run_SafeDelete.sh ${TempDataPath} >>DeletedFile.list
                mkdir ${TempDataPath}
			fi
			
			echo -e "\n\n \n" >>${AssignedCasesConsoleLogFile}
			echo "****************case index is ${TotalCaseNum}************">>${AssignedCasesConsoleLogFile}
            echo "     LocalDataDir is: ${LocalDataDir}">>${AssignedCasesConsoleLogFile}
			export IssueDataPath
			export TempDataPath
			export TestYUVName
			export InputYUV
			export AssignedCasesPassStatusFile
			export UnPassedCasesFile
			export AssignedCasesSHATableFile
			#export CheckLogFile
			export YUVSizeLayer0
			export YUVSizeLayer1
			export YUVSizeLayer2
			export YUVSizeLayer3

			./run_TestOneCase.sh  ${CaseData}      >>${AssignedCasesConsoleLogFile}

			echo -e "\n---------------parse and Cat Check Log file--------------------">>${AssignedCasesConsoleLogFile}
            if [ -e ${CheckLogFile} ]
            then
                cat ${CheckLogFile}                    >>${AssignedCasesConsoleLogFile}
                runParseCaseCheckLog  ${CheckLogFile}  >>${AssignedCasesConsoleLogFile}
            else
                echo -e "\n CheckLogFile ${CheckLogFile} does not exist,please double check"
            fi

			let "TotalCaseNum++"
		fi

		let "LineIndex++"
		
	done <$GivenCaseFile

    ./run_SafeDelete.sh ${TempDataPath} >>DeletedFile.list
}
#usage runOutputPassNum
runOutputPassNum()
{
	# output file locate in ../result
	TestFolder=`echo $CurrentDir | awk 'BEGIN {FS="/"} { i=NF; print $i}'`
	echo ""
	echo  -e "\033[32m *********************************************************** \033[0m"
	echo  -e "\033[32m total case  Num     is : ${TotalCaseNum}       \033[0m"
	echo  -e "\033[32m EncoderPassedNum    is : ${EncoderPassedNum}   \033[0m"
	echo  -e "\033[31m EncoderUnPassedNum  is : ${EncoderUnPassedNum} \033[0m"
	echo  -e "\033[32m DecoderPassedNum    is : ${DecoderPassedNum}   \033[0m"
	echo  -e "\033[31m DecoderUpPassedNum  is : ${DecoderUpPassedNum} \033[0m"
	echo  -e "\033[31m DecoderUnCheckNum   is : ${DecoderUnCheckNum}  \033[0m"
	echo "issue bitstream can be found in ./AllTestData/${TestFolder}/issue"
	echo "detail result  can be found in  ./AllTestData/${TestFolder}/${ResultPath}"
	echo  -e "\033[32m *********************************************************** \033[0m"
	echo ""
	echo "  --issue bitstream can be found in  ${LocalDataDir}/issue" 
	echo "  --detail result  can be found in   ${LocalDataDir}/${ResultPath}" 
	echo  -e "\033[32m *********************************************************** \033[0m"
	echo ""
	echo  -e "\033[32m ..................Test summary for ${TestYUVName}....................\033[0m">${CaseSummaryFile}
    echo  "     TestStartTime is ${StartTime}  ">>${CaseSummaryFile}
    echo  "     TestEndTime   is ${EndTime}    ">>${CaseSummaryFile}
	echo  -e "\033[32m total case  Num     is : ${TotalCaseNum}        \033[0m">>${CaseSummaryFile}
	echo  -e "\033[32m EncoderPassedNum    is : ${EncoderPassedNum}    \033[0m">>${CaseSummaryFile}
	echo  -e "\033[31m EncoderUnPassedNum  is : ${EncoderUnPassedNum}  \033[0m">>${CaseSummaryFile}
	echo  -e "\033[32m DecoderPassedNum    is : ${DecoderPassedNum}    \033[0m">>${CaseSummaryFile}
	echo  -e "\033[31m DecoderUpPassedNum  is : ${DecoderUpPassedNum}  \033[0m">>${CaseSummaryFile}
	echo  -e "\033[31m DecoderUnCheckNum   is : ${DecoderUnCheckNum}   \033[0m">>${CaseSummaryFile}
	echo "" >>${CaseSummaryFile}
	echo "  --issue bitstream can be found in  ${LocalDataDir}/issue" >>${CaseSummaryFile}
	echo "  --detail result  can be found in   ${LocalDataDir}/${ResultPath}" >>${CaseSummaryFile}
	echo  -e "\033[32m *********************************************************** \033[0m"

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
#***********************************************************
# usage: runMain ${ConfigureFile}  $TestYUV  $InputYUV $GivenCaseFile
runMain()
{
    StartTime=""
    EndTime=""

	runGlobalVariableInitial
	runParseConfigure

	runPrepareInputYUV

	echo ""
	echo  -e "\033[32m  testing all cases, please wait!...... \033[0m"
    #get time info
    date
    StartTime=`date`

	runAllCaseTest
    #get time info
    date
    EndTime=`date`

	runOutputPassNum
	return $?
}

Temp(){

#****************************************************************************************************************
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

}
LocalDataDir=$1
ConfigureFile=$2
TestYUVName=$3
InputYUV=$4
runParseConfigure
runPrepareInputYUV