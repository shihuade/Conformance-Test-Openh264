#!/bin/bash
#*********************************************************************************************
#  --for multiple layer test, generate input YUV for another spacial layer 
#
#  --usage:   run_PrepareMultiLayerInputYUV.sh ${OriginInputYUV} ${LayerNum} ${PrepareLog} ${Multiple16Flag}
#                                              ${LayerNum}       2<=${LayerNum}<=4        
#                                              ${Multiple16Flag} sub layer's resolution is multiple of 16 or not
#  --eg:
#    input:  run_PrepareMultiLayerInputYUV.sh  ../../ABC_1080X720_30fps.yuv   3  prepare.log  0
#    output: there will be tow down sample YUV generated under current directory.
#            ----ABC_540X360_30fps.yuv
#            ----ABC_270X180_30fps.yuv
#            ----prepare.log
#  --note: YUV name must be named as XXX_PicWxPicH_FPSxxxx.yuv  
#
#*********************************************************************************************
#usage: runGlobalVariableInitial ${OriginYUV}
runGlobalVariableInitial()
{
	if [ ! $# -eq 1   ]
	then
		echo "usage: runGlobalVariableInitial \${OriginYUV}"
		return 1
	fi
	OriginYUV=$1
	OriginYUVName=""
	OriginWidth=""
	OriginHeight=""
	FPS=""
	LayerWidth_0=""
	LayerWidth_1=""
	LayerWidth_2=""
	LayerWidth_3=""
		
	LayerHeight_0=""
	LayerHeight_1=""	
	LayerHeight_2=""
	LayerHeight_3=""
	
	OutputYUVLayer_0=""
	OutputYUVLayer_1=""
	OutputYUVLayer_2=""
	OutputYUVLayer_3=""
	
	DownSampleExe="DownConvertStatic"
	declare -a aYUVInfo
	declare -a aLayerWidth
	declare -a aLayerHeight
	declare -a aOutputLayerName
	declare -a aLayerYUVList
	declare -a aYUVSize
}
#usage: runRenameOutPutYUV  ${OriginYUVName} ${OutputWidth}  ${OutputHeight}
#eg:   
#      input:  runRenameOutPutYUV  ABC_1080X720_30fps.yuv   540  360
#      output: ABC_540X360_30fps.yuv 
runRenameOutPutYUV()
{
	if [ ! $# -eq 3  ]
	then 
		echo "usage: runRenameOutPutYUV  \${OriginYUVName} \${OutputWidth}  \${OutputHeight}"
		return 1
	fi
	local OriginYUVName=$1
	local OutputWidth=$2
	local OutputHeight=$3
	local OriginYUVWidth="0"
	local OriginYUVHeight="0"
	local OutputYUVName=""
	declare -a aPicInfo
	local Iterm=""
	local Index=""
	local Pattern_01="[xX]"
	local Pattern_02="^[1-9][0-9]"
	local Pattern_03="[0-9][0-9]$"
	local Pattern_04="fps$"
	local LastItermIndex=""
	aPicInfo=(`echo ${OriginYUVName} | awk 'BEGIN {FS="[_.]"} {for(i=1;i<=NF;i++) printf("%s  ",$i)}'`)
	let "LastItermIndex=${#aPicInfo[@]} - 1"
	#get PicW PicH info
	let "Index=0"
	for  Iterm in ${aPicInfo[@]}
	do
		if [[ $Iterm =~ $Pattern_01 ]] && [[ $Iterm =~ $Pattern_02 ]] && [[ $Iterm =~ $Pattern_03 ]]
		then			
			Iterm="${OutputWidth}X${OutputHeight}"
		fi
		if [  $Index -eq 0 ]
		then
			OutputYUVName=${Iterm}
		elif [  $Index -eq ${LastItermIndex}  ]
		then
			OutputYUVName="${OutputYUVName}.${Iterm}"
		else
			OutputYUVName="${OutputYUVName}_${Iterm}"
		fi
		let "Index++"
	done
	echo "${OutputYUVName}"
}
#usage: runExtendMultiple16 ${PicW} or ${PicH}
runExtendMultiple16()
{
	if [ $1 -lt 4 ]
	then
		echo "usage: runExtendMultiple16 \${PicW} or \${PicH}"
		exit 1
	fi
	local Num=$1
	let  "TempNum=0"
	let "Remainder=${Num}%16"
	if [ ${Remainder} -eq 0  ]
	then
		let  "TempNum=${Num}"
	else
		let  "TempNum=${Num} + 16 - ${Remainder}"
	fi
	echo "${TempNum}"
	return 0
}
#usage: runSetLayerInfo
runSetLayerInfo()
{
	OriginYUVName=`echo ${OriginYUV} | awk 'BEGIN  {FS="/"} {print $NF}'`
	aYUVInfo=(`./run_ParseYUVInfo.sh  ${OriginYUVName}`)
    OriginWidth=${aYUVInfo[0]}
	OriginHeight=${aYUVInfo[1]}
	FPS=${aYUVInfo[2]}
	if [  ${OriginWidth} -eq 0  -o ${OriginHeight} -eq 0 ]
	then
		echo "origin YUV info is not right, PicW or PicH equal to 0 "
		exit 1
	fi 
	if [ $FPS -eq 0 ]
	then
		let "FPS=10"
	fi
	if [ $FPS -gt 100 ]
	then
		let "FPS=100"
	fi
	let "LayerWidth_0 = OriginWidth/8 "
	let "LayerWidth_1 = OriginWidth/4 "
	let "LayerWidth_2 = OriginWidth/2 "
	let "LayerWidth_3 = OriginWidth"
	let "LayerHeight_0 = OriginHeight/8 "
	let "LayerHeight_1 = OriginHeight/4 "
	let "LayerHeight_2 = OriginHeight/2 "
	let "LayerHeight_3 = OriginHeight"
	aLayerWidth=(  ${LayerWidth_3}  ${LayerWidth_2}  ${LayerWidth_1}  ${LayerWidth_0}  )
	aLayerHeight=( ${LayerHeight_3} ${LayerHeight_2} ${LayerHeight_1} ${LayerHeight_0} )
	if [ ${Multiple16Flag} -eq 1  ]
	then
	for((i=0;i<4;i++))
		do
			aLayerWidth[$i]=`runExtendMultiple16   ${aLayerWidth[$i]}`
			aLayerHeight[$i]=`runExtendMultiple16  ${aLayerHeight[$i]}`
		done
	fi
	OutputYUVLayer_0=`runRenameOutPutYUV  ${OriginYUVName}   ${aLayerWidth[3]} ${aLayerHeight[3]}`
	OutputYUVLayer_1=`runRenameOutPutYUV  ${OriginYUVName}   ${aLayerWidth[2]} ${aLayerHeight[2]}`
	OutputYUVLayer_2=`runRenameOutPutYUV  ${OriginYUVName}   ${aLayerWidth[1]} ${aLayerHeight[1]}`
	OutputYUVLayer_3=`runRenameOutPutYUV  ${OriginYUVName}   ${aLayerWidth[0]} ${aLayerHeight[0]}`
   aOutputLayerName=( ${OutputYUVLayer_3} ${OutputYUVLayer_2} ${OutputYUVLayer_1} ${OutputYUVLayer_0} )
   
   
    echo "OutputYUVLayer_0 ${OutputYUVLayer_0}"
	echo "OutputYUVLayer_1 ${OutputYUVLayer_1}"
	echo "OutputYUVLayer_2 ${OutputYUVLayer_2}"
	echo "OutputYUVLayer_3 ${OutputYUVLayer_3}"
	for((i=0;i<4;i++))
	do
		let "PicWRemainder= ${aLayerWidth[$i]}%2"
		let "PicHRemainder= ${aLayerHeight[$i]}%2"
		if [ ${PicWRemainder} -eq 1 -o ${PicHRemainder} -eq 1 ]
		then
			echo ""
			echo -e "\033[31m  resolution--${aLayerWidth[$i]}x${aLayerHeight[$i]} is not multiple of 2 \033[0m"
			echo -e "\033[31m  Prepare failed! Please used another test sequence!\033[0m"
			echo ""
			exit 1
		fi	
	done
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
#usage: runSetLayerYUVSize
runSetLayerYUVSize()
{		
	aLayerYUVList=( ${OriginYUV}  ${OutputYUVLayer_2} ${OutputYUVLayer_1} ${OutputYUVLayer_0} )
	for ((i=0; i<4; i++ ))
	do
		if [ -e ${aLayerYUVList[$i]}  ]
		then
			aYUVSize[$i]=`runGetFileSize  ${aLayerYUVList[$i]}`
		else
			aYUVSize[$i]="0"		
		fi	
	done
}
#usage:runOutputPrepareLog
runOutputPrepareLog()
{
	echo "">${PrepareLog}
	for ((i=0; i<4; i++ ))
	do
		let "LayerIndex=3-$i"
		echo "LayerName_${LayerIndex}:  ${aLayerYUVList[$i]}">>${PrepareLog}  
		echo "LayerSize_${LayerIndex}:  ${aYUVSize[$i]}">>${PrepareLog}  
	done
}
#usage: run_PrepareMultiLayerInputYUV.sh ${OriginYUV} ${NumberLayer} ${PrepareLog} ${Multiple16Flag}
runMain()
{
	if [ ! $# -eq 4 ]
	then
		echo "usage: run_PrepareMultiLayerInputYUV.sh \${OriginYUV} \${NumberLayer} \${PrepareLog} \${Multiple16Flag}"
		exit 1
	fi
	
	OriginYUV=$1
	NumberLayer=$2
	PrepareLog=$3
	Multiple16Flag=$4
	let "PrepareFlag=0"
	
	runGlobalVariableInitial ${OriginYUV}
	if [ ! -f ${OriginYUV}  ]
	then
		echo "origin yuv does not exist! please double check!--${OriginYUV}"
		exit 1
	fi
	
	if [  ${NumberLayer} -lt 1  -o  ${NumberLayer} -gt 4 ]
	then
		echo "layer number should be equal to 1 or 2 or 3 or 4 "
		exit 1
	fi
	
	
	runSetLayerInfo
	for ((i=1; i<4; i++ ))
	do
		if [ -e ${aOutputLayerName[i]} ]
		then
			./run_SafeDelete.sh  ${aOutputLayerName[i]}
		fi		
	done
	
	#down sample start from 1/2 PicW layer
	for ((i=1; i<${NumberLayer}; i++ ))
	do
		./${DownSampleExe}  ${OriginWidth} ${OriginHeight} ${OriginYUV}  ${aLayerWidth[$i]} ${aLayerHeight[i]}  ${aOutputLayerName[i]}
		if [ ! $? -eq 0 ]
		then
			let "PrepareFlag=1"
		fi
	done
	
	if [ ! ${PrepareFlag} -eq 0 ]
	then
		echo ""
		echo -e "\033[31m  input YUV preparation failed! \033[0m"
		echo ""
		exit 1
	fi
	runSetLayerYUVSize
	runOutputPrepareLog
	echo ""
	echo -e "\033[32m  input YUV preparation succeed! \033[0m"
	echo ""	
	
	return 0
}
OriginYUV=$1
NumberLayer=$2
PrepareLog=$3
Multiple16Flag=$4
runMain   ${OriginYUV}  ${NumberLayer} ${PrepareLog} ${Multiple16Flag}


