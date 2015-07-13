
#!/bin/bash
#usage:  run_ParseDecoderInfo   $Decoder_LogFile  
#eg:     input:    run_ParseDecoderInfo   test.264.log
#        output    1024  720  
run_ParseDecoderInfo()
{
	if [ ! $# -eq 1 ]
	then
		echo "usage:  run_ParseDecoderInfo  \$Decoder_LogFile"
		return 1
	fi
	local LogFile=$1
	local Width=""
	local Height=""
    local FrameNum=""
	while read line
	do
		if [[  $line =~  "iWidth"   ]]
		then
			Width=`echo $line | awk 'BEGIN  {FS="[:\n]"} {print $2}'`
		elif [[  $line =~  "height"   ]]
		then
		   Height=`echo $line | awk 'BEGIN  {FS="[:\n]"} {print $2}'`
        elif [[  $line =~  "Frames"   ]]
        then
            FrameNum=`echo $line | awk 'BEGIN  {FS="[:\n]"} {print $2}'`
        fi
	done < ${LogFile}
	echo "${Width}  ${Height} ${FrameNum}"
}
#usage: run_BitStream2YUV  $BitstreamName  $OutputYUVName $LogFile 
run_BitStream2YUV()
{
 	if [ ! $# -eq 3 ]
	then
		echo "usage: run_BitStream2YUV  \$BitstreamName \$OutputYUVName \$LogFile   "
		return 1
	fi
	local BitStreamName=$1
	local OutputYUVNAMe=$2
	local LogFile=$3
	
	if [ ! -f ${BitStreamName}  ]
	then
		echo "bit stream file is not exist!"
		echo "detected by run_BitStreamToYUV.sh"
		return 1
	fi
	#decode bitstream
	${Decoder}  ${BitStreamName}  ${OutputYUVNAMe} 2> ${LogFile}
	
	return 0
}
#usage: run_RegularizeYUVName $BitstreamName $OutputYUVName $LogFile 
run_RegularizeYUVName()
{
 	if [ ! $# -eq 3 ]
	then
		echo "usage: run_RegularizeYUVName  \$BitstreamName  \$OutputYUVName \$LogFile "
		return 1
	fi
	local BitStreamName=$1
	local OrignName=$2
	local LogFile=$3
	local RegularizedYUVName=""
	 
	declare -a aDecodedYUVInfo	
	aDecodedYUVInfo=(`run_ParseDecoderInfo  ${LogFile}`)
	
	RegularizedYUVName="${BitStreamName}_${aDecodedYUVInfo[0]}x${aDecodedYUVInfo[1]}_FrNum_${aDecodedYUVInfo[1]}.yuv"
    NewYUVFileName="${OutputDir}/${RegularizedYUVName}"
	
    mv -f 	${OrignName}   ${NewYUVFileName}


	echo ""
	echo "file :  ${OrignName}   has been renamed as :${NewYUVFileName}"
    echo "OutputYUVName is ${RegularizedYUVName}"
    echo "OutputYUVDir is  ${NewYUVFileName}"
	echo ""
	
	return 0
}
#usage: runMain  ${BitStreamFile}  ${OutputDir} ${Decoder}
runMain()
{
	if [ ! $# -eq 3 ]
	then
		echo "usage: runMain  \${BitStreamFile}  \${OutputDir} \${Decoder} "
		return 1
	fi
	
	
	BitStreameFile=$1
	OutputDir=$2
	Decoder=$3
	if [ ! -e ${BitStreameFile} ]
	then
		echo -e "\033[31m bit stream file does not exist! please double check! \033[0m"
		echo -e "\033[31m   ----bit steam file:${BitStreameFile}  \033[0m"
		return 1
	fi
	
	if [ ! -d  ${OutputDir} ]
	then
		echo -e "\033[31m YUV folder for bitstream does not exist! \033[0m"
		return 1
	else
		CurrDir=`pwd`
		cd ${OutputDir}
		OutputDir=`pwd`
		cd ${CurrDir}
	fi
	BitSteamName=`echo ${BitStreameFile} | awk 'BEGIN {FS="/"} {print $NF}'`
	DecodeLogFile="${OutputDir}/${BitSteamName}_h264dec.log"
	DecodedYUVName="${OutputDir}/${BitSteamName}_dec.yuv"
	RegularizedName=""
	
	#**********************
	#decoded test bitstream
	run_BitStream2YUV  ${BitStreameFile}  ${DecodedYUVName}  ${DecodeLogFile}
	if [  ! $?  -eq 0  ]
	then
	    echo "bit stream decoded  failed!"
		return 1
	fi
	
	
	#*********************
	#regularized  YUV name
	run_RegularizeYUVName  ${BitSteamName}  ${DecodedYUVName}  ${DecodeLogFile}
   
	return 0
}
BitStreamFile=$1
OutputDir=$2
Decoder=$3
runMain  ${BitStreamFile}  ${OutputDir} ${Decoder}

