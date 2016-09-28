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

runGlobalVariableInital()
{
    declare -a  aNumSpatialLayer;   declare -a  aNumTempLayer
    declare -a  aUsageType;         declare -a  aIntraPeriod
    declare -a  aRCMode;            declare -a  aFrameSkip;       declare -a  aTargetBitrateSet;   declare -a  aInitialQP
    declare -a  aSliceMode;         declare -a  aSliceNum0;       declare -a  aSliceNum1
    declare -a  aSliceNum2;         declare -a  aSliceNum3;       declare -a  aSliceNum4
    declare -a  aMultipleThreadIdc; declare -a  aUseLoadBalancing
    declare -a  aEnableLongTermReference;   declare -a  aLoopFilterDisableIDC
    declare -a  aEnableDenoise;             declare -a  aEnableSceneChangeDetection
    declare -a  aEnableBackgroundDetection; declare -a  aEnableAdaptiveQuantization
    declare -a aSpatialLayerResolutionSet1; declare -a  aSpatialLayerResolutionSet2
    declare -a aSpatialLayerResolutionSet3; declare -a  aSpatialLayerResolutionSet4
    declare -a aSpatialLayerBRSet1;         declare -a  aSpatialLayerBRSet2
    declare -a aSpatialLayerBRSet3;         declare -a  aSpatialLayerBRSet4

    let " FramesToBeEncoded = 0";let " MaxNalSize = 0"
    let " Multiple16Flag=0";     let "TotalCasesNum=0"
	let "PicW=0";let "PicH=0";let "FPS=0"
	let "MultiLayerFlag=0"
    MultiLayerResolutionInfo="0,0,   0,0,   0,0,  0,0"

	#generate test cases and output to case file
	casefile=${OutputCaseFile}
	casefile_01=${OutputCaseFile}_01.csv
	casefile_02=${OutputCaseFile}_02.csv
}

runParseYUVInfo()
{
    aYUVInfo=(`./run_ParseYUVInfo.sh  ${TestSequence}`)
    PicW=${aYUVInfo[0]};PicH=${aYUVInfo[1]};FPS=${aYUVInfo[2]}
    [ ${PicW} -eq 0 -o ${PicH} -eq 0 ] && echo "YUVName is not correct,should be named as ABC_PicWXPicH_FPS.yuv" && exit 1

    [ ${FPS} -eq 0 ]  && let "FPS=30"; [ ${FPS} -gt 60 ] && let "FPS=60"

    return 0
}

runCaseValidationcheck()
{
    echo "to do"
}

