#!/bin/bash
#***************************************************************************************
# brief:
#      --test all cases of all sequences 
#      --usage:  run_AllBitStreamALlCasesTest  ${AllTestDataDir} \
#                                              ${FinalResultDir} \
#                                              ${ConfigureFile}
#
#
#date: 05/08/2014 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
	echo -e "\033[31m usage: ./run_AllTestSequencesAllCasesTest.sh   \${TestType}  \${AllTestDataDir}  \${FinalResultDir} \${ConfigureFile} \033[0m"
	echo -e "\033[31m       --eg:   ./run_AllTestSequencesAllCasesTest.sh  SGETest   AllTestData  FinalResult ./CaseConfigure/case.cfg \033[0m"
	echo -e "\033[31m       --eg:   ./run_AllTestSequencesAllCasesTest.sh  LocalTest AllTestData  FinalResult ./CaseConfigure/case.cfg \033[0m"
 	echo ""
 }
runGlobalInit()
{
    CurrentDir=`pwd`

    TestFlagFile=""
    SGEJobListFile="AllSGEJobsInfo.log"

    let "CurrentSGEJobNum=0"
    declare -a aTestYUVList

    #get full path info
    cd ${AllTestDataDir}
    AllTestDataDir=`pwd`
    cd  ${CurrentDir}
    cd ${FinalResultDir}
    FinalResultDir=`pwd`
    cd  ${CurrentDir}

}


runSGETest()
{
	local SGEQueneName="Openh264SGE"	
	
    ./run_SGEJobSubmit.sh        ${AllTestDataDir} ${ConfigureFile} ${SGEJobListFile}

    if [ ! $? -eq 0 ]
    then
        echo -e "\033[31m usage: failed to summit SGE jobs \033[0m"
        exit 1

    fi

    ./run_SGEJobStatusUpdate.sh  ${${SGEJobListFile}}
	
	return $?
	
}
runLocalTest()
{
	let "Flag=0"
	for TestYUV in ${aTestYUVList[@]}
	do
		SubFolder="${AllTestDataDir}/${TestYUV}"
		TestFlagFile="${TestYUV}_Tested.flag"
		if [ -e   ${SubFolder}/${TestFlagFile} ]
		then
			continue
		fi
		cd  ${SubFolder}
        CasesFile=${TestYUV}_AllCase.csv
		echo ""
		echo "test YUV is ${TestYUV}"
		echo ""
		./run_TestOneYUVWithAssignedCases.sh  ${TestType}      ${TestYUV}  ${FinalResultDir} \
                                              ${ConfigureFile} AllCases    ${CasesFile}
		if [  ! $? -eq 0 ]
		then
			echo -e "\033[31m not all test cases have been passed! \033[0m"
			let "Flag=1"
		fi
		#when test completed, generate flag file to avoid repeating test
		touch ${TestFlagFile}
		cd  ${CurrentDir}
	done
	
	return ${Flag}
	
}
 
runCheck()
{

    #check configure file
    if [  ! -f ${ConfigureFile} ]
    then
        echo -e "\033[31m usage: ConfigureFile ${ConfigureFile} doest not exist,please double check \033[0m"
        exit 1
    fi

	#check test type
	if [ ${TestType} = "SGETest" ]
	then
		return 0
	elif [ ${TestType} = "LocalTest" ]
	then
		return 0
	else
		 runUsage
		 exit 1
	fi

	return 0
}
#usage: runMain  ${BitstreamDir} ${AllTestDataDir}  ${FinalResultDir}
runMain()
{
	#parameter check!
	if [ ! $# -eq 4  ]
	then
		runUsage
		exit 1
	fi
	
	TestType=$1
	AllTestDataDir=$2
	FinalResultDir=$3
	ConfigureFile=$4
	#check input parameters
	runCheck

    #get YUV list
    aTestYUVList=(`./Scripts/run_GetTestYUVSet.sh  ${ConfigureFile}`)

	#Test
	if [ ${TestType} = "SGETest" ]
	then
		runSGETest
	elif [ ${TestType} = "LocalTest" ]
	then
		runLocalTest
	fi
	
	return $?
	
}
TestType=$1
AllTestDataDir=$2
FinalResultDir=$3
ConfigureFile=$4
runMain  ${TestType}  ${AllTestDataDir}  ${FinalResultDir} ${ConfigureFile}

