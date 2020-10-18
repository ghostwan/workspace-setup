# !/bin/bash
# Version 1.0.0

# Install all needed tools on a fresh mac

force_installation=1
export HOMEBREW_CASK_OPTS="--no-quarantine"

#########################################################
################## INSTALL UTILITY ##################
#########################################################
function printIsExits() {
    printf "is \033[0;33m $1 \033[0m installed ? "
}

function printAlreadyInstall() {
    printf "\033[0;32mYES\033[0m\n"
}

function printNotInstall() {
    printf "\033[0;34mNO\033[0m\n"
}

function printDoesNotExist() {
    printf "\033[0;31mDOESN'T EXIST\033[0m\n"
}

function printInstallingBy() {
    printf "\033[1mInstalling by $1 $2...\033[0m\n"
}

function println() {
    printf "\033[0;33m $1 \033[0m\n"
}

function printInfo() {
    printf "    \033[0;100m $DESC \033[0m => \033[0;34m $LINK \033[0m \n"
    echo ""
}

function printError() {
    printf "\033[0;31m $1 \033[0m\n"
}

function ask_no_or_Yes() { # The Captial letter is the default one
    printf "\033[0;33m $1 \033[0m"
    printf "(\033[0;92m[Y]es\033[0m"
    read -p " or [n]o): " REPLY </dev/tty
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        n|no) return 1 ;;
        *)    return 0 ;;
    esac
}

function ask_yes_or_No() { # The Captial letter is the default one
    printf "\033[0;33m $1 \033[0m"
    printf "(\033[0;91m[N]o\033[0m"
    read -p " or [y]es): " REPLY </dev/tty
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) return 0 ;;
        *)     return 1 ;;
    esac
}

function ask_open() { # The Captial letter is the default one
    printf "\033[0;33m $1 \033[0m"
    read -p " " REPLY </dev/tty
}

function checkCommand() {
    printIsExits $1
    command -v $1 >/dev/null 2>&1
}

function checkCommandMas() {
    printIsExits $1
    result=$1.app
    resultroot=/Applications/$result
    resulthome=$HOME/Applications/$result
    if [ -d "$resultroot" ] || [ -d "$resulthome" ]; then
        return 0
    else
        result="$(mas search $1 | grep 'No results found')"
        if [ -n "$result" ]; then
            return 2
        fi
        return 1
    fi
}

function checkCommandCask() {
    printIsExits $1
    brew cask info $1 >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        return 2
    else
        result="$(brew cask info $1 | grep 'Not installed')"
        if [ -n "$result" ]; then
            return 1
        fi
    fi
    return 0;
}

function printDoYouWant() {
    if [ $force_installation -eq 0 ]; then
        return 0
    fi
    printf "Do you want to install \033[0;33m $1 \033[0m? (\033[0;91m[N]o\033[0m"
    read -p ", [a]ll or [y]es): " REPLY </dev/tty
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) return 0 ;;
        a|all) 
            force_installation=0 
            return 0 
            ;;
        *)     return 1 ;;
    esac
}

function installBy() {
    if [ $3 -eq 1 ]; then
        printNotInstall
        printInfo
        printDoYouWant $2
        if [ $? -eq 0 ]; then
            printInstallingBy "$1" $2
            $1 install $2
        fi
    elif [ $3 -eq 2 ]; then
        printDoesNotExist
    else
        printAlreadyInstall
    fi
}



#################################################################
################## PACKAGE MANAGER TO INSTALL ##################
################################################################
function install_packageManager() {

    # Hombrew : package manager for macOS (or Linux)
    # https://brew.sh/index_fr
    checkCommand brew
    if [ $? -ne 0 ]; then
        printInstallingBy "curl" brew
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        printAlreadyInstall
    fi

    println "updating brew..."
    brew update

    # pip : package installer for Python
    # https://pypi.org/project/pip/
    checkCommand pip3
    if [ $? -ne 0 ]; then
        printInstallingBy "curl" pip
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    else
        printAlreadyInstall
    fi

    install_app npm brew "JS Package Manager" https://www.npmjs.com
    install_app mas brew "Mac App Store package manager" https://github.com/mas-cli/mas
}

function install_app() {
    NAME=$1
    TYPE=$2
    DESC=$3 
    LINK=$4 

    IFS=' ' read -ra arguments <<< "$NAME"
    IFS=' '
    case $TYPE in
        brew)
            checkCommand $NAME
            installBy brew $1 $?
            ;;
        brew-name)
            checkCommand ${arguments[0]}
            installBy brew ${arguments[1]} $?
            ;;
        pip)
            checkCommand $NAME
            installBy pip3 $NAME $?
            ;;
        mas)
            checkCommandMas ${arguments[0]} ${arguments[1]}
            installBy mas ${arguments[1]} $?
            ;;
        cask) 
            checkCommandCask $NAME
            installBy 'brew cask' $NAME $?
            ;;
        gem)
            checkCommand $NAME
            installBy gem $NAME $?
            ;;
        manual)
            printf "\033[0;33m $NAME \033[0m ===> \033[0;35m Go to \033[0;34m $LINK\033[0;35m and download the app \033[0m \n"
            ;;
        *) 
            printError "Command  $TYPE does not exist"
        ;;
    esac
}


