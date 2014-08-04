#!/bin/bash
#***********************************************************************************************
#    1.usage:   run_GetSpatialLayerBitRateSet.sh  $PicW  $PicH $FPS  $SpatialNum $ConfigureFile
#      output:  ("LayerBRSet0", "LayerBRSet1",...)
#
#    2.e.g: 
#         --if in configure file case.cfg, test bit rate point list as below:(kbps for FPS=10)
#             1). 1280X720: 1000  500
#             2). 640X360:  600   300
#             3). 320X180:  400   150
#             4). 160X90:   200   60
#
#         --input : 1280 720  10  4  case.cfg (4 spatial layers)
#           output: (200 400 600 1000, 60 150 300 500)
#
#         --input : 1280 720  10  4  case.cfg (3 spatial layers)
#           output: (400 600 1000 0, 150 300 500 0)
#
#         --input : 1280 720  10  2  case.cfg (2 spatial layers)
#           output: (600 1000 0 0, 300 500 0 0)
#
#         --input : 1280 720  10  2  case.cfg (1 spatial layer)
#           output: (1000 0 0 0, 500 0 0 0)
#***********************************************************************************************
#usage: runGetLayerBR ${TopLayerBRIndex} ${SpatialLayerNum} $LayerIndex 
#     
#e.g:   1. input: runGetLayerBR  0  4  2   output: 600  (0->1000kbps)
#e.g:   2. input: runGetLayerBR  0  4  1   output: 400
#e.g:   3. input: runGetLayerBR  0  4  0   output: 200     
#e.g:   3. input: runGetLayerBR  1  3  0   output: 150  (1->500kbps)
runGetLayerBR()
{
  if [ ! $#  -eq  3  ]
  then
    echo "usage:  runGetLayerBR \${TopLayerBRIndex} \${SpatialLayerNum} \$LayerIndex "
    exit  1
  elif [ $1 -lt 0  -o $2 -le 0  -o $3 -lt 0   ]
  then
    echo "usage:  runGetLayerBR \${TopLayerBRIndex} \${SpatialLayerNum} \$LayerIndex "
    exit  1
  fi
  
  local TopLayerBRIndex=$1
  local SpatialLayerNum=$2
  local LayerIndex=$3  
  local NumBRPoint=""
  declare -a aLayerBitRate
  
  let "LayerBRSetIndex = 4 - ${SpatialLayerNum} + ${LayerIndex} "
  
  if [  ${LayerBRSetIndex} -lt 0 -o ${LayerBRSetIndex} -gt 3  ]
  then
    echo "Layer index and spatial number are not corret, please double check!"
	exit 1
  fi
  if [ ${LayerBRSetIndex} -eq 0 ]
  then
    aLayerBitRate=(${aTestBRPointForLayer0[@]})
  elif [ ${LayerBRSetIndex} -eq 1 ]
  then
    aLayerBitRate=(${aTestBRPointForLayer1[@]})
  elif [ ${LayerBRSetIndex} -eq 2 ]
  then
    aLayerBitRate=(${aTestBRPointForLayer2[@]})
  elif [ ${LayerBRSetIndex} -eq 3 ]
  then
    aLayerBitRate=(${aTestBRPointForLayer3[@]})
  fi
  
  let "NumBRPoint = ${#aLayerBitRate[@]} "
  if [ ${TopLayerBRIndex} -lt ${NumBRPoint} ]
  then
    echo  ${aLayerBitRate[${TopLayerBRIndex}]}
  else
    echo  ${aLayerBitRate[${NumBRPoint}]}
  fi
}
#usage: runGenerateTestBRSet
#out generate final test bit rate point set
runGenerateTestBRSet()
{
 local TopLayerBRPonitNum=${#aTestBRPointForLayer3[@]}
 local AllLayerBR=""
 local TempLayerBR=""
 declare -a aFinaleTestBRSet
 
 for ((i=0;i<${TopLayerBRPonitNum}; i++))
 do
    AllLayerBR=""
   
   for ((j=0; j<4; j++))
   do
     if [ $j -lt  ${SpatialNum} ]
     then
       TempLayerBR=`runGetLayerBR ${i} ${SpatialNum} ${j}`
     else
       TempLayerBR="0"
     fi
   
     AllLayerBR="${AllLayerBR} ${TempLayerBR} " 
   done 
   
   aFinaleTestBRSet[$i]="${AllLayerBR}, " 
 done
 
 echo ${aFinaleTestBRSet[@]}
 
}
runOutputTempData()
{
  
  echo ""
  echo "Spatial resolution is :"
  echo "${aSpatailResolution[@]}"
  echo ""
  
  echo ""
  echo "BR matric is:"
  echo ${aTestBRPointForLayer0[@]}
  echo ${aTestBRPointForLayer1[@]}
  echo ${aTestBRPointForLayer2[@]}
  echo ${aTestBRPointForLayer3[@]}
  echo ""
  echo ""
  echo "BR matric is:"
  echo ${aTestBRPointForLayer0[0]}
  echo ${aTestBRPointForLayer1[0]}
  echo ${aTestBRPointForLayer2[0]}
  echo ${aTestBRPointForLayer3[0]}
  echo ""
  echo ""
  echo "BR matric is:"
  echo ${aTestBRPointForLayer0[1]}
  echo ${aTestBRPointForLayer1[1]}
  echo ${aTestBRPointForLayer2[1]}
  echo ${aTestBRPointForLayer3[1]}
  echo ""  
}
#usage:   runMain  $PicW  $PicH $FPS  $SpatialNum $ConfigureFile
runMain()
{
  if [ ! $#  -eq  6 ]
  then
    echo "usage: run_GetSpatialLayerBitRateSet.sh  \$PicW  \$PicH \$FPS  \$SpatialNum \$ConfigureFile \$Multiple16Flag"
    exit  1
  elif [  $1 -le 0  -o $2 -le 0  -o $3 -le 0  -o $4 -le 0 ]
  then
    echo "usage: run_GetSpatialLayerBitRateSet.sh  \$PicW  \$PicH \$FPS  \$SpatialNum \$ConfigureFile \$Multiple16Flag"
    exit  1
  fi
  
  PicW=$1
  PicH=$2
  FPS=$3
  SpatialNum=$4
  ConfigureFile=$5
  Multiple16Flag=$6
  declare -a aSpatailResolution
  declare -a aTestBRPointForLayer0
  declare -a aTestBRPointForLayer1
  declare -a aTestBRPointForLayer2
  declare -a aTestBRPointForLayer3
  
  #calculate 4 layers' resolution
  #aSpatailResolution=(PicWLayer_0 PicHLayer_0  PicWLayer_1 PicHLayer_1 PicWLayer_2 PicHLayer_2 PicWLayer_3 PicHLayer_3  )
  aSpatailResolution=( `./run_GetSpatialLayerResolutionInfo.sh  $PicW $PicH  4  ${Multiple16Flag}` )
  #get layer's test bit rate point based on configure file
  aTestBRPointForLayer0=(`./run_GetTargetBitRate.sh  ${aSpatailResolution[0]} ${aSpatailResolution[1]} ${FPS} ${ConfigureFile} `)
  aTestBRPointForLayer1=(`./run_GetTargetBitRate.sh  ${aSpatailResolution[2]} ${aSpatailResolution[3]} ${FPS} ${ConfigureFile} `)
  aTestBRPointForLayer2=(`./run_GetTargetBitRate.sh  ${aSpatailResolution[4]} ${aSpatailResolution[5]} ${FPS} ${ConfigureFile} `)
  aTestBRPointForLayer3=(`./run_GetTargetBitRate.sh  ${aSpatailResolution[6]} ${aSpatailResolution[7]} ${FPS} ${ConfigureFile} `)
   
  #generate 
  runGenerateTestBRSet
}
PicW=$1
PicH=$2
FPS=$3
SpatialNum=$4
ConfigureFile=$5
Multiple16Flag=$6
runMain  ${PicW}  ${PicH} ${FPS}  ${SpatialNum} ${ConfigureFile} ${Multiple16Flag}


