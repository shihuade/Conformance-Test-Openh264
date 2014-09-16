#!/bin/bash
#*******************************************************************************
#brief:  get test bit rate point setting from configure file.
#
#usage:  run_GetTargetBitRate.sh ${PicWidth} ${PicHeight}  ${FPS}  ${ConfigureFile}
#
#e.g:   --input:         run_GetTargetBitRate.sh 1280 720 10  case.cfg
#       --output(kbps):  500  1000
#
#date:  5/08/2014 Created
#*******************************************************************************

#usage  runGlobalVariableInital
runGlobalVariableInital()
{
  declare -a  TargetBitrate

  let "Flag_QCIF  =176*144"
  let "Flag_QVGA  =320*240"
  let "Flag_VGA   =640*480"
  let "Flag_SVGA  =800*600"
  let "Flag_XGA   =1024*768"
  let "Flag_SXGA  =1280*1024"
  let "Flag_WSXGA =1680*1050"
  let "Flag_WUXGA =1920*1200"
  let "Flag_QXGA  =2048*1536"
}

#usage: runParseBRSetting ${ConfigureFile}
runParseBRSetting()
{
  if [ ! $# -eq 1 ]
  then
    echo "usage: runParseBRSetting ${ConfigureFile}"
	exit 1
  fi

  local ConfigureFile=$1
  #read configure file
  while read line
  do
	if [[ "$line" =~ ^TargetBitRate_QCIF  ]]
    then
      TargetBitRate_QCIF=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_QVGA  ]]
    then
      TargetBitRate_QVGA=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_VGA  ]]
    then
      TargetBitRate_VGA=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_SVGA  ]]
    then
      TargetBitRate_SVGA=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_XGA  ]]
    then
      TargetBitRate_XGA=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_SXGA  ]]
    then
      TargetBitRate_SXGA=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_WSXGA+  ]]
    then
      TargetBitRate_WSXGA=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_WUXGA  ]]
    then
      TargetBitRate_WUXGA=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
    elif [[ "$line" =~ ^TargetBitRate_QXGA  ]]
    then
      TargetBitRate_QXGA=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
    fi
  done <$ConfigureFile
}

#usage  runGetTargetBitRate
#eg:    input:  runGetTargetBitRate
#       output:    1500  800 300   100   (for test_1920X1080.yuv)
runGetTargetBitRate()
{

  declare -a aTargetBitRate

  let " TotalPix=PicW*PicH"
  let "NumBitRatePoint=0"

  #us bc tool to calculate the actual bit rate factor
  BitRateFactor=`echo "scale=2; ${FPS}/10.0" | bc`

  if [  ${TotalPix} -le ${Flag_QCIF} ]
  then
    aTargetBitRate=( ${TargetBitRate_QCIF} )
  elif [  ${TotalPix} -le ${Flag_QVGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_QVGA} )
  elif [  ${TotalPix} -le ${Flag_VGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_VGA} )
   elif [  ${TotalPix} -le ${Flag_SVGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_SVGA} )
  elif [  ${TotalPix} -le ${Flag_XGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_XGA} )
  elif [  ${TotalPix} -le ${Flag_SXGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_SXGA} )
  elif [  ${TotalPix} -le ${Flag_WSXGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_WSXGA} )
  elif [  ${TotalPix} -le ${Flag_WUXGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_WUXGA} )
  elif [  ${TotalPix} -le ${Flag_QXGA} ]
  then
    aTargetBitRate=( ${TargetBitRate_QXGA} )
  fi

  NumBitRatePoint=${#aTargetBitRate[@]}

  #us bc tool to calculate the actual bit rate
  for((i=0; i< ${NumBitRatePoint}; i++))
  do
    TargetBitrate[$i]=`echo "scale=2;${aTargetBitRate[$i]}*${BitRateFactor}" | bc`
  done

}

#usage: run_GetTargetBitRate.sh  ${PicW} ${PicH} ${FPS} ${ConfigureFile}
runMain()
{
  if [ ! $# -eq 4 ]
  then
    echo "usage: run_GetTargetBitRate.sh  \${PicW} \${PicH} \${FPS} \${ConfigureFile} "
    return 1
  fi

  let "PicW = $1"
  let "PicH = $2"
  let "FPS  = $3"
  ConfigureFile=$4
  if [ ${PicW} -le 0 -o ${PicH} -le 0 -o ${FPS} -le 0 ]
  then
	echo ""
    echo "Picture info is not correct! please double check!"
	echo "usage: run_GetTargetBitRate.sh  \${PicW} \${PicH} \${FPS} \${ConfigureFile} "
	echo ""
	exit 1
  fi

  if [ ! -e ${ConfigureFile}  ]
  then
    echo ""
    echo "ConfigureFile ${ConfigureFile} does not exist! please double check!"
	echo "usage: run_GetTargetBitRate.sh  \${PicW} \${PicH} \${FPS} \${ConfigureFile} "
	echo ""
	exit 1
  fi

  runGlobalVariableInital
  runParseBRSetting  ${ConfigureFile}
  runGetTargetBitRate
  echo ${TargetBitrate[@]}

  return 0
}

PicWidth=$1
PicHeight=$2
FPS=$3
ConfigureFile=$4
runMain  ${PicWidth} ${PicHeight}  ${FPS}  ${ConfigureFile}





