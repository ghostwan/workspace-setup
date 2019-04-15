# !/bin/sh
# Version 0.0.2

# Install all needed tools on a fresh mac

force_installation=1

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
        return 1
    fi
}

function checkCommandCask() {
    printIsExits $1
    brew cask info $1 >/dev/null 2>&1
    if [ $? -eq 1 ]; then
        return 2
    else
        result="$(brew cask info $1 | awk 'END{print}' | perl -wlne 'print /([a-zA-Z\-\ 1-9]+\.app)/')"
    fi
    if [ -z "$result" ]; then
        result=$1.app
    fi
    resultroot=/Applications/$result
    resulthome=$HOME/Applications/$result
    if [ -d "$resultroot" ] || [ -d "$resulthome" ]; then
        return 0
    else
        return 1
    fi
}

function printDoYouWant() {
    if [ $force_installation -eq 0 ]; then
        return 0
    fi
    read -p "Do you want to install $1? ([y]es, [a]ll or [N]o): "
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

function brewInstall() {
    checkCommand $1
    installBy brew $1 $?
}

function pipInstall() {
    checkCommand $1
    installBy pip $1 $?
}

function masInstall() {
    checkCommandMas $1 $2
    installBy mas $2 $?
}

function caskInstall() {
    checkCommandCask $1
    installBy 'brew cask' $1 $?
}

function manualInstall() {
    printf "\033[0;33m $1 \033[0m ===> \033[0;35m Go to \033[0;34m $2\033[0;35m and download the app \033[0m \n"
}

#########################################################
#########################################################
################## PACKAGES TO INSTALL ##################
#########################################################
#########################################################

#########################################################
################## PACKAGE MANAGER ##################
#########################################################
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

    # pip : package installer for Python
    # https://pypi.org/project/pip/
    checkCommand pip
    if [ $? -ne 0 ]; then
        printInstallingBy "curl" pip
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    else
        printAlreadyInstall
    fi

    # npm : package manager for JS
    # https://www.npmjs.com/
    brewInstall npm

    # mas : A simple command line interface for the Mac App Store
    # https://github.com/mas-cli/mas
    brewInstall mas

}

#########################################################
################## BASE TOOLING ##################
#########################################################
function install_base() {
    # iTerm2 : Powerful emulator
    # https://www.iterm2.com/
    caskInstall iterm2

    # zsh : Powerful unix shell
    # https://doc.ubuntu-fr.org/zsh
    brewInstall zsh

    # git : version control system 
    # https://git-scm.com/
    brewInstall git

    # gws : a git workspace manager
    # https://github.com/StreakyCobra/gws
    brewInstall gws
}
#########################################################
################## TERMINAL TOOLING ##################
#########################################################
function install_terminal() {
    # AutoJump : a faster way to navigate in the filesystem
    # https://github.com/wting/autojump
    brewInstall autojump

    # wget : retrieves content from web servers
    # https://www.wikiwand.com/fr/GNU_Wget
    brewInstall wget

    # htop : an interactive process viewer for Unix systems
    # https://hisham.hm/htop/
    brewInstall htop

    # rmtrash : Put files (and directories) in trash
    # https://github.com/PhrozenByte/rmtrash
    brewInstall rmtrash

    # tree : list directories tree
    # https://www.geeksforgeeks.org/tree-command-unixlinux/
    brewInstall tree

    # ssh-copy-id : use locally available keys to authorise logins on a remote machine
    # https://www.ssh.com/ssh/copy-id
    brewInstall ssh-copy-id

    # sshpass : noninteractive ssh password provider
    # https://linux.die.net/man/1/sshpass
    brewInstall sshpass

    # unrar : unarchiver for rar tool
    # https://www.wikiwand.com/fr/WinRAR
    brewInstall unrar
}

#########################################################
########### generic development ######################
#########################################################
function install_genericDev() {

    # Visual Studio Code : Powerful code editor
    # https://code.visualstudio.com/
    # My setup : https://gist.github.com/ghostwan/fdf88470e77989592e6651c195bdb8ff
    caskInstall visual-studio-code

    # Intellij IDEA : The most porweful IDE
    # https://www.jetbrains.com/idea/
    caskInstall intellij-idea-ce

    # DiffMerge : Visually compare and merge files
    # https://sourcegear.com/diffmerge/
    caskInstall diffmerge

    # SQLite Browser : browser for sql database
    # https://sqlitebrowser.org/
    caskInstall db-browser-for-sqlite
}

#########################################################
########### android development ######################
#########################################################
function install_androidDev() {

    # Android Studio : provides the fastest tools for building apps on every type of Android device.ou
    # https://developer.android.com/studio
    caskInstall android-studio

    # APKtool : A tool for reverse engineering 3rd party, closed, binary Android apps
    # https://ibotpeaches.github.io/Apktool/
    brewInstall apktool

    # pidcat : Colored logcat script which only shows log entries for a specific application package.
    # https://github.com/JakeWharton/pidcat
    brewInstall pidcat

    # Tools to work with android .dex and java .class files
    # https://sourceforge.net/p/dex2jar/wiki/UserGuide/
    brewInstall dex2jar

    # Java decompiler
    # https://www.benf.org/other/cfr/
    brewInstall cfr-decompiler

    # Java decompiler
    # http://java-decompiler.github.io/
    caskInstall jd-gui

    # Hand Shaker : Android file transfer
    # https://www.smartisan.com/
    caskInstall handshaker

    # Vysor : Remote disaply for android
    # https://www.vysor.io/
    caskInstall vysor

    # KeyStore Explorer : Keystore management
    # http://keystore-explorer.org/
    caskInstall keystore-explorer
}

