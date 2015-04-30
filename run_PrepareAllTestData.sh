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
runUpdateCodec()
{

	./run_CheckoutCiscoOpenh264Codec.sh  ${Openh264GitAddr} ${SourceFolder}
	if [  ! $? -eq 0 ]
	then	
		echo ""
		echo -e "\033[31m Failed to clone latest openh264 repository! Please double check! \033[0m"
		echo ""
		exit 1
	fi
	
	cd ${SourceFolder}
	git checkout ${Branch}
	cd ${CurrentDir}
	
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

runGenerateSGEJobFileForOneYUV()
{
    if [ ! $# -eq 3 ]
    then
        echo "usage: runGenerateSGEJobFileForOneYUV  \$TestSequenceDir  \$TestYUVName \$ConfigureFile "
        return 1
    fi

    TestSequenceDir=$1
    TestYUVName=$2
    ConfigureFile=$3

    ./Scripts/run_GenerateSGEJobFile.sh  ${TestSequenceDir} ${TestYUVName} ${ConfigureFile}

    return 0
}

runParseConfigureFile()
{
	while read line
	do
		if [[ "$line" =~ ^GitAddress  ]]
		then
			Openh264GitAddr=`echo $line | awk '{print $2}' `
		elif  [[ "$line" =~ ^GitBranch  ]]
		then
			Branch=`echo $line | awk '{print $2}' `
        elif [[ "$line" =~ ^SubCasesNum  ]]
        then
            TempString=`echo $line | awk 'BEGINE {FS=":"} {print $2}' `
            TempString=`echo $TempString | awk 'BEGIN {FS="#"} {print $1}' `
            let "SGEJobSubCasesNum= ${TempString}"
        fi
	done <${ConfigureFile}

    if [ ! -z ${OpenH264Repos} ]
    then
        Openh264GitAddr="${OpenH264Repos}"
    fi

    if [ ! -z ${OpenH264Branch} ]
    then
        Branch="${OpenH264Branch}"
    fi


    echo ""
    echo -e "\033[32m openh264 repository cloning...             \033[0m"
    echo -e "\033[32m     ----repository is ${Openh264GitAddr}   \033[0m"
    echo -e "\033[32m     ----branch     is ${Branch}            \033[0m"
    echo -e "\033[32m SGEJobSubCasesNum  is ${SGEJobSubCasesNum} \033[0m"
    echo ""


}

runGenerateCaseFiles()
{
    if [ ! $# -eq 1 ]
    then
        echo -e "\033[31m usage: runGenerateCaseFiles \${TestYUVName}\033[0m"
        return 1
    fi

    TestYUVName=$1
    AllCasesFile=${TestYUVName}_AllCase.csv
    SubCaseInfoLog=${TestYUVName}_SubCasesInfo.log

    ./run_GenerateCase.sh  ${ConfigureFile}   ${TestYUVName} ${AllCasesFile}
    if [ ! $? -eq 0  ]
    then
        echo ""
        echo  -e "\033[31m  failed to generate cases ! \033[0m"
        echo ""
        return 1
    fi

    if [ ${TestType} == "SGETest"  ]
    then
        ./run_CasesPartition.sh ${AllCasesFile}  ${SGEJobSubCasesNum}    \
                                ${TestYUVName}   ${SubCaseInfoLog}

        if [ ! $? -eq 0  ]
        then
            echo ""
            echo  -e "\033[31m  failed to split all cases set into sub-set cases ! \033[0m"
            echo ""
            return 1
        fi
    fi

    return 0
}

runPrepareTestSpace()
{

	#now prepare for test space for all test sequences
	#for SGE test, use 3 test queues so that can support more parallel jobs
    echo -e "\033[32m ********************************************************************* \033[0m"
    echo -e "\033[32m    Preparing all test spaces for eache test sequence \033[0m"
    echo -e "\033[32m ********************************************************************* \033[0m"

    let "YUVIndex=0"
	for TestYUV in ${aTestYUVList[@]}
	do
		SubFolder="${AllTestDataFolder}/${TestYUV}"

        echo -e "\033[32m ********************************************************************* \033[0m"
        echo -e "\033[32m    Test sequence name is ${TestYUV} \033[0m"
        echo -e "\033[32m    Test sequence name is ${TestYUV} \033[0m"
        echo -e "\033[32m    Sub folder is  ${SubFolder}"
        echo -e "\033[32m ********************************************************************* \033[0m"

        if [  -d  ${SubFolder}  ]
		then
			continue
		fi
		mkdir -p ${SubFolder}
		cp  ${CodecFolder}/*    ${SubFolder}
		cp  ${ScriptFolder}/*   ${SubFolder}
		cp  ${ConfigureFile}    ${SubFolder}

        cd ${SubFolder}
        runGenerateCaseFiles ${TestYUV}
        cd ${CurrentDir}

		let "YUVIndex++"
		if [ ${TestType} = "SGETest"  ]
		then
			runGenerateSGEJobFileForOneYUV  ${SubFolder}  ${TestYUV}  ${ConfigureFile}
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
	if [ ! $# -ge 6  ]
	then
		echo ""
        echo -e "\033[31m usage: run_PrepareAllTestFolder.sh  \$TestType   \$SourceFolder  \$AllTestDataFolder  \033[0m"
        echo -e "\033[31m                                     \$CodecFolder \$ScriptFolder \$ConfigureFile      \033[0m"
        echo ""
        echo -e "\033[31m or:  \033[0m"
        echo -e "\033[31m usage: run_PrepareAllTestFolder.sh  \$TestType   \$SourceFolder  \$AllTestDataFolder  \033[0m"
        echo -e "\033[31m                                     \$CodecFolder \$ScriptFolder \$ConfigureFile      \033[0m"
        echo -e "\033[31m                                     \$OpenH264Branch \$OpenH264Repos       \033[0m"
        echo ""
		return 1
	fi
	
	TestType=$1
	SourceFolder=$2
	AllTestDataFolder=$3
	CodecFolder=$4
	ScriptFolder=$5
	ConfigureFile=$6
    OpenH264Branch=$7
    OpenH264Repos=$8

	CurrentDir=`pwd`
	SHA1TableFolder="SHA1Table"
	FinalResultDir="FinalResult"
	let "SGEJobNum =0 "
    let "SGEJobSubCasesNum=0"

	Openh264GitAddr=""
	Branch=""

	declare -a aTestYUVList
	#folder for eache test sequence
	SubFolder=""
	SGEJobFile=""
	
	#check input parameters
	runCheck
	runRemovedPreviousTestData
	
	mkdir ${SHA1TableFolder}
	mkdir ${FinalResultDir}
	mkdir ${SourceFolder}
	
	cd ${FinalResultDir}
	FinalResultDir=`pwd`
	cd  ${CurrentDir}
	
	#parse git repository info 
	runParseConfigureFile
	#update codec
    #runUpdateCodec

	echo "Preparing test space for all test sequences!"

    aTestYUVList=(`./Scripts/run_GetTestYUVSet.sh  ${ConfigureFile}`)

	runPrepareTestSpace
}
TestType=$1
SourceFolder=$2
AllTestDataFolder=$3
CodecFolder=$4
ScriptFolder=$5
ConfigureFile=$6
OpenH264Branch=$7
OpenH264Repos=$8
runMain  $TestType  $SourceFolder $AllTestDataFolder    $CodecFolder  $ScriptFolder  $ConfigureFile ${OpenH264Branch} "${OpenH264Repos}"

