#!/bin/bash

#*********************************************************************************************
#brief:
#  --for input YUV preparation
#        1). calculate input layer size based on encoded frame num(size in byte);
#        2). change YUV's resolution and crop it to be multiple of 16 if Multiple16Flag==1
#
#  usage: ./run_PrepareInputYUV.sh  ${OutputDir}      ${InputYUV}      ${LogFileName}
#                                             ${Multiple16Flag} ${EncodedFrmNum}
#  --eg:
#    input:  run_PrepareInputYUV.sh  /opt/GuanYUn ../../ABC_1080X720_30fps.yuv  prepare.log
#                                              1  30
#             Multiple16Flag=1; EncodedFrmNum=30
#    output: there will be tow down sample YUV generated under /opt/GuanYu/
#            1). layer0_Size=1080*720 *12bit/pixel * 30Frms /8 (byte)
#                layer1_Size=540*360  *12bit/pixel * 30Frms /8 (byte)
#                layer2_Size=270*180  *12bit/pixel * 30Frms /8 (byte)
#
#             2) as all layer is multiple of 16, no need to crop and change layer resolution
#
#  --note: YUV name must be named as XXX_PicWxPicH_FPSxxxx.yuv
#
#date:  5/08/2014 Created
#*********************************************************************************************
#usage: runGlobalVariableInitial ${OriginYUV}
runGlobalVariableInitial()
{
	OriginYUVName=""
	OriginWidth=""
	OriginHeight=""

	DownSampleExe="DownConvertStatic"

    NumberLayer=1
    aLayerWidth=(0 0 0 0)
    aLayerHeight=(0 0 0 0)
    aYUVSize=(0 0 0 0)
}

runGetOriginYUVInfo()
{
    OriginYUVName=`echo ${OriginYUV} | awk 'BEGIN  {FS="/"} {print $NF}'`
    aYUVInfo=(`./run_ParseYUVInfo.sh  ${OriginYUVName}`)

    OriginWidth=${aYUVInfo[0]}
    OriginHeight=${aYUVInfo[1]}
    if [  ${OriginWidth} -eq 0  -o ${OriginHeight} -eq 0 ]
    then
        echo "origin YUV info is not right, PicW or PicH equal to 0 "
        exit 1
    fi

    OriginYUVSize=`ls -l ${OriginYUV} | awk '{print $5}'`
    #size in bytes
    let "FrameSize = $OriginWidth * ${OriginHeight} * 12 / 8"
    let "MaxFrameNum=${OriginYUVSize}/ $FrameSize"

    #overwrite encoded frame num for special resolition,which the same with run_GenerateCase.sh
    [ ${OriginWidth} -gt 320 ] && [ ${OriginWidth} -le 640 ] && EncodedFrmNum=100
}

runCheckEncodedFrameNum()
{
    if [ ${EncodedFrmNum} -gt ${MaxFrameNum} ]
    then
        echo "EncodedFrmNum(${EncodedFrmNum}) in test is larger than MaxFrameNum(${MaxFrameNum})"
        echo "now change actual encoded frame num to MaxFrameNum(${MaxFrameNum})"
        let "EncodedFrmNum = ${MaxFrameNum}"
    fi
}

runSetLayerInfo()
{
    aLayerWidth=(0 0 0 0)
    aLayerHeight=(0 0 0 0)
    aYUVSize=(0 0 0 0)

    NumberLayer=`./run_GetSpatialLayerNum.sh ${OriginWidth} ${OriginHeight}`

    #layer resolution for laye0,layer1,layer2,layer3 is the same with case setting,
    #please refer to run_GenerateCase.sh
    #eg. Multiple16Flag=0; OriginHeight=720  then aLayerHeight=(90 180 360 720)
    #    Multiple16Flag=1; OriginHeight=720  then aLayerHeight=(80 176 352 720)

    for((i=0;i<${NumberLayer};i++))
    do
        let "factor  = 2 ** (${NumberLayer} -1 - $i)"
        let "aLayerWidth[$i]  = OriginWidth  / factor"
        let "aLayerHeight[$i] = OriginHeight / factor"

        if [ ${Multiple16Flag} -eq 1  ]
        then
            let  "aLayerWidth[$i]  = ${aLayerWidth[$i]}  - ${aLayerWidth[$i]}  % 16"
            let  "aLayerHeight[$i] = ${aLayerHeight[$i]} - ${aLayerHeight[$i]} % 16"
        fi

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

        #get layer size, this info is need for RecYUV layersize comparison
        # to check wheather layer encoded YUV size is equal to rec YUV size
        # eg. resolution=1080*720,encoded_frm_num=30
        # then, encoded_layer_size=1080*720*12bit/piexl*30Frms / 8 (Bytes)
        let "aYUVSize[i] = ${aLayerWidth[$i]} * ${aLayerHeight[$i]} * ${EncodedFrmNum} * 12 / 8"
	done
}

