#!/bin/bash
#*************************************************************************
#brief:  used bit stream extractor from train's project.
#        and extract single layer spatial layer's bit stream 
#
#usage: run_ExtractLayerBitStream.sh  ${InputBitSteam}  \
#                         ${SpatialLayerNum} ${OutputBitStreamName[@]}
#
#
#date:  5/08/2014 Created
#*************************************************************************
#usage: run_ExtractLayerBitStream.sh  ${SpatialLayerNum} ${InputBitSteam}  ${OutputBitStreamName[@]}
runMain()
{
	if [  ! $# -eq 6  ]
	then
		echo ""
		echo "usage: run_ExtractLayerBitStream.sh   \${SpatialLayerNum} \${InputBitSteam} \${OutputBitStreamName[@]} "
		echo ""
		exit 1
	fi

	SpatialLayerNum=$1
	InputBitSteam=$2
    aOutputBitStreamNameList=( $3 $4 $5 $6)
	Extractor="extractor.app"


	let "ExtractFlag=0"
    if [ ${SpatialLayerNum} -eq 1 ]
    then
        cp ${InputBitSteam} ${aOutputBitStreamNameList[0]}
    else
        for((i=0;i<${SpatialLayerNum}; i++))
        do
            ./${Extractor}  ${InputBitSteam} ${aOutputBitStreamNameList[$i]}  -did $i 2>BitStreamExtract.log
            if [ ! $? -eq 0  -o  ! -e  ${aOutputBitStreamNameList[$i]} -o ! -s  ${aOutputBitStreamNameList[$i]} ]
            then
                let "ExtractFlag=1"
            fi
	    done
    fi

	if [ ${ExtractFlag} -eq 0 ]
	then
		echo ""
		echo -e "\033[32m  bit stream extraction succeed \033[0m"
		echo ""
		return 0
	else
		echo ""
		echo -e "\033[31m bit stream extraction failed \033[0m"
		echo ""
		return 1
	fi

}
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo "*********************************************************"
echo ""
runMain  $@


