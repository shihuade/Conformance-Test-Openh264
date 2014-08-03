#!/bin/bash

#usage: run_GetMultiLayerBRPoint.sh  $PicW $PicH  $FPS  $MaxLayerBR $ConfigureFile

# runGlobalVariableInital ${ConfigureFile}
runGlobalVariableInital()
{

  if [ ! $# -eq 1  ]
  then
	echo "runGlobalVariableInital ${ConfigureFile}"
	exit 1
  fi
  
  local ConfigureFile=$1
  
  WidthLayer_0="0"
  WidthLayer_1="0"
  WidthLayer_2="0"
  WidthLayer_3="0"
  
  HeightLayer_0="0"
  HeightLayer_1="0"
  HeightLayer_2="0"  
  HeightLayer_3="0"
  
  TargetBRLayer_0="0"
  TargetBRLayer_1="0"
  TargetBRLayer_2="0"
  TargetBRLayer_3="0"

  declare -a aLayerWidth
  declare -a aLayerHeight

  declare -a aBitRatePointLayer0
  declare -a aBitRatePointLayer1 
  declare -a aBitRatePointLayer2
  declare -a aBitRatePointLayer3 
  
  let "PointNumLayer0 = 0"
  let "PointNumLayer1 = 0"
  let "PointNumLayer2 = 0"
  let "PointNumLayer3 = 0"  
  TargetBitRate_QCIF=""     #176x144,   for those resolution: PicWXPicH <=176x144
  TargetBitRate_QVGA=""     #320x240,   for those resolution: 176x144    <  PicWXPicH <= 320x240	
  TargetBitRate_VGA=""      #640x480,   for those resolution: 320x240    <  PicWXPicH <= 640x480	 	
  TargetBitRate_SVGA=""     #800x600,   for those resolution: 640x480    <  PicWXPicH <= 800x600		
  TargetBitRate_XGA=""      #1024x768,  for those resolution: 800x600    <  PicWXPicH <= 1024x768
  TargetBitRate_SXGA=""     #1280x1024, for those resolution: 1024x768   <  PicWXPicH <= 1280x1024
  TargetBitRate_WSXGA=""    #1680x1050, for those resolution: 1280x1024  <  PicWXPicH <= 1680x1050
  TargetBitRate_WUXGA=""    #1920x1200, for those resolution: 1680x1050  <  PicWXPicH <= 1920x1200
  TargetBitRate_QXGA=""     #2048x1536, for those resolution: 1920x1200  <  PicWXPicH <= 2048x1536 
  
  let "Flag_QCIF  =176*144"
  let "Flag_QVGA  =320*240"
  let "Flag_VGA   =640*480"
  let "Flag_SVGA  =800*600"
  let "Flag_XGA   =1024*768"
  let "Flag_SXGA  =1280*1024"
  let "Flag_WSXGA =1680*1050"
  let "Flag_WUXGA =1920*1200"
  let "Flag_QXGA  =2048*1536"  
  
 while read line
  do
	if [[ "$line" =~ ^TargetBitRate_QCIF  ]]
    then
      TargetBitRate_QCIF=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_QVGA  ]]
    then
      TargetBitRate_QVGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_VGA  ]]
    then
      TargetBitRate_VGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_SVGA  ]]
    then
      TargetBitRate_SVGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `	
    elif [[ "$line" =~ ^TargetBitRate_XGA  ]]
    then
      TargetBitRate_XGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_SXGA  ]]
    then
      TargetBitRate_SXGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `	
    elif [[ "$line" =~ ^TargetBitRate_WSXGA+  ]]
    then
      TargetBitRate_WSXGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `	
    elif [[ "$line" =~ ^TargetBitRate_WUXGA  ]]
    then
      TargetBitRate_WUXGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `	
    elif [[ "$line" =~ ^TargetBitRate_QXGA  ]]
    then
      TargetBitRate_QXGA=`echo $line | awk 'BEGIN {FS="[#:]" } {print $2}' `	
    fi
  done <$ConfigureFile

}