#########################################################
########### python ##################################
#########################################################
function install_pythonDev() {

    # Anaconda : Machine learning environement
    # https://www.anaconda.com/distribution/
    caskInstall anaconda
}

#########################################################
########### CI ######################################
#########################################################
function install_ci() {
    
    # Docker : Container engine
    # https://www.docker.com/
    caskInstall docker

    # Kubernetes : Container orchestration
    # https://kubernetes.io
    brewInstall brew install kubernetes-cli
    caskInstall minikube
}

#########################################################
########### HACKING ################################
#########################################################
function install_hacking() {

    # WireShark : Network analyzer
    # https://www.wireshark.org/
    caskInstall wireshark

    # Mitmproxy : Man in the middle
    # https://mitmproxy.org/
    brewInstall mitmproxy

    # Burp : Pen test
    # https://portswigger.net/burp
    caskInstall burp-suite

}

#########################################################
########### WEB #####################################
#########################################################
function install_web() {

    # Insomnia : Rest client
    # https://insomnia.rest/
    caskInstall insomnia

    # Chromme : Web browser
    # https://www.google.com/chrome/
    caskInstall google-chrome

    # Transmit : FTP Client
    # https://panic.com/transmit/
    caskInstall transmit

    # MullvadVPN : VPN
    # http://mullvad.net/
    caskInstall mullvadvpn

}

#########################################################
########### PRODUCTIVITY ############################
#########################################################
function install_productivity() {

    # Alfed : Poweful spotlight
    # https://www.alfredapp.com/
    caskInstall alfred

    # Dash : API documentation browser
    # https://kapeli.com/dash
    caskInstall dash

    # Dropbox : oneline storage
    # https://www.dropbox.com/
    caskInstall dropbox

    # Evernote : not organize
    # https://evernote.com/
    caskInstall evernote

    # Better Touch tool : powerful shortcuts customisation
    # https://folivora.ai/
    caskInstall bettertouchtool

    # Better Snap tool : manage your window positions and sizes
    # https://folivora.ai/bettersnaptool
    masInstall BetterSnapTool 417375580
}

#########################################################
############## COMMUNICATION ########################
#########################################################
function install_communication() {

    # Skype : visioconference
    # https://www.skype.com
    caskInstall skype

    # Slack : a collaboration hub for work
    # https://slack.com
    caskInstall slack

    # TeamViewer : remote control
    # https://www.teamviewer.com/
    caskInstall teamviewer

    # Shift : Account manager
    # https://tryshift.com/
    manualInstall Shift https://tryshift.com/

}

#########################################################
############## OS  #################################
#########################################################
function install_os() {

    # DaisyDisk : disk analyser
    # https://daisydiskapp.com/
    caskInstall daisydisk
}

#########################################################
############## MULTIMEDIA  #################################
#########################################################
function install_multimedia() {

    # MPlayerX : video player
    # http://mplayerx.org
    caskInstall mplayerx

    # SusbMarine : subtitles downloader
    # https://cocoawithchurros.com/subsmarine.php
    caskInstall subsmarine

    # Transmission : torrent
    # https://transmissionbt.com/
    caskInstall transmission

    # Spotify : Music streaming 
    # https://www.spotify.com/
    caskInstall spotify
}

#########################################################
############## DESIGN  #################################
#########################################################
function install_design() {

    # Sketch : proto desgner
    # https://www.sketch.com/
    caskInstall sketch

    # Sketch : UI designer
    # https://zeplin.io/
    caskInstall zeplin
}

#########################################################
############## FUN  #################################
#########################################################
function install_fun() {

    # Garage Band : music composer
    # https://www.apple.com/fr/mac/garageband/
    masInstall GarageBand 682658836

    # Battle.net : Game center
    # https://www.blizzard.com
    caskInstall battle-net

    # Steam : Game center
    # https://store.steampowered.com
    caskInstall steam
}

# # A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

category=""
fun=1
package=1

while getopts "h?vfc:px" opt; do
    case "$opt" in
    h | \?)
        echo "Usage: install_stack.sh [-h] [-f] [-c <category> | -p <package>]
\nOptions:
-h Show this screen 
-f force app installation
-c choose which category to install (default is all) among :
    base terminal genericDev androidDev pythonDev ci hacking web productivity communication os multimedia design fun  
-p installation of a package 
-x add fun package" >&2
        exit 0
        ;;
    f)
        force_installation=0
        ;;
    c)
        category=$OPTARG
        ;;
    p)
        package=0
        ;;
    x)
        fun=0
        ;;
    esac
done

shift $((OPTIND - 1))
[ "${1:-}" = "--" ] && shift
remaining_args="$@"

if [ -n "$category" ]; then
    install_packageManager
    install_$category
elif [ $package -eq 0 ]; then
    $remaining_args
else
    install_packageManager
    install_base
    install_terminal
    install_genericDev
    install_androidDev
    install_pythonDev
    install_ci
    install_hacking
    install_web
    install_productivity
    install_communication
    install_os
    install_multimedia
    install_design

    if [ $fun -eq 0 ]; then
        install_fun
    fi
fi