runMultiLayerInitial()
{
    #set test cases' spactial layer num
	MultiLayerNum=`./run_GetSpatialLayerNum.sh  ${PicW}  ${PicH}`
	[ ${MultiLayerFlag} -eq 0 ] && aNumSpatialLayer=( 1 )
	[ ${MultiLayerFlag} -eq 1 ] && aNumSpatialLayer=( ${MultiLayerNum} )
	[ ${MultiLayerFlag} -eq 2 ] && [ ${MultiLayerNum} -gt 1 ] && aNumSpatialLayer=( 1 ${MultiLayerNum} )
	[ ${MultiLayerFlag} -eq 2 ] && [ ${MultiLayerNum} -eq 1 ] && aNumSpatialLayer=( 1 )
	
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
	local SpatialNum=$1
	local TempLayerBRInfo=""
	local OverallBR="0"

	[ ${SpatialNum} -eq 1 ] && TempLayerBRInfo="${aSpatialLayerBRSet1[@]}"
	[ ${SpatialNum} -eq 2 ] && TempLayerBRInfo="${aSpatialLayerBRSet2[@]}"
	[ ${SpatialNum} -eq 3 ] && TempLayerBRInfo="${aSpatialLayerBRSet3[@]}"
	[ ${SpatialNum} -eq 4 ] && TempLayerBRInfo="${aSpatialLayerBRSet4[@]}"

    #example:   TempLayerBRInfo="200 400 800 0 , 50 300 600 0 ,"
    #        -->aTempLayerBRInfo=(200 400 800 0   50 300 600 0)
    aTempLayerBRInfo=(`echo ${TempLayerBRInfo}  | awk ' BEGIN  {FS=","}  {for(i=1;i<=NF;i++) printf(" %s",$i) }'`)
	TempTotalNum=`echo ${TempLayerBRInfo}  | awk ' BEGIN  {FS=","}  {printf NF-1 }'`
	for ((i=0;i<${TempTotalNum}; i++))
	do
        let "j = i*4"
	    #bc tool to calculate overall target bit rate
		OverallBR=`echo "scale=2;           ${aTempLayerBRInfo[$i+0]}+${aTempLayerBRInfo[$i+1]}+${aTempLayerBRInfo[$i+2]}+${aTempLayerBRInfo[$i+3]}" | bc`
        LayerBR="${aTempLayerBRInfo[$j+0]},${aTempLayerBRInfo[$j+1]},${aTempLayerBRInfo[$j+2]},${aTempLayerBRInfo[$j+3]}"
        MaxLayerBR=${LayerBR}

        #OveralBR, LayerBR_0, LayerBR_1, LayerBR_2, LayerBR_3, MaxLayerBR_0, MaxLayerBR_1, MaxLayerBR_2, MaxLayerBR_3,
		aTargetBitrateSet[$i]="${OverallBR},${LayerBR},${MaxLayerBR},"
    done
}
#usage: runGenerateLayerResolution ${SpatialNum}
runGenerateLayerResolution()
{
	local SpatialNum=$1
	local TempLayerResolution=""
	[ ${SpatialNum} -eq 1 ] && TempLayerResolution="${aSpatialLayerResolutionSet1[@]}"
	[ ${SpatialNum} -eq 2 ] && TempLayerResolution="${aSpatialLayerResolutionSet2[@]}"
	[ ${SpatialNum} -eq 3 ] && TempLayerResolution="${aSpatialLayerResolutionSet3[@]}"
	[ ${SpatialNum} -eq 4 ] && TempLayerResolution="${aSpatialLayerResolutionSet4[@]}"

    #Example:   TempLayerResolution="360 640   720 1280   0 0   0 0"
    #        -->MultiLayerResolutionInfo=(360, 640,   720, 1280,   0, 0,   0, 0,)
    MultiLayerResolutionInfo=`echo ${TempLayerResolution} |awk '{for(i=1;i<=NF;i++) printf("%s,",$i)}' `
}

