
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
runPromptInfo()
runPromptInfo()
 {
	echo ""
	echo  -e "\033[32m Final result can be found in ./FinaleRestult \033[0m"
	echo  -e "\033[32m SHA1 table can be found in ./SHA1Table \033[0m"
	echo ""
 }
runMain()
 {
	if [ ! $# -eq 1 ]
	then
		echo "usage: ./run_Main.sh \$ConfigureFile"
		echo "      eg:   ./run_Main.sh  ../CaseConfigure/case.cfg "
		exit 1
	fi
	local ConfigureFile=$1
	if [  ! -f ${ConfigureFile} ]
	then
		echo "Configure file not exist!, please double check in "
		echo " usage may looks like:   ./run_Main.sh  ../CaseConfigure/case.cfg "
		exit 1
	fi
	#dir translation
	AllTestDataFolder="AllTestData"
	CodecFolder="Codec"
	ScriptFolder="Script"
	SH1TableFolder="SHA1Table"
	ConfigureFolder="CaseConfigure"
	FinalResultDir="FinalResult"
	echo ""
	echo ""
	echo "prepare for all test data......."
	echo ""
	# prepare for all test data
	./run_PrepareAllTestData.sh    ${AllTestDataFolder}  ${CodecFolder}  ${ScriptFolder}  ${ConfigureFile}
	if [ ! $? -eq 0 ]
	then
		echo "failed to prepared  test space for all test data!"
		exit 1
	fi
	echo ""
	echo ""
	echo "running all test cases for all bit streams......"
	echo ""
	./run_AllTestSequencesAllCasesTest.sh   ${AllTestDataFolder}  ${FinalResultDir} ${ConfigureFile}
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
ConfigureFile=$1
runMain  ${ConfigureFile}


