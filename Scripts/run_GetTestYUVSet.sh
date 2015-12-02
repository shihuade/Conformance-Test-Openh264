#!/bin/bash
#***************************************************************************************
# brief:
#      --get test test YUV name list from case configure file
#      --if input files are bit streams, transcode bit stream into YUV file
#        under folder under ${WorkdingDir}/BitStreamToYUV
# usage:
#      ./run_GetTestYUVSet.sh  ${CaseConfigureFile}
#
#      ----for case 0: input format is 0
#          input files are YUV, output test YUV name list only
#
#      ----for case 0: input format is 1
#           input files are bit stream,
#          --i) check that wheather all test bit stream are exist under given input dir
#          --ii)transcode bit stream into YUV, output YUV folder is
#               ${CurrentDir}/BitStreamToYUV
#          --iii) output transcode YUV name list
#
#
#date:  04/26/2014 Created
#***************************************************************************************

runInitial()
{
    declare -a aInputTestFileList
    declare -a aTestYUVList
    declare -a aBitStreamToYUVFlag
    declare -a aFailedTranscodedList

    TestSet0=""
    TestSet1=""
    TestSet2=""
    TestSet3=""
    TestSet4=""
    TestSet5=""
    TestSet6=""
    TestSet7=""
    TestSet8=""

    CurrentDir=`pwd`
    ScriptsDir="${CurrentDir}/Scripts"
    CodecDir="${CurrentDir}/Codec/h264dec"
    InputBitStreamDir=""
    BitStreamToYUVFolder="${CurrentDir}/BitStreamToYUV"
    BitStreamToYUVLog="${CurrentDir}/BitStreamToYUV.log"
    let "InputFileFormat = 0"
    let "FailedTranscodedNum=0"
    let "ReturnFlag=0"
    date >${BitStreamToYUVLog}

}

runParseInputSetting()
{
	while read line
	do
		if [[ "$line" =~ ^TestSet0  ]]
		then
			TestSet0=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet1  ]]
		then
			TestSet1=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet2  ]]
		then
			TestSet2=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet3  ]]
		then
			TestSet3=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet4  ]]
		then
			TestSet4=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet5  ]]
		then
			TestSet5=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet6  ]]
		then
			TestSet6=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet7  ]]
		then
			TestSet7=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `
		elif  [[ "$line" =~ ^TestSet8  ]]
		then
			TestSet8=`echo $line | awk 'BEGIN {FS="[#:\r]" } {print $2}' `

        elif [[ "$line" =~ ^InputFormat  ]]
        then
            TempString=`echo $line | awk 'BEGINE {FS=":"} {print $2}' `
            TempString=`echo $TempString | awk 'BEGIN {FS="#"} {print $1}' `
            let "InputFileFormat= ${TempString}"

        elif [[ "$line" =~ ^TestBitStreamDir  ]]
        then
            TempString=`echo $line | awk 'BEGINE {FS=":"} {print $2}' `
            TempString=`echo $TempString | awk 'BEGIN {FS="#"} {print $1}' `
            InputBitStreamDir="${TempString}"
        fi

    done <${ConfigureFile}

	aInputTestFileList=(${TestSet0}  ${TestSet1}  ${TestSet2}  ${TestSet3}  ${TestSet4}  ${TestSet5}  ${TestSet6}  ${TestSet7} ${TestSet8})


 }

runTranscodeBitStreamToYUV()
{

    if [ ! -d ${BitStreamToYUVFolder} ]
    then
        mkdir ${BitStreamToYUVFolder}
    fi

    let "i=0"

    for vInputFileName in ${aInputTestFileList[@]}
    do

        InputBitStreamFile=${InputBitStreamDir}/${vInputFileName}

        if [ ! -e ${InputBitStreamFile} ]
        then
            echo -e "\033[31m bit sream ${InputBitStreamFile}  does not exist,please double check! \033[0m"
            aBitStreamToYUVFlag[$i]="Transcoded Failed!--File not exist"
            aFailedTranscodedList[FailedTranscodedNum]=${InputBitStreamFile}
            let "FailedTranscodedNum ++"
            let "ReturnFlag=1"
        else
            ${ScriptsDir}/run_BitStreamToYUV.sh ${InputBitStreamFile} ${BitStreamToYUVFolder}  ${CodecDir}
            aBitStreamToYUVFlag[$i]="Transcoded Succed!"
        fi
        let "i ++"
    done
}

runOutputBitStreamTransCodeInfo()
{

    echo -e "\033[32m ********************************************************* \033[0m"
    echo -e "\033[32m Bit stream transcode to YUV detaile info list as below:   \033[0m"
    echo -e "\033[32m ********************************************************* \033[0m"
    for ((i=0;i<${#aInputTestFileList[@]};i++))
    do
        echo "${aInputTestFileList[$i]} : ${aBitStreamToYUVFlag[$i]} "
    done
    echo ""
    echo -e "\033[31m Total failed num         is:  ${FailedTranscodedNum}       \033[0m"
    echo -e "\033[31m Failed bit stream files are:  ${aFailedTranscodedList[@]}  \033[0m"
    echo ""
    echo -e "\033[32m TranscodeYUV list are: ${aTestYUVList[@]}                  \033[0m"
    echo -e "\033[32m ********************************************************* \033[0m"
}
runGetTranscodeYUVName()
{

    let " i=0"
    for file in ${BitStreamToYUVFolder}/*.yuv
    do

        vTempName=`echo ${file} | awk 'BEGIN {FS="/"} {print $NF}'`
        aTestYUVList[$i]=${vTempName}
        let " i ++"
   done
}

runCheck()
{
    if [ ${InputFileFormat} -eq 1 ]
    then

        if [ ! -d ${InputBitStreamDir} ]
        then
            echo -e "\033[31m Input bit stream dir does not exist,please double check! \033[0m"
            exit 1
        fi

        cd ${InputBitStreamDir}
        InputBitStreamDir=`pwd`
        cd ${CurrentDir}
    fi

}

runGetTestYUVList()
{

    if [ ${InputFileFormat} -eq 1 ]
    then
        runTranscodeBitStreamToYUV      >>${BitStreamToYUVLog}
        runGetTranscodeYUVName          >>${BitStreamToYUVLog}
        runOutputBitStreamTransCodeInfo >>${BitStreamToYUVLog}

    else
        aTestYUVList=( ${aInputTestFileList[@]})
    fi

}

runMain()
{

    if [ ! $# -eq 1  ]
    then
        echo -e "\033[31m usage: ./run_GetTestYUVSet.sh  \${CaseConfigureFile} \033[0m"
       exit 1
    fi

    ConfigureFile=$1

    if [ ! -e ${ConfigureFile} ]
    then
        echo -e "\033[31m  $1 doest noe exist. please double check! \033[0m"
        exit 1
    fi

    runInitial
    runParseInputSetting

    runGetTestYUVList

    echo ${aTestYUVList[@]}

    return ${ReturnFlag}

}

ConfigureFile=$1
runMain ${ConfigureFile}