#usage:  runParseCaseConfigure $ConfigureFile
runParseCaseConfigure()
{
    aUsageType=(`cat ${ConfigureFile}         | grep ^UsageType         | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    FramesToBeEncoded=(`cat ${ConfigureFile}  | grep ^FramesToBeEnc     | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    MultiLayerFlag=(`cat ${ConfigureFile}     | grep ^MultiLayer        | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aNumTempLayer=(`cat ${ConfigureFile}      | grep ^TemporalLayerNum  | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aMultipleThreadIdc=(`cat ${ConfigureFile} | grep ^MultipleThreadIdc | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aUseLoadBalancing=(`cat ${ConfigureFile}  | grep ^UseLoadBalancing  | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)

    aSliceMode=(`cat ${ConfigureFile} | grep ^SliceMode | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aSliceNum0=(`cat ${ConfigureFile} | grep ^SliceNum0 | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aSliceNum1=(`cat ${ConfigureFile} | grep ^SliceNum1 | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aSliceNum2=(`cat ${ConfigureFile} | grep ^SliceNum2 | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aSliceNum3=(`cat ${ConfigureFile} | grep ^SliceNum3 | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aSliceNum4=(`cat ${ConfigureFile} | grep ^SliceNum4 | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)

    aIntraPeriod=(`cat ${ConfigureFile}   | grep ^IntraPeriod     | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aRCMode=(`cat ${ConfigureFile}        | grep ^RCMode          | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aFrameSkip=(`cat ${ConfigureFile}     | grep ^EnableFrameSkip | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    MaxNalSize=(`cat ${ConfigureFile}     | grep ^MaxNalSize      | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aInitialQP=(`cat ${ConfigureFile}     | grep ^InitialQP       | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aEnableDenoise=(`cat ${ConfigureFile} | grep ^EnableDenoise   | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)

    aEnableLongTermReference=(`cat ${ConfigureFile}    | grep ^EnableLongTermReference    | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aLoopFilterDisableIDC=(`cat ${ConfigureFile}       | grep ^LoopFilterDisableIDC       | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aEnableSceneChangeDetection=(`cat ${ConfigureFile} | grep ^EnableSceneChangeDetection | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aEnableBackgroundDetection=(`cat ${ConfigureFile}  | grep ^EnableBackgroundDetection  | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    aEnableAdaptiveQuantization=(`cat ${ConfigureFile} | grep ^EnableAdaptiveQuantization | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)
    Multiple16Flag=(`cat ${ConfigureFile}              | grep ^Multiple16Flag             | awk 'BEGIN {FS="[#:\r]" } {print $2}' `)

    #overwrite encoded frame num for special resolition, need to keep the same logic which in run_PrepareInputYUV.sh
    # encode frame num is used to check recYUVSize and JMDecYUVSize in case validate logic in run_CheckBasicCheck.sh
    [ ${PicW} -gt 320 ] && [ ${PicW} -le 640 ] && FramesToBeEncoded=(100)
}
#usage: runGetSliceNum  $SliceMd
runGetSliceNum()
{
	local SlicMdIndex=$1

	[ ${SlicMdIndex} -eq 0 ] && echo ${aSliceNum0[@]}
	[ ${SlicMdIndex} -eq 1 ] && echo ${aSliceNum1[@]}
	[ ${SlicMdIndex} -eq 2 ] && echo ${aSliceNum2[@]}
	[ ${SlicMdIndex} -eq 3 ] && echo ${aSliceNum3[@]}
	[ ${SlicMdIndex} -eq 4 ] && echo ${aSliceNum4[@]}
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
            runGenerateLayerResolution   ${NumSpatialLayer}

			for NumTempLayer in ${aNumTempLayer[@]}
			do
				for RCModeIndex in ${aRCMode[@]}
				do
					if [[  "$aRCModeIndex" =~  "-1"  ]]
					then
						aQPforTest=${aInitialQP[@]}
						aTargetBitrateSet=("256,256,256,256,")
                        aFrameSkip=(0)
					else
						aQPforTest=(26)
						runGenerateMultiLayerBRSet ${NumSpatialLayer}
					fi

                    for vFrameSkipFlag in ${aFrameSkip[@]}
                    do

                        #......for loop.........................................#
                        for QPIndex in ${aQPforTest[@]}
                        do
                            for BitRateIndex in ${aTargetBitrateSet[@]}
                            do
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
                                ${vFrameSkipFlag},\
								${BitRateIndex}">>$casefile_01
                            done
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
        for SlcMode in ${aSliceMode[@]}
        do
            aSliceNumber=( `runGetSliceNum  $SlcMode ` )
            if [  $SlcMode -eq 3  ]
            then
                let "TempNalSize=${MaxNalSize}"
            else
                let "TempNalSize= 0"
            fi
            for SlcNum in ${aSliceNumber[@]}
            do
                #thread num based on slice num
                ThreadNumber=( ${aMultipleThreadIdc[@]} )
                [ $SlcMode -eq 0  ] || [ ${SlcNum} -eq 1 ]  && ThreadNumber=( 1 )

                for  IntraPeriodIndex in ${aIntraPeriod[@]}
                do
                    for ThreadNum in ${ThreadNumber[@]}
                    do
                        for LoadBalancing in ${aUseLoadBalancing[@]}
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
                                $ThreadNum,\
                                $LoadBalancing">>$casefile_02
                            else
                                echo "$FirstStageCase\
                                ${SlcMode}, ${SlcNum},\
                                ${SlcMode}, ${SlcNum},\
                                ${SlcMode}, ${SlcNum},\
                                ${SlcMode}, ${SlcNum},\
                                ${TempNalSize},\
                                ${IntraPeriodIndex},\
                                ${ThreadNum},\
                                $LoadBalancing">>$casefile_02
                            fi
                        done #loadbalancing loop
                    done #threadNum loop
                done #aSliceNum loop
            done #Slice Mode loop
        done # Entropy loop
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
	done <$casefile_02
}
#only for test
runOutputParseResult()
{
    echo ""
    echo -e "\033[32m ********************************************************************* \033[0m"
    echo -e "\033[32m Test cases generation result for ${TestSequence} \033[0m"
    echo -e "\033[32m TotalCasesNum is: ${TotalCasesNum}               \033[0m"
    echo -e "\033[32m   Start time  is: ${StartTime}                   \033[0m"
    echo -e "\033[32m   End time    is: ${EndTime}                     \033[0m"
    echo -e "\033[32m ********************************************************************* \033[0m"
	echo "PicWxPicH_FPS is ${PicW}x${PicH}_${FPS}"
	echo "all cases info have been  output to file $casefile "
	echo "aUsageType=         ${aUsageType[@]}"
	echo "Frames=             $FramesToBeEncoded"
	echo "aNumSpatialLayer=   ${aNumSpatialLayer[@]}"
	echo "aNumTempLayer=      ${aNumTempLayer[@]}"
	echo "MaxNalSize=         $MaxNalSize"
	echo "aRCMode=            ${aRCMode[@]}"
	echo "aFrameSkip=         ${aFrameSkip[@]}"
	echo "aInitialQP=         ${aInitialQP[@]}"
	echo "aIntraPeriod=       ${aIntraPeriod}"
	echo "aSliceMode=         ${aSliceMode[@]}"
	echo "aSliceNum0=         ${aSliceNum0[@]}"
	echo "aSliceNum1=         ${aSliceNum1[@]}"
	echo "aSliceNum2=         ${aSliceNum2[@]}"
	echo "aSliceNum3=         ${aSliceNum3[@]}"
	echo "aSliceNum4=         ${aSliceNum4[@]}"
	echo "aMultipleThreadIdc= ${aMultipleThreadIdc[@]}"
	echo "aUseLoadBalancing=  ${aUseLoadBalancing[@]}"
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
    echo "aTargetBitrateSet is ${aTargetBitrateSet[@]}"
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
        FrameSkip,\
		BROverAll,\
		BRLayer0,\
		BRLayer1,\
		BRLayer2,\
		BRLayer3,\
        MaxBRLayer0,\
        MaxBRLayer1,\
        MaxBRLayer2,\
        MaxBRLayer3,\
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
		LoadBalancing,\
		EnableLongTermReference,\
		LoopFilterDisableIDC,\
		DenoiseFlag,\
		SceneChangeFlag,\
		BackgroundFlag,\
		AQFlag"
  echo $headline>$casefile
#echo $headline>$casefile_01
#echo $headline>$casefile_02
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
  [ ! -f ${ConfigureFile} ] && ConfigureFile=`echo ${ConfigureFile} | awk 'BEGIN {FS="/"} {print $NF}'`
  [ ! -f ${ConfigureFile} ] && echo "configure file does not exist, please double check!" && exit 1

  StartTime=`date`
  runGlobalVariableInital
  runParseYUVInfo

  runParseCaseConfigure

  runMultiLayerInitial
  runBeforeGenerate
  runFirstStageCase
  runSecondStageCase

  runThirdStageCase
  runAfterGenerate

  EndTime=`date`
  runOutputParseResult
}

#******************************************************************************************************************
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo "*********************************************************"
echo ""
if [ ! $# -eq 3 ]
then
    echo "usage:   runMain   \$Case.cfg   \$TestSequence  \$OutputCaseFile  "
    exit 1
fi

ConfigureFile=$1
TestSequence=$2
OutputCaseFile=$3

runMain
#******************************************************************************************************************