runPrepareInputYUV()
{
    let "CropYUVFlag = 0"
    [ ! ${OriginWidth}  -eq ${aLayerWidth[$NumberLayer-1]}   ]  &&  let "CropYUVFlag = 1"
    [ ! ${OriginHeight} -eq ${aLayerHeight[$NumberLayer -1]} ] &&  let "CropYUVFlag = 1"

    if [ ${CropYUVFlag} -eq 1 ]
    then
        #rename new input yuv file due to resolution change
        NewInputYUVName=`./run_RenameYUVfileWithNewResolution.sh ${OriginYUVName} ${aLayerWidth[$NumberLayer-1]} ${aLayerHeight[$NumberLayer-1]}`
        if [ -e ${OutPutDir}/${NewInputYUVName} ]
        then
            ./run_SafeDelete.sh  ${OutPutDir}/${NewInputYUVName}
        fi

        if [ ! -e ${DownSampleExe} ]
        then
            echo "${DownSampleExe} does not exist! please double check! "
            let  "PrepareFlag=1"
            exit 1
        fi

        RunCommand="./${DownSampleExe} ${OriginWidth} ${OriginHeight} ${OriginYUV} ${aLayerWidth[$NumberLayer-1]} ${aLayerHeight[$NumberLayer-1]} ${OutPutDir}/${NewInputYUVName}"
        echo "new input YUV name after croped is ${OutPutDir}/${NewInputYUVName}"
        echo "RunCommand is ${RunCommand}"
        ${RunCommand}
        if [ ! $? -eq 0 ]
        then
            let "PrepareFlag=1"
        fi
    else
        NewInputYUVName=${OriginYUVName}
        cp -f ${OriginYUV} ${OutPutDir}/${NewInputYUVName}
    fi

}

#usage:runOutputPrepareLog
runOutputPrepareLog()
{
    #log looks like:
    #*****************************************************
    #InputYUV:      horse_riding_640x512_30.yuv
    #OriginYUVSize: 314572800
    #MaxFrameNum  : 640
    #NumberLayer:   3
    #EncodedFrmNum: 100
    #LayerPicW_0:   160
    #LayerPicH_H_0: 128
    #LayerSize_0:   3072000
    #LayerPicW_1:   320
    #LayerPicH_H_1: 256
    #LayerSize_1:   12288000
    #LayerPicW_2:   640
    #LayerPicH_H_2: 512
    #LayerSize_2:   49152000
    #LayerPicW_3:   0
    #LayerPicH_H_3: 0
    #LayerSize_3:   0
    #*****************************************************

    echo ""
    echo "InputYUV:      ${NewInputYUVName}"
    echo "OriginYUVSize: $OriginYUVSize"
    echo "MaxFrameNum  : $MaxFrameNum"
    echo "NumberLayer:   ${NumberLayer}"
    echo "EncodedFrmNum: ${EncodedFrmNum}"

    for ((i=0; i<4; i++ ))
	do
        echo "LayerPicW_${i}:   ${aLayerWidth[$i]}"
        echo "LayerPicH_H_${i}: ${aLayerHeight[$i]}"
        echo "LayerSize_${i}:   ${aYUVSize[$i]}"
	done
}

runCheckParm()
{
    if [ ! -f ${OriginYUV}  ]
    then
        echo "origin yuv does not exist! please double check!--${OriginYUV}"
        exit 1
    fi

    if [ ! -d  ${OutPutDir} ]
    then
        echo "output directory does not exist! please double check!--${OriginYUV}"
        exit 1
    fi

}
#usage: run_PrepareInputYUV.sh ${OriginYUV} ${PrepareLog} ${Multiple16Flag}
runMain()
{
	let "PrepareFlag=0"
	runGlobalVariableInitial
    runCheckParm

    runGetOriginYUVInfo
    runCheckEncodedFrameNum

	runSetLayerInfo
    runPrepareInputYUV
	if [ ! ${PrepareFlag} -eq 0 ]
	then
		echo -e "\033[31m\n  input YUV preparation failed! \n\033[0m"
		exit 1
	fi

	runOutputPrepareLog >${PrepareLog}
    cat ${PrepareLog}
    echo -e "\033[32m\n  input YUV preparation succeed! \n\033[0m"

	return 0
}
#******************************************************************
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo "*********************************************************"
echo ""

if [ ! $# -eq 5 ]
then
    echo -e "\033[32m usage: run_PrepareInputYUV.sh \${OutPutDir} \${OriginYUV} \${PrepareLog} \${Multiple16Flag} \${EncodedFrmNum} \n\033[0m"
    exit 1
fi

OutPutDir=$1
OriginYUV=$2
PrepareLog=$3
Multiple16Flag=$4
EncodedFrmNum=$5
runMain
