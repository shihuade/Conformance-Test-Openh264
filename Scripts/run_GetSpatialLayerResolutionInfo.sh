
#!/bin/bash

#*****************************************************************************************************
# brief:  get actual spatial layer resolution based on actual spatial number
#
# usage:  input:   run_GetSpatialLayerResolutionInfo.sh $PicW $PicH  $SpatialNum $Multiple16Flag
#
#         output:   LayerWidth_0  LayerHeight_0  \
#                   LayerWidth_1  LayerHeight_1  \
#                   LayerWidth_2  LayerHeight_2  \
#                   LayerWidth_3  LayerHeight_3
#
#  e.g:
#         --input : 1280 720  4  1 ( 4 layer and align with 16)
#           output: 160  80  320  176  640  352 1280  720
#
#         --input : 1280 720  4  0 ( 4 layer and not align with 16)
#           output: 160  90  320  180  640  360 1280  720
#
#         --input : 1280 720  3  0 ( 3 layer and not align with 16)
#           output: 320  180 640  360 1280  720  0  0
#
#         --input : 1280 720  2  0 ( 2 layer and not align with 16)
#           output: 640  360 1280  720 0  0 0  0
#
#         --input : 1280 720  1  0 ( 1 layer and not align with 16)
#           output: 1280  720 0 0  0 0 0 0
#
#date:  5/08/2014 Created
#*****************************************************************************************************

runExtendMultiple16()
{
	local Num=$1
    let  "TempNum = ${Num} - ${Num}%16"

	echo "${TempNum}"
}

runMain()
{
	if [ $#  -lt 4  ]
	then
		echo "usage: run_GetSpatialLayerResolutionInfo.s  \$PicW \$PicH  \$SpatialNum \${Multiple16Flag}"
		exit  1
	elif [  $1 -le 0  -o $2 -le 0 -o $3 -gt 4 ]
	then
        echo "usage: run_GetSpatialLayerResolutionInfo.s  \$PicW \$PicH  \$SpatialNum \${Multiple16Flag}"
        echo "spatial layer number should be among 1~4"
		exit  1
	fi
	local PicW=$1
	local PicH=$2
	local SpatialNum=$3
	local Multiple16Flag=$4

	declare -a aLayerWidth
	declare -a aLayerHeight

	let "LayerWidth_0 = ${PicW}/8"
	let "LayerWidth_1 = ${PicW}/4"
	let "LayerWidth_2 = ${PicW}/2"
	let "LayerWidth_3 = ${PicW}"
	let "LayerHeight_0 = ${PicH}/8"
	let "LayerHeight_1 = ${PicH}/4"
	let "LayerHeight_2 = ${PicH}/2"
	let "LayerHeight_3 = ${PicH}"

	aLayerWidth=(  ${LayerWidth_0}  ${LayerWidth_1}  ${LayerWidth_2}  ${LayerWidth_3}  )
	aLayerHeight=( ${LayerHeight_0} ${LayerHeight_1} ${LayerHeight_2} ${LayerHeight_3} )

	if [ ${Multiple16Flag} -eq 1 ]
	then
		for((i=0;i<4;i++))
		do
			aLayerWidth[$i]=`runExtendMultiple16   ${aLayerWidth[$i]}`
			aLayerHeight[$i]=`runExtendMultiple16  ${aLayerHeight[$i]}`
		done
	fi

	#not: output format need to use whit space to separate each parameter
	if [ ${SpatialNum} -eq 4  ]
	then
		echo  "${aLayerWidth[0]}  ${aLayerHeight[0]}  ${aLayerWidth[1]}  ${aLayerHeight[1]}  ${aLayerWidth[2]}  ${aLayerHeight[2]} ${aLayerWidth[3]}  ${aLayerHeight[3]} "
	elif [ ${SpatialNum} -eq 3  ]
	then
		echo  "${aLayerWidth[1]}  ${aLayerHeight[1]} ${aLayerWidth[2]}  ${aLayerHeight[2]} ${aLayerWidth[3]}  ${aLayerHeight[3]}  0  0 "
	elif [ ${SpatialNum} -eq 2  ]
	then
		echo  "${aLayerWidth[2]}  ${aLayerHeight[2]} ${aLayerWidth[3]}  ${aLayerHeight[3]} 0  0 0  0"
	elif [ ${SpatialNum} -eq 1  ]
	then
		echo  "${aLayerWidth[3]}  ${aLayerHeight[3]} 0 0  0 0 0 0 "
	fi
	return 0
}
#****************************************************************************************************
PicW=$1
PicH=$2
SpatialNum=$3
Multiple16Flag=$4

runMain  ${PicW} ${PicH}  ${SpatialNum}  ${Multiple16Flag}
#****************************************************************************************************


