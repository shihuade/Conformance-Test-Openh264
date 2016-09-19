#!/bin/bash


#*************************************************************************************************
# brife:
#    As openh264 encoder's reconstructed YUV file is multiple of 16 even though the
#    input resolution is not multiple of 16. So, in order to make comparison between
#    JM decoded YUV and reconstructed YUV, we need to crop the reconstructed  YUV
#    first.
#
#  usage:
#         ----./run_CropYUV.sh  ${RecYUV} ${OutputYUV} ${EncodedWidth} ${EncodedHeight}
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
		let "RecYUVWidth=${EncodedWidth}   + 16 - ${PicWRemainder}"
	fi
	
	if [ ! ${PicHRemainder} -eq 0  ]
	then
		let "RecYUVHeight=${EncodedHeight} + 16 - ${PicHRemainder} "
	fi
	
	return 0
}

runCropYUV()
{

	local Command="./${Cropper} ${RecYUVWidth}  ${RecYUVHeight}  ${RecYUV}  \
					${EncodedWidth} ${EncodedHeight} ${OutputYUV} \
					-crop 0 0 0 ${EncodedWidth} ${EncodedHeight}" 
	
	echo ""
	echo "RecYUVWidth   is ${RecYUVWidth}"
	echo "RecYUVHeight  is ${RecYUVHeight}"
	echo "EncodedWidth  is ${EncodedWidth}"
	echo "EncodedHeight is ${EncodedHeight}"
	echo ""
	
	echo ${Command}
	echo ""
	
	./${Cropper} ${RecYUVWidth}  ${RecYUVHeight}  ${RecYUV}  \
	             ${EncodedWidth} ${EncodedHeight} ${OutputYUV} \
				 -crop 0 0 0 ${EncodedWidth} ${EncodedHeight}

	if [  $? -eq 0  -a  -s ${OutputYUV} ]
	then
		let "CropFlag=0"
	else
		let "CropFlag=1"
	fi
}

#usage:run_CropYUV.sh  ${RecYUV} ${OutputYUV} ${EncodedWidth} ${EncodedHeight}
runMain()
{

	if [ ! $# -eq 4 ]
	then
		echo ""
		echo "usage:run_CropYUV.sh  \${RecYUV} \${OutputYUV} \${EncodedWidth} \${EncodedHeight}"
		echo ""
		exit 2
	fi

	RecYUV=$1
	OutputYUV=$2
	EncodedWidth=$3
	EncodedHeight=$4
	Cropper="DownConvertStatic"
	
	let "RecYUVWidth=${EncodedWidth}"
	let "RecYUVHeight=${EncodedHeight}"
	
	let "CropFlag=1"
	
	runSetCropResolution
	[  ${CropFlag} -eq 0 ] && echo -e "\033[32m\n  YUV resolution is multiple of 16, no need to crop \n\033[0m" && return 1

	runCropYUV
	[  ! ${CropFlag} -eq 0 ] && echo -e "\033[32m\n   crop failed \n\033[0m" &&  return 2

    echo -e "\033[32m\n  crop succeed \n\033[0m"
    return 0
}

RecYUV=$1
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
runMain  ${RecYUV} ${OutputYUV} ${EncodedWidth} ${EncodedHeight}


