#!/bin/bash
#***************************************************************************************
# brief:
#      --submit all jobs to SGE
#      --usage:  ./run_SGEJobSubmit.sh  ${AllTestDataDir} ${ConfigureFile}
#                                       ${SGEJobInfoFile}
#
#
#
#date: 04/26/2015 Created
#***************************************************************************************
 runUsage()
 {
	echo ""
	echo -e "\033[31m usage: ./run_SGEJobSubmit.sh  \${AllTestDataDir} \${ConfigureFile} \${SGEJobInfoFile} \033[0m"
 	echo ""
 }
runInitialSGEJobInfoFile()
{
    echo "***********************************************************************************************"
    echo "    "
    echo "    This file is used for SGE job status detction."
    echo "    "
    echo "    You can add new SGE job info in this file if you want to add "
    echo "    new jobs into current test or restart jobs before all"
    echo "    test jobs are completed"
    echo "    "
    echo "    Job info format should looks like as below:"
    echo "      Your job 534 ("CREW_176x144_30.yuv_SGE_Test_SubCaseIndex_1") has been submitted"
    echo "    "
    date
    echo "*************************************************************************************************"
    echo ""
    echo "    All SGE jobs info List As below"
    echo ""
    echo "*************************************************************************************************"

}

runSGEJobSubmit()
{
	let "JobNum=0"
    runInitialSGEJobInfoFile >${SGEJobListFile}

	for TestYUV in ${aTestYUVList[@]}
	do
        SubFolder="${AllTestDataDir}/${TestYUV}"
        echo ""
        echo "test YUV is ${TestYUV}"
        echo ""
        echo "******************************************************************************" >>${SGEJobListFile}
        echo "test YUV is ${TestYUV}" >>${SGEJobListFile}
        echo "******************************************************************************" >>${SGEJobListFile}

        for vSGEFile in ${SubFolder}/${TestYUV}*.sge
        do
            TestSubmitFlagFile="${vSGEFile}_Submitted.flag"

            if [  -e  ${SubFolder}/${TestSubmitFlagFile} ]
            then
                continue
            fi

            echo "submitting job ......"
            # e.g.: Your job 534 ("CREW_176x144_30.yuv_SGE_Test_SubCaseIndex_1") has been submitted
            aSubmitJobList[$JobNum]=`qsub  ${vSGEFile} `
            echo "submit job is ${aSubmitJobList[$JobNum]} "
            echo "${aSubmitJobList[$JobNum]}" >>${SGEJobListFile}
            let "JobNum ++"
            touch ${TestSubmitFlagFile}
            #cd  ${CurrentDir}

        done
	done
	return 0
}

runMain()
{
	#parameter check!
	if [ ! $# -eq 3  ]
	then
		runUsage
		exit 1
	fi

    AllTestDataDir=$1
	ConfigureFile=$2
    SGEJobListFile=$3
	CurrentDir=`pwd`

	let "CurrentSGEJobNum=0"
	declare -a aTestYUVList

	#get full path info
	cd ${AllTestDataDir}
	AllTestDataDir=`pwd`
	cd  ${CurrentDir}

	#get YUV list
    aTestYUVList=(`./Scripts/run_GetTestYUVSet.sh  ${ConfigureFile}`)
    if [ ! $? -eq 0 ]
    then
        echo -e "\033[31m  Failed to parse test YUV set. please double check! \033[0m"
        echo -e "\033[31m  detected by $0 \033[0m"
        exit 1
    fi

    runSGEJobSubmit

    return 0

}
AllTestDataDir=$1
ConfigureFile=$2
SGEJobListFile=$3
runMain  ${AllTestDataDir}  ${ConfigureFile} ${SGEJobListFile}

