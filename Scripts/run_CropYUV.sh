#!/bin/bash


#*************************************************************************************************
# brife:
#    As openh264 encoder's reconstructed YUV file is multiple of 16 even though the
#    input resolution is not multiple 0f 16. So, in order to make comparison between
#    JM decoded YUV and reconstructed YUV, we need to crop the reconstructed  YUV
#    first.
#
#  usage:
#         ----./run_CropYUV.sh  ${InputYUV} ${OutputYUV} ${EncodedWidth} ${EncodedHeight}
#  return value:
#          0-->cropped succeed   1-->no need to crop, multiple of 16
#          2-->cropped failed
#  e.g:
#        input:  run_CropYUV.sh test_320X192.yuv test_320X180.yuv  320 180
#        output: test_320X180.yuv  with resolution of 320X180
#
#date:  5/08/2014 Created
#*************************************************************************************************
runSetCropResolution()
{

	let  "PicWRemainder= ${EncodedWidth}%16"
	let  "PicHRemainder= ${EncodedHeight}%16"
	
	if [  ${PicWRemainder} -eq 0 -a ${PicHRemainder} -eq 0 ]
	then
		let "CropFlag=0"
		return 0
	fi

	if [ ! ${PicWRemainder} -eq 0   ]
	then
		let "OriginWidth=${EncodedWidth}   + 16 - ${PicWRemainder}"
	fi
	
	if [ ! ${PicHRemainder} -eq 0  ]
	then
		let "OriginHeight=${EncodedHeight} + 16 - ${PicHRemainder} "
	fi
	
	return 0
}

runCropYUV()
{

	local Command="./${Cropper} ${OriginWidth}  ${OriginHeight}  ${InputYUV}  \
					${EncodedWidth} ${EncodedHeight} ${OutputYUV} \
					-crop 0 0 0 ${EncodedWidth} ${EncodedHeight}" 
	
	echo ""
	echo "OriginWidth   is ${OriginWidth}"
	echo "OriginHeight  is ${OriginHeight}"
	echo "EncodedWidth  is ${EncodedWidth}"
	echo "EncodedHeight is ${EncodedHeight}"
	echo ""
	
	echo ${Command}
	echo ""
	
	./${Cropper} ${OriginWidth}  ${OriginHeight}  ${InputYUV}  \
	             ${EncodedWidth} ${EncodedHeight} ${OutputYUV} \
				 -crop 0 0 0 ${EncodedWidth} ${EncodedHeight}

	if [  $? -eq 0  -a  -s ${OutputYUV} ]
	then
		let "CropFlag=0"
	else
		let "CropFlag=1"
	fi
}

#usage:run_CropYUV.sh  ${InputYUV} ${OutputYUV} ${EncodedWidth} ${EncodedHeight}
runMain()
{

	if [ ! $# -eq 4 ]
	then
		echo ""
		echo "usage:run_CropYUV.sh  \${InputYUV} \${OutputYUV} \${EncodedWidth} \${EncodedHeight}"
		echo ""
		exit 2
	fi

	InputYUV=$1
	OutputYUV=$2
	EncodedWidth=$3
	EncodedHeight=$4
	Cropper="DownConvertStatic"
	
	let "OriginWidth=${EncodedWidth}"
	let "OriginHeight=${EncodedHeight}"
	
	let "CropFlag=1"
	
	if [ ! -e ${InputYUV}  -o ! -s ${InputYUV} ]
	then
		echo ""	
		echo -e "\033[31m   input yuv file ${InputYUV} does not exist or the size is 0 bit! \033[0m"
		echo ""
		exit 2
	fi
	
	if [ ${EncodedWidth} -lt 4  -o  ${EncodedHeight} -lt 4  ]
	then
		echo ""
		echo -e "\033[31m   encoded width or encoded height is not correct, the value should be PicWXPicH>=4X4 \033[0m"
		echo ""
		exit 2
	fi
	
	runSetCropResolution
	if [  ${CropFlag} -eq 0 ]
	then
		echo ""
		echo -e "\033[32m   YUV resolution is multiple of 16 \033[0m"
		echo -e "\033[32m   no need to crop \033[0m"
		echo ""
		exit 1	
	fi
	
	runCropYUV
	if [  ${CropFlag} -eq 0 ]
	then
		echo ""
		echo -e "\033[32m   crop succeed \033[0m"
		echo ""
		exit 0	
	else
		echo ""
		echo -e "\033[31m   crop failed \033[0m"
		echo ""
		exit 2		
	fi

}

InputYUV=$1
OutputYUV=$2
EncodedWidth=$3
EncodedHeight=$4
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters are:"
echo "        $0 $@"
echo "*********************************************************"
echo ""
runMain  ${InputYUV} ${OutputYUV} ${EncodedWidth} ${EncodedHeight}


