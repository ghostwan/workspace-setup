# !/bin/bash
# Version 1.0.0

# Install all needed tools on a fresh mac

force_installation=1
export HOMEBREW_CASK_OPTS="--no-quarantine"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Find stack file either on current or upper folder
STACK_CSV=$SCRIPT_DIR/stack.csv
if [ ! -f "$STACK_CSV" ] ; then
    STACK_CSV=$SCRIPT_DIR/../stack.csv
    if [ ! -f "$STACK_CSV" ]; then printf "\033[0;31m Can't find stack.csv \033[0m\n"; exit 1; fi
fi

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
    printInfo
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

function continue_or_quit() {
  printf "\033[0;100m !! Tap enter to continue or q to quit ... \033[0m"
  read -p "  " REPLY </dev/tty
  if [ -z "$REPLY" ]; then return 1; else return 0; fi
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
        npm)
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
            installBy npm $NAME $?
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
    install_packageManager
    if [ $# -eq 1 ]; then
        println "installing stack for category $1"
        readStack
        while IFS=, read CAT TYPE NAME DESC LINK; do
            if [ $# -eq 1 ] && [ $CAT = $1 ]; then
                install_app "${NAME}" "${TYPE}" "${DESC}" "${LINK}"
            fi
        done
        IFS=' '
    else
        println "installing all categories"
        readStack
        while IFS=, read CAT TYPE NAME DESC LINK; do
            install_app "${NAME}" "${TYPE}" "${DESC}" "${LINK}"
        done
        IFS=' '
    fi
}

function checkPackageExist() {
    if [[ "$1" == "gem"  || "$1" == "manual" ]]; then return 0; fi

    temp_type=""
    if  ([ "$1" == "dunno" ] || [ "$1" == "brew" ]) && [ $(brew info $2 >/dev/null 2>&1; echo $?) -eq 0 ]; then temp_type="brew";
    elif ([ "$1" == "dunno" ] || [ "$1" == "cask" ]) && [ $(brew cask info $2 >/dev/null 2>&1; echo $?) -eq 0 ]; then temp_type="cask";
    elif ([ "$1" == "dunno" ] || [ "$1" == "pip" ]) && [ $(pip3 search $2 | grep $2 >/dev/null 2>&1; echo $?) -eq 0 ]; then temp_type="pip"; 
    elif ([ "$1" == "dunno" ] || [ "$1" == "mas" ]) && [ $(mas search $2 | grep $2 >/dev/null 2>&1; echo $?) -eq 0 ]; then temp_type="mas"; 
    elif ([ "$1" == "dunno" ] || [ "$1" == "npm" ]) && [ $(npm view $2  >/dev/null 2>&1; echo $?) -eq 0 ]; then temp_type="npm"; 
    fi
    if [ -z $temp_type ]; then
        TYPE="any"
        return 1
    else 
        TYPE=$temp_type
        echo "found in $TYPE"
        return 0
    fi
}

function checkPackageInstall() {
    TYPE=$1
    NAME=$2
    IFS=' ' read -ra arguments <<< "$NAME"
    IFS=' '
    case $TYPE in
        brew|pip|gem) if [ $(command -v $NAME >/dev/null 2>&1; echo $?) -eq 0 ]; then return 0; fi  ;;
        brew-name) if [ $(command -v ${arguments[0]} >/dev/null 2>&1; echo $?) -eq 0 ]; then return 0; fi ;;
        cask) if [ $(brew cask info $NAME | grep -e 'Not installed' >/dev/null 2>&1; echo $?) -eq 1 ]; then return 0; fi ;; 
        *) 
            result=${arguments[0]}.app
            resultroot=/Applications/$result
            resulthome=$HOME/Applications/$result
            if [ -d "$resultroot" ] || [ -d "$resulthome" ]; then
                return 0
            fi
            ;;
    esac
    return 1
}

function readStack() {
    exec < $STACK_CSV || exit 1
    read header # read (and ignore) the first line
}

function list_all_categories() {
    readStack
    while IFS=, read CAT TYPE NAME DESC LINK; do
        echo $CAT
    done | sort -u | tr '\n' ' '
    IFS=' '
}

