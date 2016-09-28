#!/bin/bash
#***********************************************************************************************
# brief: get spatial layer's test bit rate set base on actual spatial layer
#
#1.usage:   run_GetSpatialLayerBitRateSet.sh  $PicW  $PicH $FPS  $SpatialNum $ConfigureFile
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
#         --input : 1280 720  10  3  case.cfg (3 spatial layers)
#           output: (400 600 1000 0, 150 300 500 0)
#
#         --input : 1280 720  10  2  case.cfg (2 spatial layers)
#           output: (600 1000 0 0, 300 500 0 0)
#
#         --input : 1280 720  10  2  case.cfg (1 spatial layer)
#
#           output: (1000 0 0 0, 500 0 0 0)
#date:  5/08/2014 Created
#***********************************************************************************************

#******************************************************************************************
#calculate actual layers' resolution
#aSpatailResolution=(PicW_0 PicH_0  PicW_1 PicH_1 PicW_2 PicH_2 PicW_3 PicH_3  )
#   input:   run_GetSpatialLayerResolutionInfo.sh $PicW $PicH  $SpatialNum $Multiple16Flag
#   eg:   --input :  1280 720  3  0                     ( 3 layer without align with 16)
#         --output:  320  180  640  360 1280  720  0  0
#aSpatailResolution=(320  180  640  360 1280  720  0  0)
#******************************************************************************************
runGetActualLayerResolution()
{
    aSpatailResolution=( `./run_GetSpatialLayerResolutionInfo.sh  $PicW $PicH  ${SpatialNum}  ${Multiple16Flag}` )
}

runGetLayrBRPoint()
{
    #get layer's test bit rate point based on configure file
    #eg:  1280*720, 3 layer, aSpatailResolution=(320  180  640  360 1280  720  0  0)
    #         aTestBRPointLayer0=(400  150)   aTestBRPointLayer1=(600  300)
    #         aTestBRPointLayer2=(1000  500)  aTestBRPointLayer3=(0    0)
    aTestBRPointLayer0=(`./run_GetTargetBitRate.sh  ${aSpatailResolution[0]} ${aSpatailResolution[1]} ${FPS} ${ConfigureFile} `)
    aTestBRPointLayer1=(`./run_GetTargetBitRate.sh  ${aSpatailResolution[2]} ${aSpatailResolution[3]} ${FPS} ${ConfigureFile} `)
    aTestBRPointLayer2=(`./run_GetTargetBitRate.sh  ${aSpatailResolution[4]} ${aSpatailResolution[5]} ${FPS} ${ConfigureFile} `)
    aTestBRPointLayer3=(`./run_GetTargetBitRate.sh  ${aSpatailResolution[6]} ${aSpatailResolution[7]} ${FPS} ${ConfigureFile} `)
}

#******************************************************************************************
# example:
# for 1280*720, 3 layer cases;
#   aTestBRPointLayer0=(400  150)  aTestBRPointLayer1=(600  300)
#   aTestBRPointLayer2=(1000  500) aTestBRPointLayer3=(0    0)
#
#   aFinalTestBRSet=(400 600 1000 0, 150 300 500 0)
#******************************************************************************************
runGenerateTestBRSet()
{
    BRPonitNum=${#aTestBRPointLayer3[@]}
    BRPointForAllLayer=""
    FinalTestBRSet=""

    for ((i=0;i<${BRPonitNum}; i++))
    do
        BRPointForAllLayer="${aTestBRPointLayer0[$i]}  ${aTestBRPointLayer1[$i]}  ${aTestBRPointLayer2[$i]}  ${aTestBRPointLayer3[$i]}"
        FinalTestBRSet="${FinalTestBRSet} ${BRPointForAllLayer}, "
    done

    echo ${FinalTestBRSet}
}

runOutputTempData()
{
    echo ""
    echo "Spatial resolution is :"
    echo "${aSpatailResolution[@]}"
    echo ""

    echo ""
    echo "BR matric is:"
    echo ${aTestBRPointLayer0[@]}
    echo ${aTestBRPointLayer1[@]}
    echo ${aTestBRPointLayer2[@]}
    echo ${aTestBRPointLayer3[@]}
    echo ""
    echo ""
    echo "BR matric is:"
    echo ${aTestBRPointLayer0[0]}
    echo ${aTestBRPointLayer1[0]}
    echo ${aTestBRPointLayer2[0]}
    echo ${aTestBRPointLayer3[0]}
    echo ""
    echo ""
    echo "BR matric is:"
    echo ${aTestBRPointLayer0[1]}
    echo ${aTestBRPointLayer1[1]}
    echo ${aTestBRPointLayer2[1]}
    echo ${aTestBRPointLayer3[1]}
    echo ""
}

runInitAndInputCheck()
{
    declare -a aSpatailResolution
    declare -a aTestBRPointLayer0
    declare -a aTestBRPointLayer1
    declare -a aTestBRPointLayer2
    declare -a aTestBRPointLayer3

    [ ${PicW} -le 0 ]         || [ ${PicH} -le 0 ] || [ ${FPS} -le 0 ] && echo "resolution and fps invalid input" && exit 1
    [ ${SpatialNum} -le 0 ]   || [ ${SpatialNum} -gt 4 ] && echo "spatital num invalid" && exit 1
    [ ! -e ${ConfigureFile} ] && echo "cfg file does not exist!" && exit 1
}

#usage:   runMain  $PicW  $PicH $FPS  $SpatialNum $ConfigureFile
runMain()
{

    runInitAndInputCheck
    runGetActualLayerResolution
    runGetLayrBRPoint

    #generate
    runGenerateTestBRSet

    #runOutputTempData
}
#**********************************************************************************************************************************
if [ ! $#  -eq  6 ]
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
runMain
#**********************************************************************************************************************************


