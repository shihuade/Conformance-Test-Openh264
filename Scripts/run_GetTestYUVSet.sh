#!/bin/bash
#***************************************************************************************
# brief:
#      --get test test YUV name list from case configure file
#      --if input files are bit streams, transcode bit stream into YUV file
#        under folder under ${WorkdingDir}/BitStreamToYUV
# usage:
#      ./run_GetTestYUVSet.sh  ${CaseConfigureFile}
#
#date:  04/26/2014 Created
#***************************************************************************************

runInitial()
{
    declare -a aInputTestFileList
    declare -a aTestYUVList

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
    InputBitStreamDir=""
    BitStreamToYUVFolder="BitStreamToYUV"
    let "InputFileFormat = 0"

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
            InputBitStreamDir= ${TempString}
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

    runGetTestYUVList

    echo ${aTestYUVList[@]}

    return 0

}

ConfigureFile=$1
runMain ${ConfigureFile}