function list_packages_category() {
    readStack
    if [ "all" = $1 ]; then
        while IFS=, read CAT TYPE NAME DESC LINK; do
            status="NOT INSTALL"
            if checkPackageInstall $TYPE $NAME
            then
                status="INSTALLED"
            fi
            printf "$status \033[0;35m ${CAT} \033[0m \033[0;32m ${TYPE} \033[0m \033[0;31m ${NAME} \033[0m \033[0;30m ${DESC} \033[0m \033[0m \033[0;34m ${LINK} \033[0m \n"
        done
    else
        while IFS=, read CAT TYPE NAME DESC LINK; do
            if [ $CAT = $1 ]; then
                status="NOT INSTALL"
                if checkPackageInstall $TYPE $NAME
                then
                    status="INSTALLED"
                fi
                printf "$status \033[0;32m ${TYPE} \033[0m \033[0;31m ${NAME} \033[0m \033[0;30m ${DESC} \033[0m \033[0m \033[0;34m ${LINK} \033[0m \n"
            fi
        done
    fi
    IFS=' '
}


function search_package() {
    package=$1
    println "Searching on brew/cask..."
    brew search "$package"
    if continue_or_quit; then return 1; fi
    println "Searching on mas..."
    mas search "$package"
    if continue_or_quit; then return 1; fi
    println "Searching on pip..."
    pip3 search "$package"
    if continue_or_quit; then return 1; fi
    println "Searching on gem..."
    gem search "$package"
    if continue_or_quit; then return 1; fi
    println "Searching on npm..."
    npm search "$package"
    if continue_or_quit; then return 1; fi
}

function install_package() {
    install_packageManager

    package=$1

    println "installing package $package"
    readStack
    while IFS=, read CAT TYPE NAME DESC LINK; do
        if [ $# -eq 1 ] && [ "$NAME" = "$package" ]; then
            install_app "${NAME}" "${TYPE}" "${DESC}" "${LINK}"
            return 1
        fi
    done
    printError "$package does not exist in the stack!"
    if ask_yes_or_No "Do you want to look for the $package (say no if you are sure of the name) ?"; then
        search_package $package
        ask_open "What is the name of the package (default is $package)  ?"
        if [ -n $REPLY ]; then package=$REPLY; fi
    fi
    if ask_no_or_Yes "Do you want to add in the stack and install $package ?"; then
        NAME=$package
        ask_open "What package type is it (brew, cask, brew-name, manual, pip, gem ) or leave blanck for detection  ?"
        TYPE=$REPLY
        if [ -z $TYPE ]; then TYPE="dunno"; fi
        if checkPackageExist $TYPE $NAME; then
            if [ $TYPE = "mas" ]; then 
                ask_open "What is the name of this app ?"
                NAME="$REPLY $NAME"
            fi
            ask_open "In what category do you want to put it ? ( $(list_all_categories)) "
            CAT=$REPLY
            if [ -z "$CAT" ]; then CAT="wip"; fi
            ask_open "Give a brief description of this tool: "
            DESC=$REPLY
            ask_open "Give this tools website link for more info: "
            LINK=$REPLY
            newLine="$CAT,$TYPE,$NAME,$DESC,$LINK"
            echo $newLine >> $STACK_CSV
            if ask_yes_or_No "Do you want to commit the add of "$NAME" and push ?"; then
                git -C $SCRIPT_DIR commit -am "Add $NAME: $DESC"
                git -C  $SCRIPT_DIR push -u origin HEAD
            fi
            install_package "$NAME"
        else
            printError "$package does not exist on $TYPE repository!"
        fi
    fi
        
    IFS=' '
}



# # A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

category=""

display_usage() {
  echo
  echo "Usage: ${0##*/} [-h] [-f] [-c <category>] [package]"
  echo " -h             Display usage instructions"
  echo
  echo " [package]      Installation of a specific package / app by its name (or mas id)."
  echo 
  echo " -c <category>  Choose which category to install"
  echo "                => example:  ${0##*/} -c multimedia"
  echo " -l <category>  List all packages in a category. All to display the whole stack"
  echo ""
  printf "Categories:   $(list_all_categories) \n"
  echo ""
  echo " -f             Force packages installation (don't ask confiramtion)"
  echo "                => example:  ${0##*/} -p spotify"
  echo " -s <package>       Search for a specific package/app by its name"
  echo
  
}

while getopts "h?vfc:s:l:" opt; do
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
    s)
        search_package $OPTARG
        exit 0
        ;;
    l)
        list_packages_category $OPTARG
        exit 0
        ;;
    esac
done

# If category install category
if [ -n "$category" ]; then
    install_stack $category
fi

# If package name passed try to install packages
shift $(expr $OPTIND - 1 )
fullStack=true
while test $# -gt 0; do
  install_package $1
  shift
  fullStack=false
done

# else install the whole stack
if $fullStack; then install_stack; fi

