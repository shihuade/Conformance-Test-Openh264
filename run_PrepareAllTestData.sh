#!/bin/bash
#***************************************************************************************
# brief:
#      --delete previous test data, and prepare test space for all test sequences in AllTestData/XXX.yuv
#      --usage: run_PrepareAllTestData.sh  $AllTestDataFolder  \
#                                          $CodecFolder  $ScriptFolder \
#                                          $ConfigureFile
#
#
#date:  5/08/2014 Created
#***************************************************************************************
runRemovedPreviousTestData()
{
	
	if [ -d $AllTestDataFolder ]
	then
		./${ScriptFolder}/run_SafeDelete.sh  $AllTestDataFolder
	fi
	if [ -d $SHA1TableFolder ]
	then
		./${ScriptFolder}/run_SafeDelete.sh  $SHA1TableFolder
	fi
	if [ -d $FinalResultDir ]
	then
		./${ScriptFolder}/run_SafeDelete.sh  $FinalResultDir
	fi
	
	if [ -d $SourceFolder ]
	then
		./${ScriptFolder}/run_SafeDelete.sh  $SourceFolder
	fi
	
}
runUnpdateCodec()
{
	echo ""
	echo -e "\033[32m openh264 repository cloning... \033[0m"
	echo ""
	./run_CheckoutCiscoOpenh264Codec.sh  ${Openh264GitAddr} ${SourceFolder}
	if [  ! $? -eq 0 ]
	then	
		echo ""
		echo -e "\033[31m Failed to clone latest openh264 repository! Please double check! \033[0m"
		echo ""
		exit 1
	fi
		
	echo ""
	echo -e "\033[32m openh264 codec building... \033[0m"
	echo ""
	./run_UpdateCodec.sh  ${SourceFolder}
	if [ ! $? -eq 0 ]
	then	
		echo ""
		echo -e "\033[31m Failed to update codec to latest version! Please double check! \033[0m"
		echo ""
		exit 1
	fi
	
	return 0
}
runPrepareSGEJobFile()
{
	if [ ! $# -eq 2 ]
	then
		echo "usage: runPrepareSGEJobFile  \$TestSequenceDir  \$TestYUVName "
		return 1
	fi
	TestSequenceDir=$1
	TestYUVName=$2
	
	if [ -d ${TestSequenceDir} ]
	then
		cd ${TestSequenceDir}
		TestSequenceDir=`pwd`
		cd ${CurrentDir}
	else
		echo -e "\033[31m Job folder does not exist! Please double check! \033[0m"
		exit 1
	fi
	
	SGEQueue="Openh264SGE"
	SGEName="${TestYUVName}_SGE_Test"
	SGEModelFile="${CurrentDir}/${ScriptFolder}/SGEModel.sge"
	SGEJobFile="${TestSequenceDir}/${TestYUV}.sge"
	SGEJobScript="run_OneTestYUV.sh"
	
	echo ""
	echo -e "\033[32m creating SGE job file : ${SGEJobFile} ......\033[0m"
	echo ""
	
	echo "">${SGEJobFile}
	while read line
	do
		if [[ $line =~ ^"#$ -q"  ]]
		then
			echo "#$ -q ${SGEQueue}  # Select the queue">>${SGEJobFile}
		elif [[ $line =~ ^"#$ -N"  ]]
		then
			echo "#$ -N ${SGEName} # The name of job">>${SGEJobFile}
		elif [[ $line =~ ^"#$ -wd"  ]]
		then
			echo "#$ -wd ${TestSequenceDir}">>${SGEJobFile}
		else
			echo $line >>${SGEJobFile}
		fi
	
	done <${SGEModelFile}
	
	echo "${TestSequenceDir}/${SGEJobScript}   ${TestYUVName}  ${FinalResultDir}  ${ConfigureFile}">>${SGEJobFile}
	
	return 0
}
#usage: runGetTestYUVList 
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
	
	aTestYUVList=(${TestSet0} ${TestSet1}  ${TestSet2}  ${TestSet3}  ${TestSet4}  ${TestSet5}  ${TestSet6}  ${TestSet7}  ${TestSet8})
}
runPrepareTestSpace()
{
	
	#now prepare for test space for all test sequences
	for TestYUV in ${aTestYUVList[@]}
	do
		SubFolder="${AllTestDataFolder}/${TestYUV}"
	
		echo ""
		echo "Test sequence name is ${TestYUV}"
		echo "sub folder is  ${SubFolder}"
		echo ""
		if [  -d  ${SubFolder}  ]
		then
			continue
		fi
		mkdir -p ${SubFolder}
		mkdir -p ${SubFolder}/${IssueFolder}
		mkdir -p ${SubFolder}/${TempDataFolder}
		mkdir -p ${SubFolder}/${ResultFolder}
		cp  ${CodecFolder}/*    ${SubFolder}
		cp  ${ScriptFolder}/*   ${SubFolder}
		cp  ${ConfigureFile}    ${SubFolder}
		
		if [ ${TestType} = "SGETest"  ]
		then
			runPrepareSGEJobFile  ${SubFolder}  ${TestYUV}
		fi 		
	done
	
	return 0
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
		 echo -e "\033[31musage: TestTest should be SGETest or LocalTest, please choose one! \033[0m"
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
#usage: runPrepareALlFolder   $TestType $AllTestDataFolder  $TestBitStreamFolder   $CodecFolder  $ScriptFolder  $ConfigureFile/$SH1TableFolder
runMain()
{
	#parameter check!
	if [ ! $# -eq 6  ]
	then
		echo ""
		echo -e "\033[31musage: run_PrepareAllTestFolder.sh   \$TestType  \$SourceFolder  \$AllTestDataFolder  \$CodecFolder  \$ScriptFolder \$ConfigureFile \033[0m"
		echo ""
		return 1
	fi
	
	TestType=$1
	SourceFolder=$2
	AllTestDataFolder=$3
	CodecFolder=$4
	ScriptFolder=$5
	ConfigureFile=$6
	
	CurrentDir=`pwd`
	SHA1TableFolder="SHA1Table"
	FinalResultDir="FinalResult"
	Openh264GitAddr="https://github.com/cisco/openh264"
	declare -a aTestYUVList
	#folder for eache test sequence
	SubFolder=""
	SGEJobFile=""
	IssueFolder="issue"
	TempDataFolder="TempData"
	ResultFolder="result"
	
	#check input parameters
	runCheck
	runRemovedPreviousTestData
	
	mkdir ${SHA1TableFolder}
	mkdir ${FinalResultDir}
	mkdir ${SourceFolder}
	
	#update codec
	runUnpdateCodec
	
	echo "Preparing test space for all test sequences!"
	runGetTestYUVList
	runPrepareTestSpace
}
TestType=$1
SourceFolder=$2
AllTestDataFolder=$3
CodecFolder=$4
ScriptFolder=$5
ConfigureFile=$6
runMain  $TestType  $SourceFolder $AllTestDataFolder    $CodecFolder  $ScriptFolder  $ConfigureFile

