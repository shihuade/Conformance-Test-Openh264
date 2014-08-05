#!/bin/bash

#*******************************************************************************
#brief:  get spatial layer number based on PicE and PicH
#
#usage:  run_GetSpatialLayerNum.sh  ${PicWidth} ${PicHeight}
#
#e.g:   --input:  run_GetSpatialLayerNum.sh  1280 720
#       --output: 4
#
#*******************************************************************************

#usage: runGetLayerNum  $PicW  $PicH
runGetLayerNum()
{

  if [ $#  -lt 2  ]
  then
    echo "usage: run_GetSpatialLayerNum.sh  \$PicW  \$PicH"
    exit  1
  elif [  $1 -le 0  -o $2 -le 0 ]
  then
    echo "usage: run_GetSpatialLayerNum.sh  \$PicW  \$PicH"
    exit  1
  fi

  local PicWidth=$1
  local PicHeight=$2

  let " TotalPixel= ${PicWidth} * ${PicHeight}"

  let "Flag_720P=1280*720"
  let "Flag_360P=480*360"
  let "Flag_180P=240*180"

  if [ ${TotalPixel} -ge ${Flag_720P} ]
  then
    let "LayerNum = 4 "
  elif [  ${TotalPixel} -ge ${Flag_360P} ]
  then
     let "LayerNum = 3 "
  elif [ ${TotalPixel} -ge ${Flag_180P}  ]
  then
	let "LayerNum = 2 "
  else
    let "LayerNum = 1 "
  fi

  echo ${LayerNum}

}
PicW=$1
PicH=$2
runGetLayerNum  ${PicW}  ${PicH}
