#!/bin/bash
#*******************************************************************************
# brief:
#      clone or update repos to given checkout dir
#
# for usage, please refer to runUsage
#
# date: 2016.09.23
#*******************************************************************************
runUsage()
{
    echo -e "\033[32m ******************************************************************************* \033[0m"
    echo -e "\033[32m usage:                                                                          \033[0m"
    echo -e "\033[32m  ./run_CheckoutRepos.sh  \${GitRepositoryAddr} \${Branch}                       \033[0m"
    echo -e "\033[32m                          \${CheckoutDir}      \${ReposUpdateOption}             \033[0m"
    echo -e "\033[32m                                                                                 \033[0m"
    echo -e "\033[32m   ReposUpdateOption: fast or clone                                              \033[0m"
    echo -e "\033[32m                      if no value, will set to fast by default                   \033[0m"
    echo -e "\033[32m        ----fast,  will only update via git pull command based on current repos, \033[0m"
    echo -e "\033[32m                         no need to clone a new one                              \033[0m"
    echo -e "\033[32m        ----clone, will delete entire repos, and clone a new one                 \033[0m"
    echo -e "\033[32m                                                                                 \033[0m"
    echo -e "\033[32m example:                                                                        \033[0m"
    echo -e "\033[32m   ./run_CheckoutRepos.sh  https://github.com/cisco/openh264 master Source fast  \033[0m"
    echo -e "\033[32m ******************************************************************************* \033[0m"
}

runCheckParameter()
{
    #ReposUpdateOption: fast,  will only update via git pull command based on current repos,no need to clone a new one
    #                   clone, will delete entire repos, and clone a new one
    [ -z ${ReposUpdateOption} ] && ReposUpdateOption="fast"
    if [ "${ReposUpdateOption}" = "fast" ]
    then
        if [ ! -d ${CheckoutDir} ]
        then
            echo "Source folder ${CheckoutDir} does not exist!"
            echo "now change ReposUpdateOption to clone, which will clone a new repos to ${CheckoutDir} "
            ReposUpdateOption="clone"
            mkdir ${CheckoutDir}
            return 0
        fi

        cd ${CheckoutDir}
        #check if there is a repos
        git remote -v
        if [ ! $? -eq 0 ]
        then
            echo "git remote -v error, seems there is no repos"
            echo "now change ReposUpdateOption to clone, which will clone a new repos to ${CheckoutDir} "
            ReposUpdateOption="clone"
            cd -p ${CurrentDir}
            return 0
        fi

        #check if the current repos git address is the same with input
        #git remote output may looks like
        #origin	https://github.com/cisco/openh264 (fetch)
        #origin	https://github.com/cisco/openh264 (push)
        CurrentReposAddr=` git remote -v | grep origin | head -1 | awk '{print $2}'`
        if [ ! "${CurrentReposAddr}" = "${GitRepositoryAddr}" ]
        then
            echo "CurrentReposAddr        is: ${CurrentReposAddr}"
            echo "input GitRepositoryAddr is: ${GitRepositoryAddr}"
            echo "current repos address is not the same with input"
            echo "now change ReposUpdateOption to clone, which will clone a new repos to ${CheckoutDir} "
            ReposUpdateOption="clone"
            cd ${CurrentDir}
            return 0
        fi
        cd ${CurrentDir}
    fi

	return 0
}

runUpdateRepos()
{
    cd ${CheckoutDir}

    #clean up repos
    git clean -fdx
    git status | grep "modified:" | awk '{print $2}' | xargs git checkout

    #checkout to input branch
    git checkout ${Branch}
    [ ! $? -eq 0 ] && echo "checkout to branch ${Branch} failed!" && cd ${CurrentDir} && return 1

    #clean up repos
    git clean -fdx
    git status | grep "modified:" | awk '{print $2}' | xargs git checkout

    #pull latest commit
    git pull origin ${Branch}
    [ ! $? -eq 0 ] && echo "pull to latest commit failed!" && cd ${CurrentDir} && return 1

    cd ${CurrentDir}
    return 0
}

runCloneRepos()
{
    #remove and clone a new repos to CheckoutDir
   [ -d ${CheckoutDir} ] && ./Scripts/run_SafeDelete.sh ${CheckoutDir}
   mkdir -p ${CheckoutDir}

   git clone ${GitRepositoryAddr}  ${CheckoutDir}
   [ ! $? -eq 0 ] && echo "clone repos ${GitRepositoryAddr} failed!" && return 1

    #checkout to input branch
    cd ${CheckoutDir}
    git checkout ${Branch}
    [ ! $? -eq 0 ] && echo "checkout to branch ${Branch} failed!" && cd ${CurrentDir} && return 1
    cd ${CurrentDir}
    return 0
}

runOutputReposUpdateInfo()
{
    echo -e "\033[32m***********************************************  \033[0m"
    echo -e "\033[34m   ReposUpdateOption is: ${ReposUpdateOption}    \033[0m"
    echo -e "\033[32m   repos addr        is: ${GitRepositoryAddr}    \033[0m"
    echo -e "\033[32m   branch            is: ${Branch}               \033[0m"
    echo -e "\033[32m   update src dir    is: ${CheckoutDir}          \033[0m"
    echo -e "\033[32m***********************************************  \033[0m"
}

runOutputReposCommitInfo()
{
    echo -e "\033[33m*********************************************** \033[0m"
    echo -e "\033[33m  repos basic info                              \033[0m"
    echo -e "\033[33m*********************************************** \033[0m"
    cd ${CheckoutDir}
    git branch
    git remote -v
    echo -e "\033[33m*********************************************** \033[0m"
    git log -2
    cd ${CurrentDir}
    echo -e "\033[33m*********************************************** \033[0m"
}

runMain()
{
    CurrentDir=`pwd`
	runCheckParameter
    runOutputReposUpdateInfo

    if [ "${ReposUpdateOption}" = "fast" ]
    then
        runUpdateRepos
        [ ! $? -eq 0 ] && echo -e "\033[31m\n update repos failed!\n\033[0m" && exit 1

    elif [ "${ReposUpdateOption}" = "clone" ]
    then
        runCloneRepos
        [ ! $? -eq 0 ] && echo -e "\033[31m\n update repos failed!\n\033[0m" && exit 1
    else
        echo -e "\033[31m\n ReposUpdateOption should be fast or clone \n\033[0m"
        runUsage
        exit 1
    fi

    runOutputReposCommitInfo

	return 0
}

runExampleTest()
{
    GitRepositoryAddr="https://github.com/cisco/openh264"
    Branch="master"
    CheckoutDir="Source"
    ReposUpdateOption="fast"

   runMain
}

#******************************************************************************************************************
#example:
#runExampleTest
#Temp()
#{
#******************************************************************************************************************
echo ""
echo "*********************************************************"
echo "     call bash file is $0"
echo "     input parameters is:"
echo "        $0 $@"
echo "*********************************************************"
echo ""
#******************************************************************************************************************

if [  $# -lt 2 ]
then
    runUsage
    exit 1
fi

GitRepositoryAddr=$1
Branch=$2
CheckoutDir=$3
ReposUpdateOption=$4

runMain
#******************************************************************************************************************
#}



