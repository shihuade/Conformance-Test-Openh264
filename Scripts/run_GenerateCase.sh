#!/bin/bash
#***************************************************************************************
# brief:
#      generate  case based on case configure file and given test sequence
#
#      usage: ./run_GenerateCase.sh  $Case.cfg   $TestSequence      $OutputCaseFile
#      e.g.:  ./run_GenerateCase.sh  case.cfg    ABC_1920X1080.yuv  AllCase.csv
#
#date:  5/08/2014 Created
#***************************************************************************************

#usage:  runParseYUVInfo  ${YUVName}
runParseYUVInfo()
{
    TestYUVName=${TestSequence}
    declare -a aYUVInfo
	aYUVInfo=(`./run_ParseYUVInfo.sh  ${TestYUVName}`)
	PicW=${aYUVInfo[0]}
	PicH=${aYUVInfo[1]}
	FPS=${aYUVInfo[2]}
	if [  ${PicW} -eq 0 -o ${PicH} -eq 0  ]
	then
		echo "YUVName is not correct,should be named as ABC_PicWXPicH_FPS.yuv"
		exit 1
	fi
	if [  ${FPS} -eq 0  ]
	then
		let "FPS=10"
	elif [  ${FPS} -gt 60  ]
		then
		let "FPS=60"
	fi
	return 0
}
#usage:   runCaseVilidationcheck  \$CaseInfo
runCaseVilidationcheck()
{
	if [ ! $# -lt 2 ]
	then
		echo "usage:   runCaseVilidationcheck  \$CaseInfo "
		return 1
	fi
	echo "to do"
}
#usage  runGlobalVariableInital  $TestSequence  $OutputCaseFile
runGlobalVariableInital()
{
	if [ ! $# -eq 2 ]
	then
        echo "usage:   runGlobalVariableInital  \$TestSequence  \$OutputCaseFile "
        return 1
	fi
	local  TestSequence=$1
	local  OutputCaseFile=$2
	let   " FramesToBeEncoded = 0"
	let   " MaxNalSize = 0"
	let   " Multiple16Flag=0"
	declare -a  aNumSpatialLayer
	declare -a  aNumTempLayer
	declare -a  aUsageType
	declare -a  aRCMode
	declare -a  aIntraPeriod
	declare -a  aTargetBitrateSet
	declare -a  aInitialQP
	declare -a  aSliceMode
	declare -a  aSliceNum0
	declare -a  aSliceNum1
	declare -a  aSliceNum2
	declare -a  aSliceNum3
	declare -a  aSliceNum4
	declare -a  aMultipleThreadIdc
	declare -a  aEnableLongTermReference
	declare -a  aLoopFilterDisableIDC
	declare -a  aEnableDenoise
	declare -a  aEnableSceneChangeDetection
	declare -a  aEnableBackgroundDetection
	declare -a  aEnableAdaptiveQuantization
	MultiLayerResolutionInfo="0,0,   0,0,   0,0,  0,0"
	declare -a aSpatialLayerResolutionSet1
	declare -a aSpatialLayerResolutionSet2
	declare -a aSpatialLayerResolutionSet3
	declare -a aSpatialLayerResolutionSet4
	declare -a aSpatialLayerBRSet1
	declare -a aSpatialLayerBRSet2
	declare -a aSpatialLayerBRSet3
	declare -a aSpatialLayerBRSet4
	let "PicW=0"
	let "PicH=0"
	let "FPS=0"
	let "MultiLayerFlag=0"
	#generate test cases and output to case file
	casefile=${OutputCaseFile}
	casefile_01=${OutputCaseFile}_01.csv
	casefile_02=${OutputCaseFile}_02.csv
}
runMultiLayerInitial()
{
	runParseYUVInfo  ${TestSequence}
	MultiLayerNum=`./run_GetSpatialLayerNum.sh  ${PicW}  ${PicH}`
	if [  ${MultiLayerFlag} -eq 0  ]
	then
		aNumSpatialLayer=( 1 )
	elif  [  ${MultiLayerFlag} -eq 1  ]
	then
		aNumSpatialLayer=( ${MultiLayerNum} )
	elif  [  ${MultiLayerFlag} -eq 2  ]
	then
		if [  ${MultiLayerNum} -gt 1 ]
		then
			aNumSpatialLayer=( 1 ${MultiLayerNum} )
		else
			aNumSpatialLayer=( 1 )
		fi
	fi
	
	#set spatial layer resolution
	#may look like 360 640   720 1280   0 0   0 0
	aSpatialLayerResolutionSet1=(`./run_GetSpatialLayerResolutionInfo.sh ${PicW} ${PicH} 1 ${Multiple16Flag}`)
	aSpatialLayerResolutionSet2=(`./run_GetSpatialLayerResolutionInfo.sh ${PicW} ${PicH} 2 ${Multiple16Flag}`)
	aSpatialLayerResolutionSet3=(`./run_GetSpatialLayerResolutionInfo.sh ${PicW} ${PicH} 3 ${Multiple16Flag}`)
	aSpatialLayerResolutionSet4=(`./run_GetSpatialLayerResolutionInfo.sh ${PicW} ${PicH} 4 ${Multiple16Flag}`)
	#may look like: 200 400 800 0 , 50 300 600 0 ,
	aSpatialLayerBRSet1=(`./run_GetSpatialLayerBitRateSet.sh  $PicW  $PicH $FPS  1 $ConfigureFile ${Multiple16Flag}`)
	aSpatialLayerBRSet2=(`./run_GetSpatialLayerBitRateSet.sh  $PicW  $PicH $FPS  2 $ConfigureFile ${Multiple16Flag}`)
	aSpatialLayerBRSet3=(`./run_GetSpatialLayerBitRateSet.sh  $PicW  $PicH $FPS  3 $ConfigureFile ${Multiple16Flag}`)
	aSpatialLayerBRSet4=(`./run_GetSpatialLayerBitRateSet.sh  $PicW  $PicH $FPS  4 $ConfigureFile ${Multiple16Flag}`)
}

#usage:  runGenerateMultiLayerBRSet ${SpatialNum}
#e.g:    --input:  runGenerateMultiLayerBRSet 2
#        --output: "1000,200,800,0, 0,"  "1500,500,1000,0,0"
#                   "OverAllBR, BRLayer0,BRLayer1,BRLayer2,BRLayer3,"
runGenerateMultiLayerBRSet()
{
	if [ ! $# -eq 1 ]
	then
	echo "usage:  runGenerateMultiLayerBRSet \${SpatialNum}"
	exit 1
	fi
	local SpatialNum=$1
	local TempLayerBRInfo=""
	local TempIndex=""
	local TempTotalNum=""
	local OverallBR="0"
	declare -a aTempLayerBRInfo
	if [ ${SpatialNum} -eq 1 ]
	then
		TempLayerBRInfo="${aSpatialLayerBRSet1[@]}"
	elif  [ ${SpatialNum} -eq 2 ]
	then
		TempLayerBRInfo="${aSpatialLayerBRSet2[@]}"
	elif  [ ${SpatialNum} -eq 3 ]
	then
		TempLayerBRInfo="${aSpatialLayerBRSet3[@]}"
	elif  [ ${SpatialNum} -eq 4 ]
	then
		TempLayerBRInfo="${aSpatialLayerBRSet4[@]}"
	fi
	aTempLayerBRInfo=(`echo ${TempLayerBRInfo}  | awk ' BEGIN  {FS=","}  {for(i=1;i<=NF;i++) printf(" %s",$i) }'`)
	let "TempTotalNum = ${#aTempLayerBRInfo[@]}"
	let  "TempIndex=0"
	for ((i=0;i<${TempTotalNum}; i+=4))
	do
	#bc tool to calculate overall target bit rate
		OverallBR=`echo "scale=2; ${aTempLayerBRInfo[$i+0]}+${aTempLayerBRInfo[$i+1]}+${aTempLayerBRInfo[$i+2]}+${aTempLayerBRInfo[$i+3]}" | bc`
		aTargetBitrateSet[${TempIndex}]="${OverallBR},${aTempLayerBRInfo[$i+0]},${aTempLayerBRInfo[$i+1]},${aTempLayerBRInfo[$i+2]},${aTempLayerBRInfo[$i+3]},"
		let  "TempIndex ++"
	done
}
#usage: runGenerateLayerResolution ${SpatialNum}
runGenerateLayerResolution()
{
	if [ ! $# -eq 1 ]
	then
		echo "usage: runGenerateLayerResolution  \${SpatialNum}"
		exit 1
	fi
	local SpatialNum=$1
	local TempLayerResolution=""
	if [ ${SpatialNum} -eq 1 ]
	then
		TempLayerResolution="${aSpatialLayerResolutionSet1[@]}"
	elif  [ ${SpatialNum} -eq 2 ]
	then
		TempLayerResolution="${aSpatialLayerResolutionSet2[@]}"
	elif  [ ${SpatialNum} -eq 3 ]
	then
		TempLayerResolution="${aSpatialLayerResolutionSet3[@]}"
	elif  [ ${SpatialNum} -eq 4 ]
	then
		TempLayerResolution="${aSpatialLayerResolutionSet4[@]}"
	fi
	MultiLayerResolutionInfo=`echo ${TempLayerResolution} |awk '{for(i=1;i<=NF;i++) printf("%s,",$i)}' `
}
#usage:  runParseCaseConfigure $ConfigureFile
runParseCaseConfigure()
{
	#parameter check!
	if [ ! $# -eq 1  ]
	then
		echo "usage:  runParseCaseConfigure \$ConfigureFile"
		return 1
	fi
	local ConfigureFile=$1
	#read configure file
	while read line
	do
		if [[ "$line" =~ ^FramesToBeEnc  ]]
		then
			FramesToBeEncoded=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif [[ "$line" =~ ^UsageType ]]
		then
			aUsageType=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^MultiLayer ]]
		then
			MultiLayerFlag=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^TemporalLayerNum ]]
		then
			aNumTempLayer=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^MultipleThreadIdc ]]
		then
			aMultipleThreadIdc=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^SliceMode ]]
		then
			aSliceMode=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^MaxNalSize ]]
		then
			MaxNalSize=`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `
		elif [[ "$line" =~ ^SliceNum0 ]]
		then
			aSliceNum0=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^SliceNum1 ]]
		then
			aSliceNum1=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^SliceNum2 ]]
		then
			aSliceNum2=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^SliceNum3 ]]
		then
			aSliceNum3=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^SliceNum4 ]]
		then
			aSliceNum4=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^IntraPeriod ]]
		then
			aIntraPeriod=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^RCMode ]]
		then
			aRCMode=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^EnableLongTermReference ]]
		then
			aEnableLongTermReference=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^LoopFilterDisableIDC ]]
		then
			aLoopFilterDisableIDC=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^InitialQP ]]
		then
			aInitialQP=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^EnableDenoise ]]
		then
			aEnableDenoise=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^EnableSceneChangeDetection ]]
		then
			aEnableSceneChangeDetection=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^EnableBackgroundDetection ]]
		then
			aEnableBackgroundDetection=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^EnableAdaptiveQuantization ]]
		then
			aEnableAdaptiveQuantization=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		elif [[ "$line" =~ ^Multiple16Flag ]]
		then
			Multiple16Flag=(`echo $line | awk 'BEGIN {FS="[#:\r]"} {print $2}' `)
		fi
	done <$ConfigureFile
}
#usage: runGetSliceNum  $SliceMd
runGetSliceNum()
{
	if [ ! $# -eq 1  ]
	then
		echo "usage: runGetSliceNum  \$SliceMd"
		return 1
	fi
	local SlicMdIndex=$1
	if [ ${SlicMdIndex} -eq 0 ]
	then
		echo ${aSliceNum0[@]}
	elif [  ${SlicMdIndex} -eq 1 ]
	then
		echo ${aSliceNum1[@]}
	elif [  ${SlicMdIndex} -eq 2 ]
	then
		echo ${aSliceNum2[@]}
	elif [  ${SlicMdIndex} -eq 3 ]
	then
		echo ${aSliceNum3[@]}
	elif [  ${SlicMdIndex} -eq 4 ]
	then
		echo ${aSliceNum4[@]}
	fi
}
#the first stage for case generation
runFirstStageCase()
{
    declare -a aQPforTest
	for ScreenSignal in ${aUsageType[@]}
	do
		if [ ${ScreenSignal} -eq 1 ]
		then
			aNumSpatialLayer=(1)
		fi
		
		for NumSpatialLayer in ${aNumSpatialLayer[@]}
		do
			for NumTempLayer in ${aNumTempLayer[@]}
			do
				for RCModeIndex in ${aRCMode[@]}
				do
					if [[  "$aRCModeIndex" =~  "0"  ]]
					then
						aQPforTest=${aInitialQP[@]}
						aTargetBitrateSet=("256,256,256,256,")
					else
						aQPforTest=(26)
						runGenerateMultiLayerBRSet ${NumSpatialLayer}
					fi
					#......for loop.........................................#
					for QPIndex in ${aQPforTest[@]}
					do
						for BitRateIndex in ${aTargetBitrateSet[@]}
						do
							runGenerateLayerResolution   ${NumSpatialLayer}
							echo "$ScreenSignal, \
								$FramesToBeEncoded,\
								${NumSpatialLayer},\
								$NumTempLayer,\
								${PicW}, ${PicH},\
								${MultiLayerResolutionInfo}  \
								${FPS}, ${FPS},${FPS},${FPS},\
								${QPIndex}, ${QPIndex},\
								${QPIndex}, ${QPIndex},\
								${RCModeIndex},\
								${BitRateIndex}">>$casefile_01
						done
					done
				done
			done
		done
    done
}
##second stage for case generation
runSecondStageCase()
{
	#for slice number based on different aSliceMode
	declare -a aSliceNumber
	declare -a ThreadNumber
	local TempNalSize=""
    let  "SliceMode3MaxH = 35*16"

	while read FirstStageCase
	do
		if  [[ $FirstStageCase =~ ^[-0-9]  ]]
		then
			for SlcMode in ${aSliceMode[@]}
			do
				aSliceNumber=( `runGetSliceNum  $SlcMode ` )
				#for slice number based on different thread number
				if [ $SlcMode -eq 0  ]
				then
				  ThreadNumber=( 1 )
				else
				  ThreadNumber=( ${aMultipleThreadIdc[@]} )
				fi
				if [  $SlcMode -eq 4  ]
				then
					let "TempNalSize=${MaxNalSize}"
				else
					let "TempNalSize= 0"
				fi
				for SlcNum in ${aSliceNumber[@]}
				do
					for  IntraPeriodIndex in ${aIntraPeriod[@]}
					do
						for ThreadNum in ${ThreadNumber[@]}
						do
							if [ ${SlcMode} -eq 1 -a ${SlcNum} -eq 4   ]
							then
								echo "$FirstStageCase\
								1,4,\
								1,1,\
								1,1,\
								1,1,\
								${TempNalSize},\
								$IntraPeriodIndex,\
								$ThreadNum">>$casefile_02
                            elif [ ${SlcMode} -eq 3 -a ${PicH} -ge ${SliceMode3MaxH} ]
                            then
                                continue
                            else
								echo "$FirstStageCase\
								${SlcMode}, ${SlcNum},\
								${SlcMode}, ${SlcNum},\
								${SlcMode}, ${SlcNum},\
								${SlcMode}, ${SlcNum},\
								${TempNalSize},\
								${IntraPeriodIndex},\
								${ThreadNum}">>$casefile_02
							fi
						done #threadNum loop
					done #aSliceNum loop
				done #Slice Mode loop
			done # Entropy loop
		fi
  done <$casefile_01
}
#the third stage for case generation
runThirdStageCase()
{
	local SliceMd=""
	local DenoiseFlag=""
	local SceneChangeFlag=""
	local BackgroundFlag=""
	local AQFlag=""
	declare -a CaseInfo
	while read SecondStageCase
	do
		if [[ $SecondStageCase =~ ^[-0-9]  ]]
		then
			for LTRFlag in ${aEnableLongTermReference[@]}
			do
				for LoopfilterIndex in ${aLoopFilterDisableIDC[@]}
				do
					for  DenoiseFlag in ${aEnableDenoise[@]}
					do
						for  SceneChangeFlag in ${aEnableSceneChangeDetection[@]}
						do
							for  BackgroundFlag in ${aEnableBackgroundDetection[@]}
							do
								for  AQFlag in ${aEnableAdaptiveQuantization}
								do
									echo "$SecondStageCase,\
										$LTRFlag,\
										$LoopfilterIndex,\
										${DenoiseFlag},\
										${SceneChangeFlag},\
										${BackgroundFlag},\
										${AQFlag}">>$casefile
                                        let "TotalCasesNum ++"
								done
							done
						done
					done
				done
			done
		fi
	done <$casefile_02
}
#only for test
runOutputParseResult()
{
    echo ""
    echo -e "\033[32m ********************************************************************* \033[0m"
    echo -e "\033[32m Test cases generation result for ${TestSequence} \033[0m"
    echo -e "\033[32m TotalCasesNum is ${TotalCasesNum}"
    echo -e "\033[32m ********************************************************************* \033[0m"
	echo "PicWxPicH_FPS is ${PicW}x${PicH}_${FPS}"
	echo "all cases info have been  output to file $casefile "
	echo "aUsageType=         ${aUsageType[@]}"
	echo "Frames=             $FramesToBeEncoded"
	echo "aNumSpatialLayer=   ${aNumSpatialLayer[@]}"
	echo "aNumTempLayer=      ${aNumTempLayer[@]}"
	echo "MaxNalSize=         $MaxNalSize"
	echo "aRCMode=            ${aRCMode[@]}"
	echo "aInitialQP=         ${aInitialQP[@]}"
	echo "aIntraPeriod=       ${aIntraPeriod}"
	echo "aSliceMode=         ${aSliceMode[@]}"
	echo "aSliceNum0=         ${aSliceNum0[@]}"
	echo "aSliceNum1=         ${aSliceNum1[@]}"
	echo "aSliceNum2=         ${aSliceNum2[@]}"
	echo "aSliceNum3=         ${aSliceNum3[@]}"
	echo "aSliceNum4=         ${aSliceNum4[@]}"
	echo "aMultipleThreadIdc= ${aMultipleThreadIdc[@]}"
	echo "aEnableLongTermReference=      ${aEnableLongTermReference[@]}"
	echo "aLoopFilterDisableIDC=         ${aLoopFilterDisableIDC[@]}"
	echo "aEnableDenoise=                ${aEnableDenoise[@]}"
	echo "aEnableSceneChangeDetection=   ${aEnableSceneChangeDetection[@]}"
	echo "aEnableBackgroundDetection=    ${aEnableBackgroundDetection[@]}"
	echo "aEnableAdaptiveQuantization=   ${aEnableAdaptiveQuantization[@]}"
	echo ""
	echo "aSpatialLayerResolutionSet1  is ${aSpatialLayerResolutionSet1[@]}"
	echo "aSpatialLayerResolutionSet2  is ${aSpatialLayerResolutionSet2[@]}"
	echo "aSpatialLayerResolutionSet3  is ${aSpatialLayerResolutionSet3[@]}"
	echo "aSpatialLayerResolutionSet4  is ${aSpatialLayerResolutionSet4[@]}"
	echo ""
	echo "aSpatialLayerBRSet1 is ${aSpatialLayerBRSet1[@]}"
	echo "aSpatialLayerBRSet2 is ${aSpatialLayerBRSet2[@]}"
	echo "aSpatialLayerBRSet3 is ${aSpatialLayerBRSet3[@]}"
	echo "aSpatialLayerBRSet4 is ${aSpatialLayerBRSet4[@]}"
    echo -e "\033[32m ********************************************************************* \033[0m"
    echo ""
}
runBeforeGenerate()
{
  headline="UsageType, \
		EncodedNum,   \
		NumSpaceLayer,\
		NumTempLayer, \
		PicWidth,  \
		PicHeiht,  \
		PicWLayer0,\
		PicHLayer0,\
		PicWLayer1,\
		PicHLayer1,\
		PicWLayer2,\
		PicHLayer2,\
		PicWLayer3,\
		PicHLayer3,\
		FPSLayer0,\
		FPSLayer1,\
		FPSLayer2,\
		FPSLayer3,\
		QPLayer0,\
		QPLayer1,\
		QPLayer2,\
		QPLayer3,\
		RCMode,\
		BROverAll,\
		BRLayer0,\
		BRLayer1,\
		BRLayer2,\
		BRLayer3,\
		SliceMdLayer0, \
		SliceNmuLayer0,\
		SliceMdLayer1, \
		SliceNmuLayer1,\
		SliceMdLayer2, \
		SliceNmuLayer2,\
		SliceMdLayer3, \
		SliceNmuLayer3,\
		MaxNalSize,\
		IntraPeriod,\
		MultipleThreadIdc,\
		EnableLongTermReference,\
		LoopFilterDisableIDC,\
		DenoiseFlag,\
		SceneChangeFlag,\
		BackgroundFlag,\
		AQFlag"
  echo $headline>$casefile
  echo $headline>$casefile_01
  echo $headline>$casefile_02
}
runAfterGenerate()
{
  #deleted temp_case file
  ./run_SafeDelete.sh $casefile_01
  ./run_SafeDelete.sh $casefile_02
}
#usage:   runMain   $Case.cfg   $TestSequence  $OutputCaseFile
runMain()
{
  if [ ! $# -eq 3 ]
  then
    echo "usage:   runMain   \$Case.cfg   \$TestSequence  \$OutputCaseFile  "
    return 1
  fi

  ConfigureFile=$1
  TestSequence=$2
  OutputCaseFile=$3
  let "TotalCasesNum=0"


  ConfigureFile=`echo ${ConfigureFile} | awk 'BEGIN {FS="/"} {print $NF}'`
  if [ ! -f ${ConfigureFile} ]
  then
    echo "configure file does not exist, please double check!"
    echo "${ConfigureFile} for cases generation!"
    exit 1
  fi

  runGlobalVariableInital  $TestSequence  $OutputCaseFile
  runParseCaseConfigure  ${ConfigureFile}
  runMultiLayerInitial
  runBeforeGenerate
  runFirstStageCase
  runSecondStageCase
  runThirdStageCase
  runAfterGenerate
  runOutputParseResult
}
ConfigureFile=$1
TestSequence=$2
OutputCaseFile=$3
echo ""
echo "case generating ......"
runMain  ${ConfigureFile}   ${TestSequence}   ${OutputCaseFile}

