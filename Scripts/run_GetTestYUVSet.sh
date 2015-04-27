#!/bin/bash
#***************************************************************************************
# brief:
#      --get test YUV set from case configure file
# usage:
#      ./run_GetTestYUVSet.sh  ${CaseConfigureFile}
#
#date:  04/26/2014 Created
#***************************************************************************************


runGetTestYUVList()
{
	local TestSet0=""
	local TestSet1=""
	local TestSet2=""
	local TestSet3=""
	local TestSet4=""
	local TestSet5=""
	local TestSet6=""
	local TestSet7=""
	local TestSet8=""

    declare -a aTestYUVList
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
		fi
	done <${ConfigureFile}
	
	aTestYUVList=(${TestSet0}  ${TestSet1}  ${TestSet2}  ${TestSet3}  ${TestSet4}  ${TestSet5}  ${TestSet6}  ${TestSet7} ${TestSet8})

    echo ${aTestYUVList[@]}
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

    return 0

}

ConfigureFile=$1
runMain ${ConfigureFile}