#usage  runGetTargetBitRate  $PicWidth  $PicHeight $FrameRate
#eg:    input:  runGetTargetBitRate  
#       output:    1500  800 300   100   (for test_1920X1080.yuv)
runGetTargetBitRate()
{
   if [ ! $# -eq 3  ]
  then
	echo "usage: runGetTargetBitRate  \$PicWidth  \$PicHeight \$FrameRate"
	exit 1
  fi
  
  local PicWidth=$1
  local PicHeight=$2
  local FrameRate=$3
  local TotalPixel=""
  local BitRateFactor="1"
  declare -a aTargetBitRate
  
  let "TotalPixel= ${PicWidth}*${PicWidth}"
  let "NumBitRatePoint=0"
  let "BitRateFactor=${FPS}/10"
  
  if [  ${TotalPixel} -le ${Flag_QCIF} ]
  then
    aTargetBitRate=( ${TargetBitRate_QCIF} )
  elif [  ${TotalPixel} -le ${Flag_QVGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_QVGA} )
  elif [  ${TotalPixel} -le ${Flag_VGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_VGA} ) 
   elif [  ${TotalPixel} -le ${Flag_SVGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_SVGA} )
  elif [  ${TotalPixel} -le ${Flag_XGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_XGA} )
  elif [  ${TotalPixel} -le ${Flag_SXGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_SXGA} )
  elif [  ${TotalPixel} -le ${Flag_WSXGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_WSXGA} )
  elif [  ${TotalPixel} -le ${Flag_WUXGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_WUXGA} )
  elif [  ${TotalPixelel} -le ${Flag_QXGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_QXGA} )
  fi
  
  NumBitRatePoint=${#aTargetBitRate[@]}
  
  for((i=0; i< ${NumBitRatePoint}; i++))
  do
    let "TargetBitrate[$i]=${aTargetBitRate[$i]}*${BitRateFactor}"
  done
  
  echo ${aTargetBitRate[@]} 
}


runSetLayerInfo()
{


	let "WidthLayer_0=PicW/8"
	let "WidthLayer_1=PicW/4"
	let "WidthLayer_2=PicW/2"
	let "WidthLayer_3=PicW"
	
	let "HeightLayer_0=PicH/8"
	let "HeightLayer_1=PicH/4"
	let "HeightLayer_2=PicH/2"
	let "HeightLayer_3=PicH"
	
	
    aLayerWidth=(  ${WidthLayer_3}  ${WidthLayer_2}  ${WidthLayer_1}  ${WidthLayer_0}  )
    aLayerHeight=( ${HeightLayer_3} ${HeightLayer_2} ${HeightLayer_1} ${HeightLayer_0} )
	
	aBitRatePointLayer3=(`runGetTargetBitRate  ${aLayerWidth[0]}  ${aLayerHeight[0]} ${FPS}`)
	aBitRatePointLayer2=(`runGetTargetBitRate  ${aLayerWidth[1]}  ${aLayerHeight[1]} ${FPS}`)
	aBitRatePointLayer1=(`runGetTargetBitRate  ${aLayerWidth[2]}  ${aLayerHeight[2]} ${FPS}`)
	aBitRatePointLayer0=(`runGetTargetBitRate  ${aLayerWidth[3]}  ${aLayerHeight[3]} ${FPS}`)
	
	let "PointNumLayer0 = ${#aBitRatePointLayer0[@]}"
	let "PointNumLayer1 = ${#aBitRatePointLayer1[@]}"
	let "PointNumLayer2 = ${#aBitRatePointLayer2[@]}"
	let "PointNumLayer3 = ${#aBitRatePointLayer3[@]}"
}

#usage: run_GetMultiLayerBRPoint.sh  $PicW $PicH  $FPS  $MaxLayerBR $ConfigureFile
runMain()
{
  if [ ! $# -eq 5 ]
  then
    echo "usage: run_GetMultiLayerBRPoint.sh  \$PicW \$PicH  \$FPS  \$MaxLayerBR \$ConfigureFile"
	exit 1
  fi

  PicW=$1
  PicH=$2
  FPS=$3
  MaxLayerBR=$4
  ConfigureFile=$5

  if [ ${PicW} -eq 0 -o ${PicH} -eq 0  -o ${FPS} -eq 0  ]
  then
	echo "YUV info is not correct, please double check!"
	exit 1
  fi
  
  runGlobalVariableInital ${ConfigureFile}
  runSetLayerInfo
  
  let "BRPointIndex =0"
  let "Flag=0"
  
  echo ${aBitRatePointLayer3[@]}
  echo ${aBitRatePointLayer2[@]}
  echo ${aBitRatePointLayer1[@]}
  echo ${aBitRatePointLayer0[@]}
  
  echo ""
  echo "Layer info is:"
  echo ${aLayerWidth[@]}
  echo ${aLayerHeight[@]}
  
  for BRPoint in ${aBitRatePointLayer3[@]}
  do
  
	if [ ${BRPoint} -eq ${MaxLayerBR} ]
	then
	   let "Flag=1"
	   break
	fi
	 let "BRPointIndex ++"
  done
  
  if [ ${Flag} -eq 0 ]
  then
   TargetBRLayer_3=${MaxLayerBR}
   TargetBRLayer_2=${aBitRatePointLayer2[${PointNumLayer2}-1]}
   TargetBRLayer_1=${aBitRatePointLayer1[${PointNumLayer1}-1]}
   TargetBRLayer_0=${aBitRatePointLayer0[${PointNumLayer0}-1]}
  else
   TargetBRLayer_3=${aBitRatePointLayer3[${BRPointIndex}]}
   TargetBRLayer_2=${aBitRatePointLayer2[${BRPointIndex}]}
   TargetBRLayer_1=${aBitRatePointLayer1[${BRPointIndex}]}
   TargetBRLayer_0=${aBitRatePointLayer0[${BRPointIndex}]}
  fi
  
  echo " ${TargetBRLayer_3}  ${TargetBRLayer_2}  ${TargetBRLayer_1}  ${TargetBRLayer_0}  "
  
}
PicW=$1
PicH=$2
FPS=$3
MaxLayerBR=$4
ConfigureFile=$5
runMain  $PicW $PicH  $FPS  $MaxLayerBR $ConfigureFile


