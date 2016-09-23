#!/bin/bash
#***************************************************************************************
# brief:
#      --delete previous test data, and prepare test space for all test sequences in AllTestData/XXX.yuv
#      --usage: refer to function runUsage()
#
#date:  5/08/2014 Created
#***************************************************************************************
runUsage()
{
    echo -e "\033[32m ************************************************************************** \033[0m"
    echo -e "\033[31m usage: run_PrepareAllTestFolder.sh  \$TestType       \$ConfigureFile       \033[0m"
    echo -e "\033[31m                                     \$OpenH264Branch \$OpenH264Repos       \033[0m"
    echo -e "\033[31m                                     \$SourceFolder   \$ReposUpdateOption   \033[0m"
    echo -e "\033[31m       --last four parameters are optional                                  \033[0m"
    echo -e "\033[31m         which used to overwrite value in configure file                    \033[0m"
    echo -e "\033[31m       --ReposUpdateOption: fast or colone                                  \033[0m"
    echo -e "\033[31m         ----fast:  update repos via git pull only                          \033[0m"
    echo -e "\033[31m         ----clone: clone a new repos                                       \033[0m"
    echo -e "\033[31m                                                                            \033[0m"
    echo -e "\033[31m example:                                                                   \033[0m"
    echo -e "\033[31m   ./run_PrepareAllTestFolder.sh LocalTest case_SVC.cfg                     \033[0m"
    echo -e "\033[31m                                                                            \033[0m"
    echo -e "\033[32m ************************************************************************** \033[0m"
}

runGlobalVariableInitial()
{
    CurrentDir=`pwd`
    #the same with run_main.sh
    AllTestDataFolder="AllTestData";SHA1TableFolder="SHA1Table";FinalResultDir="FinalResult"
    CodecFolder="Codec";Codec_Linux="Codec_Linux";Codec_Mac="Codec_Mac"
    ScriptFolder="Scripts"
    BitStreamToYUVFolder="BitStreamToYUV"
    SummaryDir="FinalResult_Summary"

    let "SGEJobNum =0 ";let "SGEJobSubCasesNum=0"

    Openh264GitAddr="";Branch=""

    #Input test set setting
    declare -a aTestYUVList
    InputFileFormat=""

    #folder for eache test sequence
    SubFolder="";SGEJobFile=""
}

