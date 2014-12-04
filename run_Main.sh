
#!/bin/bash
#***************************************************************************************
# brief:
#      --start point of the test.
#      --before run this script,
#          i) you need to update you codec  in folder ./Codec
#          ii) change you configure file if you do not use the default test case
#      --usage: run_Main.sh $ConfigureFile
# 
#      --for more detail,please refer to README.md
#
#
#date:  5/08/2014 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
	echo -e "\033[31m usage: ./run_Main.sh  \$TestType \$ConfigureFile \033[0m"
	echo -e "\033[31m       --eg:   ./run_Main.sh  SGETest  ./CaseConfigure/case.cfg\033[0m"
	echo -e "\033[31m       --eg:   ./run_Main.sh  LocalTest  ./CaseConfigure/case.cfg \033[0m"
 	echo ""
 }
 
 runPromptInfo()
 {
	echo ""
	echo  -e "\033[32m Final result can be found in ./FinaleRestult \033[0m"
	echo  -e "\033[32m SHA1 table can be found in ./SHA1Table \033[0m"
	echo ""
 }
 
runCheck()
{
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
	
	#check configure file
	if [  ! -f ${ConfigureFile} ]
	then
		echo "Configure file not exist!, please double check in "
		echo " usage may looks like:   ./run_Main.sh  ../CaseConfigure/case.cfg "
		exit 1
	fi
	return 0
}
runMain()
 {
	if [ ! $# -eq 2 ]
	then
		runUsage
		exit 1
	fi
	TestType=$1
	ConfigureFile=$2
	
	runCheck
	
	#dir translation
	AllTestDataFolder="AllTestData"
	SourceFolder="Source"
	CodecFolder="Codec"
	ScriptFolder="Scripts"
	SH1TableFolder="SHA1Table"
	ConfigureFolder="CaseConfigure"
	FinalResultDir="FinalResult"
	
	echo ""
	echo ""
	echo "prepare for all test data......."
	echo ""
	# prepare for all test data  //$TestType  $SourceFolder $AllTestDataFolder    $CodecFolder  $ScriptFolder  $ConfigureFile
	./run_PrepareAllTestData.sh   ${TestType}  ${SourceFolder}  ${AllTestDataFolder}  ${CodecFolder}  ${ScriptFolder}  ${ConfigureFile}
	if [ ! $? -eq 0 ]
	then
		echo "failed to prepared  test space for all test data!"
		exit 1
	fi
	echo ""
	echo ""
	echo "running all test cases for all test sequences......"
	echo ""
	##                                     ${TestType}  ${AllTestDataDir}  ${FinalResultDir} ${ConfigureFile}
	./run_AllTestSequencesAllCasesTest.sh  ${TestType}  ${AllTestDataFolder}  ${FinalResultDir} ${ConfigureFile}
	if [ ! $? -eq 0 ]
	then
		echo ""
		echo -e "\033[31m failed: not all cases for all test sequences have been passed ! \033[0m"
		echo ""
		cp  ${FinalResultDir}/*SHA1_Table.csv  ./${SH1TableFolder}
		runPromptInfo
		exit 1
	else
		echo ""
		echo -e "\033[32m all cases of  all test sequences have been passed! \033[0m"
		echo ""
		cp  ${FinalResultDir}/*SHA1_Table.csv ./${SH1TableFolder}
		runPromptInfo
		exit 0
	fi
}
TestType=$1
ConfigureFile=$2
runMain  ${TestType} ${ConfigureFile}