function install_stack() {

    if [ $# -eq 1 ]; then
        println "installing stack for category $1"
        exec < stack.csv || exit 1
        read header # read (and ignore) the first line
        while IFS=, read CAT TYPE NAME DESC LINK; do
            if [ $# -eq 1 ] && [ $CAT = $1 ]; then
                install_app "${NAME}" "${TYPE}" "${DESC}" "${LINK}"
            fi
        done
        IFS=' '
    else
        println "installing all categories"
        exec < stack.csv || exit 1
        read header # read (and ignore) the first line
        while IFS=, read CAT TYPE NAME DESC LINK; do
            install_app "${NAME}" "${TYPE}" "${DESC}" "${LINK}"
        done
        IFS=' '
    fi
}

function checkPackageExist() {
    case $1 in
        brew|brew-name)
            return brew info $2 >/dev/null 2>&1; echo $?
            ;;
        cask)
            return brew cask info $2 >/dev/null 2>&1 ; echo $?
            ;;
        pip)
            return pip3 search $2 >/dev/null 2>&1; echo $?
            ;;
        mas)
            return mas search $2 >/dev/null 2>&1; echo $?
            ;;
        gem|manual)
            return 0
            ;;
        dunno)
            TYPE=""
            if [ $(brew info $2 >/dev/null 2>&1; echo $?) -eq 0 ]; then TYPE="brew";
            elif [ $(brew cask info $2 >/dev/null 2>&1; echo $?) -eq 0 ]; then TYPE="cask";
            elif [ $(pip3 search $2 >/dev/null 2>&1; echo $?) -eq 0 ]; then TYPE="pip"; 
            elif [ $(mas search $2 >/dev/null 2>&1; echo $?) -eq 0 ]; then TYPE="mas"; 
            fi
            if [ -z $TYPE ]; then
                TYPE="any"
                return 1
            else 
                echo "found in $TYPE"
                return 0
            fi
            ;;
        *) 
            printError "Command $TYPE does not exist"
            ;;
    esac
    return 1
}

function list_all_categories() {
    exec < stack.csv || exit 1
    read header # read (and ignore) the first line
    while IFS=, read CAT YPE NAME DESC LINK; do
        echo $CAT
    done | sort -u | tr '\n' ' '
    IFS=' '
}

function install_package() {
    package=$1

    println "installing package $package"
    exec < stack.csv || exit 1
    read header # read (and ignore) the first line
    while IFS=, read CAT TYPE NAME DESC LINK; do
        if [ $# -eq 1 ] && [ "$NAME" = "$package" ]; then
            install_app "${NAME}" "${TYPE}" "${DESC}" "${LINK}"
            exit 0
        fi
    done
    printError "$package does not exist in the stack!"
    if ask_yes_or_No "Do you want to add in the stack and install $package ?"
    then
        NAME=$package
        ask_open "What package type is it (brew, cask, brew-name, manual, pip, gem ) or leave blanck for detection  ?"
        TYPE=$REPLY
        echo $TYPE
        if [ -z $TYPE ]; then TYPE="dunno"; fi
        if checkPackageExist $TYPE $NAME
        then
            ask_open "In what category do you want to put it ? ( $(list_all_categories)) "
            CAT=$REPLY
            ask_open "Give a brief description of this tool: "
            DESC=$REPLY
            ask_open "Give this tools website link for more info: "
            LINK=$REPLY
            newLine="$CAT,$TYPE,$NAME,$DESC,$LINK"
            echo $newLine >> stack.csv
            install_package $NAME
        else
            printError "$package does not exist on $TYPE repository!"
        fi
    fi
        
    IFS=' '
}



# # A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

category=""
package=""

display_usage() {
  echo
  echo "Usage: ${0##*/} [-h] [-f] [-c <category> | -p <package>]"
  echo
  echo " -h             Display usage instructions"
  echo
  echo " -f             Force app installation"
  echo " -p <package>   Installation of a specific package by its name"
  echo "                => example:  ${0##*/} -p spotify"
  echo ""
  printf " -c <category>  Choose which category to install (default is all) among : $(list_all_categories)"
  echo
  echo "                => example:  ${0##*/} -c multimedia"
  echo
  
}


while getopts "h?vfc:p:" opt; do
    case "$opt" in
    h | \?)
        display_usage
        exit 0
        ;;
    f)
        force_installation=0
        ;;
    c)
        category=$OPTARG
        ;;
    p)
        package=$OPTARG
        ;;
    esac
done

install_packageManager
if [ -n "$package" ]; then
    install_package $package
else 
    install_stack $category
fi

