
#!/bin/bash
#***************************************************************************************
# brief:
#      --start point of the test.
#      --before run this script,
#          i) you need to update you codec  in folder ./Codec
#          ii) change you configure file if you do not use the default test case
#      --usage: refer to function runUsage()
# 
#      --for more detail,please refer to README.md
#
#
#date:  5/08/2014 Created
#***************************************************************************************
 runUsage()
 {
    echo -e "\033[32m ************************************************************************** \033[0m"
	echo -e "\033[31m   usage: ./run_Main.sh    \$TestType  \$ConfigureFile                      \033[0m"
	echo -e "\033[31m       --eg:   ./run_Main.sh  SGETest    ./CaseConfigure/case.cfg           \033[0m"
	echo -e "\033[31m       --eg:   ./run_Main.sh  LocalTest  ./CaseConfigure/case.cfg           \033[0m"
    echo -e "\033[32m or                                                                         \033[0m"
    echo -e "\033[32m ************************************************************************** \033[0m"
    echo -e "\033[31m   usage: ./run_Main.sh  \$TestType       \$ConfigureFile                   \033[0m"
    echo -e "\033[31m                         \$OpenH264Branch \$OpenH264Repos                   \033[0m"
    echo -e "\033[31m                         \$SourceFolder   \$ReposUpdateOption               \033[0m"
    echo -e "\033[32m ************************************************************************** \033[0m"
    echo -e "\033[31m       --last four parameters are optional                                  \033[0m"
    echo -e "\033[31m         which used to overwrite value in configure file                    \033[0m"
    echo -e "\033[31m       --ReposUpdateOption: fast or colone                                  \033[0m"
    echo -e "\033[31m         ----fast:  update repos via git pull only                          \033[0m"
    echo -e "\033[31m         ----clone: clone a new repos                                       \033[0m"
    echo -e "\033[32m ************************************************************************** \033[0m"
 }
 
runGetFinalTestResult()
{
    #check test type
    if [ ${TestType} = "SGETest" ]
    then
        echo -e "\033[32m ********************************************************************************************\033[0m"
        echo -e "\033[32m     please run below command to check whether all SGE jobs have been completed!             \033[0m"
        echo -e "\033[32m       ./run_SGEJobStatusUpdate.sh  SGEJobsSubmittedInfo.log ${AllJobsCompletedFlagFile} \n\n\033[0m"
        echo -e "\033[32m     please run below command to get final result when all SGE jobs have been completed!     \033[0m"
        echo -e "\033[32m       ./run_GetAllTestResult.sh  ${TestType}  ${ConfigureFile} ${AllTestResultPassFlag} \n\n\033[0m"
        echo -e "\033[32m ********************************************************************************************\033[0m"
        return 0
    elif [ ${TestType} = "LocalTest" ]
    then
        ./run_GetAllTestResult.sh  ${TestType}  ${ConfigureFile} ${AllTestResultPassFlag}
        let "AllTestFlag =$?"
    fi
}

runCheck()
{
	#check test type
	[ ! ${TestType} = "SGETest" ] && [ ! ${TestType} = "LocalTest" ] && runUsage && exit 1
	
	#check configure file
	[  ! -f ${ConfigureFile} ] && echo "Configure file ${ConfigureFile} does not exist!, please double check" && runUsage && exit 1

    return 0
}

runMain()
 {
	runCheck
	
	#dir translation
	AllTestDataFolder="AllTestData"
	CodecFolder="Codec"
	ScriptFolder="Scripts"
	SHA1TableFolder="SHA1Table"
	ConfigureFolder="CaseConfigure"
	FinalResultDir="FinalResult"
    AllJobsCompletedFlagFile="AllSGEJobsCompleted.flag"
    AllTestResultPassFlag="AllCasesPass.flag"

    #default is Source, will be overwrite by input value
    #SourceFolder="Source"

    let "AllTestFlag =0"
    echo -e "\033[32m **************************************************************************\033[0m"
    echo -e "\033[32m   prepare for all test data.......                                        \033[0m"
    echo -e "\033[32m **************************************************************************\033[0m"
   ./run_PrepareAllTestData.sh   ${TestType} ${ConfigureFile} ${OpenH264Branch} "${OpenH264Repos}" ${SourceFolder} ${CodecUpdateOption}
	if [ ! $? -eq 0 ]
	then
		echo "failed to prepared  test space for all test data!"
		exit 1
	fi

    echo -e "\033[32m **************************************************************************\033[0m"
    echo -e "\033[32m   testing all cases for all test sequences......                          \033[0m"
    echo -e "\033[32m **************************************************************************\033[0m"
    ./run_TestAllSequencesAllCasesTest.sh  ${TestType}  ${AllTestDataFolder}  ${FinalResultDir} ${ConfigureFile}

    echo -e "\033[32m **************************************************************************\033[0m"
    echo -e "\033[32m   get final test result......                                             \033[0m"
    echo -e "\033[32m **************************************************************************\033[0m"
    runGetFinalTestResult

    return ${AllTestFlag}
}

runExampleTest()
{
    TestType=LocalTest
    ConfigureFile="../CaseConfigure/case_for_Mac_fast_test.cfg"
    OpenH264Branch="Master"
    OpenH264Repos="https://github.com/cisco/openh264"

    runMain
}

#*****************************************************************************************
#exampe test
#*****************************************************************************************
#runExampleTest
#Temp()
#{
#*****************************************************************************************
# main enctry:
#*****************************************************************************************
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters is:"
echo "        $0 $@"
echo "*********************************************************"
echo ""

if [ ! $# -ge 2 ]
then
    runUsage
    exit 1
fi

TestType=$1
ConfigureFile=$2
OpenH264Branch=$3
OpenH264Repos=$4
SourceFolder=$5
CodecUpdateOption=$6


runMain
#*****************************************************************************************
#}