runRemovedPreviousTestData()
{
	[ -d $AllTestDataFolder ]    && ./${ScriptFolder}/run_SafeDelete.sh  $AllTestDataFolder
	[ -d $SHA1TableFolder ]      && ./${ScriptFolder}/run_SafeDelete.sh  $SHA1TableFolder
	[ -d $FinalResultDir ]       && ./${ScriptFolder}/run_SafeDelete.sh  $FinalResultDir
	[ -d $SummaryDir ]           && ./${ScriptFolder}/run_SafeDelete.sh  $SummaryDir
    [ -d $SourceFolder ]         && ./${ScriptFolder}/run_SafeDelete.sh  $SourceFolder
    [ -d $BitStreamToYUVFolder ] && ./${ScriptFolder}/run_SafeDelete.sh  $BitStreamToYUVFolder
    [ -d $CodecFolder ]          && ./${ScriptFolder}/run_SafeDelete.sh  $CodecFolder

    for file in ${CurrentDir}/*.log
    do
        ./${ScriptFolder}/run_SafeDelete.sh  ${file}
    done

    for file in ${CurrentDir}/*.txt
    do
        ./${ScriptFolder}/run_SafeDelete.sh  ${file}
    done

    for file in ${CurrentDir}/*.flag
    do
        ./${ScriptFolder}/run_SafeDelete.sh  ${file}
    done

    mkdir -p ${AllTestDataFolder} ${SHA1TableFolder} ${FinalResultDir} ${SummaryDir} ${BitStreamToYUVFolder} ${CodecFolder}
}

runParseConfigureFile()
{
    Openh264GitAddr=(`cat ${ConfigureFile} | grep "^GitAddress"   | awk '{print $2}' `)
    Branch=(`cat ${ConfigureFile}          | grep "^GitBranch"    | awk '{print $2}' `)
    TempString=(`cat ${ConfigureFile}      | grep "^SubCasesNum"  | awk 'BEGIN {FS="[#:]"} {print $2}' `)
    let "SGEJobSubCasesNum= ${TempString}"
    TempString=(`cat ${ConfigureFile}      | grep "^InputFormat"  | awk 'BEGIN {FS="[#:]"} {print $2}' `)
    let "InputFileFormat= ${TempString}"
    Platform=(`cat ${ConfigureFile}        | grep "TestPlatform"  | awk 'BEGIN {FS="[#:]"} {print $2}' `)

    #if value in configure files will be overwrite by input value
    [ ! -z ${OpenH264Repos} ]    && Openh264GitAddr="${OpenH264Repos}"
    [ ! -z ${OpenH264Branch} ]   && Branch="${OpenH264Branch}"

    #using default value
    [ -z ${SourceFolder} ]       && SourceFolder="Source"
    [ -z ${ReposUpdateOption} ]  && ReposUpdateOption="fast"
}

runUpdateCodec()
{
    #checkout openh264 repos and switch to test branch
    ./run_CheckoutRepos.sh  ${Openh264GitAddr} ${Branch} ${SourceFolder} ${ReposUpdateOption}
	[  ! $? -eq 0 ] && echo -e "\033[31m\n Failed to checkout openh264 repository! \n\033[0m" && exit 1

    #build codec with enable YUV dump
	./run_UpdateCodec.sh  ${SourceFolder}
	[ ! $? -eq 0 ] && echo -e "\033[31m\n Failed build and update codec! \n\033[0m" && exit 1

    #copy JM/JSVM/DowsampleApp etc. tools to codec folder
    [ "${Platform}" = "linux" ] && cp -f  ${Codec_Linux}/*  ${CodecFolder}
    [ "${Platform}" = "mac" ]   && cp -f  ${Codec_Mac}/*    ${CodecFolder}

	return 0
}

runGenerateCaseFiles()
{
    TestYUVName=$1

    AllCasesFile=${TestYUVName}_AllCase.csv
    SubCaseInfoLog=${TestYUVName}_SubCasesInfo.log

    ./run_GenerateCase.sh  ${ConfigureFile}   ${TestYUVName} ${AllCasesFile}
    [ ! $? -eq 0  ] && echo  -e "\033[31m\n  failed to generate cases ! \n\033[0m" && exit 1

    if [ ${TestType} == "SGETest"  ]
    then
        ./run_CasesPartition.sh ${AllCasesFile}  ${SGEJobSubCasesNum}\
                                ${TestYUVName}   ${SubCaseInfoLog}
        [ ! $? -eq 0  ] && echo  -e "\033[31m  failed to split all cases set into sub-set! \n\033[0m" && exit 1
    fi

    return 0
}

runPrepareTestSpace()
{
    let "YUVIndex=0"
	for TestYUV in ${aTestYUVList[@]}
	do
		SubFolder="${AllTestDataFolder}/${TestYUV}"
        [ -d  ${SubFolder} ] && continue #for those repeat YUV name in TestYUVList

        echo -e "\033[32m ********************************************************************* \033[0m"
        echo -e "\033[32m    Test sequence name is: ${TestYUV}                                  \033[0m"
        echo -e "\033[32m    Test space         is: ${SubFolder}                                \033[0m"
        echo -e "\033[32m ********************************************************************* \033[0m"

        #copy codec app, script files, cfg files to test space for one YUV
		mkdir -p ${SubFolder}
        cp ${CodecFolder}/*  ${SubFolder};  cp ${ScriptFolder}/*  ${SubFolder};  cp ${ConfigureFile} ${SubFolder}

        #if input format is bit stream, will decode to YUV, and sub-folder as input YUV dir
        [ ${InputFileFormat} -eq 1 ] && cp ${BitStreamToYUVFolder}/${TestYUV}  ${SubFolder}

        #generate test cases
        cd ${SubFolder};runGenerateCaseFiles ${TestYUV};cd ${CurrentDir}

		let "YUVIndex++"
		if [ ${TestType} = "SGETest"  ]
		then
			./Scripts/run_GenerateSGEJobFile.sh  ${SubFolder}  ${TestYUV}  ${ConfigureFile}
		fi 		
	done
	
	return 0
}

runGetInputYUVTestSet()
{
    #if InputFileFormat=1, which means bit stream as input,
    #   --1, will decode to YUV, rename YUV with actual resolution
    #   --2, will copy decoded YUV files to BitStreamToYUV
    #   --3, BitStreamToYUV will be set as input YUVs' dir
    aTestYUVList=(`./Scripts/run_GetTestYUVSet.sh  ${ConfigureFile}`)

    [ ${InputFileFormat} -eq 1 ] && cat BitStreamToYUV.log
}

runOutput()
{
    echo -e "\033[32m ********************************************************* \033[0m"
    echo -e "\033[32m Repository         is ${Openh264GitAddr}   \033[0m"
    echo -e "\033[32m Branch             is ${Branch}            \033[0m"
    echo -e "\033[32m SGEJobSubCasesNum  is ${SGEJobSubCasesNum} \033[0m"
    echo -e "\033[32m SGEJobSubCasesNum  is ${SGEJobSubCasesNum} \033[0m"
    echo -e "\033[32m ********************************************************* \033[0m"
}

runCheck()
{
	#check test type
	[ ! "${TestType}" = "SGETest" ] && [ ! "${TestType}" = "LocalTest" ] && exit 1

	#check configure file
	[  ! -f ${ConfigureFile} ] && echo "Configure file not exist!, please double check in " && exit 1

    return 0
}

runMain()
{
    #check input parameters
	runCheck
    runGlobalVariableInitial

    echo -e "\033[32m ********************************************************************* \033[0m"
    echo -e "\033[32m    Removing previous test data \033[0m"
    echo -e "\033[32m ********************************************************************* \033[0m"
	runRemovedPreviousTestData

	#parse git repository info
	runParseConfigureFile
    runOutput

	#update codec
    echo -e "\033[32m ********************************************************************* \033[0m"
    echo -e "\033[32m    updating test codec  \033[0m"
    echo -e "\033[32m ********************************************************************* \033[0m"
    runUpdateCodec

    runGetInputYUVTestSet

    echo -e "\033[32m ********************************************************************* \033[0m"
    echo -e "\033[32m    Preparing all test spaces for eache test sequence \033[0m"
    echo -e "\033[32m ********************************************************************* \033[0m"
	runPrepareTestSpace

    echo -e "\033[32m ********************************************************************* \033[0m"
    echo -e "\033[32m   Test space preparation succeed                               \033[0m"
    echo -e "\033[32m   All test data, please refer to: ${AllTestDataFolder}         \033[0m"
    echo -e "\033[32m ********************************************************************* \033[0m"
}

runExampleTest()
{
    TestType="LocalTest"
    ConfigureFile="./CaseConfigure/case_for_Mac_fast_test.cfg"
    OpenH264Repos="https://github.com/cisco/openh264"
    Branch="master"
    CheckoutDir="Source"
    ReposUpdateOption="fast"

    runMain
}
#************************************************************************************************************
# example test
runExampleTest

EnableExampleTest()
{
#************************************************************************************************************
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters is:"
echo "        $0 $@"
echo "*********************************************************"
echo ""

#parameter check!
if [ ! $# -ge 2 ]
then
    runUsage
    return 1
fi

TestType=$1
ConfigureFile=$2
OpenH264Branch=$3
OpenH264Repos=$4
SourceFolder=$5
ReposUpdateOption=$6

runMain
#************************************************************************************************************
}
