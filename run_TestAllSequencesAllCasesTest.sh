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
    SGEJobListFile="SGEJobsSubmittedInfo.log"

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
    ./run_SGEJobSubmit.sh  ${AllTestDataDir} ${ConfigureFile} ${SGEJobListFile}
    if [ ! $? -eq 0 ]
    then
        echo -e "\033[31m usage: failed to summit SGE jobs \033[0m"
        exit 1

    fi

    #./run_SGEJobStatusUpdate.sh  ${SGEJobListFile}
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
                                              ${ConfigureFile}  AllCases   ${CasesFile}

        let "Flag = $?"

		#when test completed, generate flag file to avoid repeating test
		touch ${TestFlagFile}
		cd  ${CurrentDir}
	done
	
	return ${Flag}
	
}
 
runCheck()
{
    #check configure file
    [  ! -f ${ConfigureFile} ] && echo -e "\033[31m usage: ConfigureFile ${ConfigureFile} doest not exist,please double check \033[0m" && exit 1

	#check test type
    [ ! ${TestType} = "SGETest" ] && [ ! ${TestType} = "LocalTest" ] && runUsage && exit 1

	return 0
}

#usage: runMain  ${BitstreamDir} ${AllTestDataDir}  ${FinalResultDir}
runMain()
{
    declare -a aTestYUVList
	#check input parameters
	runCheck
    runGlobalInit

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

#************************************************************************************************************
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters is:"
echo "        $0 $@"
echo "*********************************************************"
echo ""
if [ ! $# -eq 4  ]
then
    runUsage
    exit 1
fi

TestType=$1
AllTestDataDir=$2
FinalResultDir=$3
ConfigureFile=$4

runMain
#************************************************************************************************************

