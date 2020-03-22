# !/bin/bash
# Version 0.0.2

# Install all needed tools on a fresh mac

force_installation=1
info=""
url=""
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
    printf "    \033[0;100m $info \033[0m => \033[0;34m $url \033[0m \n"
    echo ""
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
    printf "Do you want to install \033[0;33m $1 \033[0m? (\033[0;91m[N]o\033[0m"
    read -p ", [a]ll or [y]es): "
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

function brewInstall() {
    checkCommand $1
    installBy brew $1 $?
}

function brewInstallName() {
    checkCommand $1
    installBy brew $2 $?
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

    println "updating brew..."
    brew update

    # pip : package installer for Python
    # https://pypi.org/project/pip/
    checkCommand pip
    if [ $? -ne 0 ]; then
        printInstallingBy "curl" pip
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    else
        printAlreadyInstall
    fi

    info="npm : package manager for JS"
    url="https://www.npmjs.com/"
    brewInstall npm

    info="mas : A simple command line interface for the Mac App Store"
    url="https://github.com/mas-cli/mas"
    brewInstall mas

}

#########################################################
################## BASE TOOLING ##################
#########################################################
function install_base() {
    info="Powerful terminal"
    url="https://www.iterm2.com/"
    caskInstall iterm2

    info="Powerful unix shell"
    url="https://doc.ubuntu-fr.org/zsh"
    brewInstall zsh

    info="version control system" 
    url="https://git-scm.com/"
    brewInstall git

    info="GUI to commit"
    url="https://git-scm.com/"
    brewInstall git-gui

    info="a git workspace manager"
    url="https://github.com/StreakyCobra/gws"
    brewInstall gws

    info="Application settings backup"
    url="https://github.com/lra/mackup"
    brewInstall mackup 

    info="Put files (and directories) in trash"
    url="https://github.com/PhrozenByte/rmtrash"
    brewInstall rmtrash

    info="command-line JSON processor"
    url="https://stedolan.github.io/jq/"
    brewInstall jq

    info="Password manager"
    url="https://bitwarden.com/"
    caskInstall bitwarden
}
#########################################################
################## TERMINAL TOOLING ##################
#########################################################
function install_terminal() {
    info="a faster way to navigate in the filesystem"
    url="https://github.com/wting/autojump"
    brewInstall autojump

    info="retrieves content from web servers"
    url="https://www.wikiwand.com/fr/GNU_Wget"
    brewInstall wget

    info="an interactive process viewer for Unix systems"
    url="https://hisham.hm/htop/"
    brewInstall htop

    info="list directories tree"
    url="https://www.geeksforgeeks.org/tree-command-unixlinux/"
    brewInstall tree

    info="use locally available keys to authorise logins on a remote machine"
    url="https://www.ssh.com/ssh/copy-id"
    brewInstall ssh-copy-id

    info="noninteractive ssh password provider"
    url="https://linux.die.net/man/1/sshpass"
    brewInstall sshpass

    info="unarchiver for rar tool"
    url="https://www.wikiwand.com/fr/WinRAR"
    brewInstall unrar

    info="Tools to esase the use of github"
    url="https://github.com/github/hub"
    brewInstall hub

    info="Tools to esase the use of gitlab"
    url="https://github.com/zaquestion/lab"
    brewInstallName lab zaquestion/tap/lab
}

#########################################################
########### generic development ######################
#########################################################
function install_genericDev() {

    info="Last java / jdk version"
    url="https://adoptopenjdk.net/"
    caskInstall adoptopenjdk

    info="Powerful code editor"
    url="https://code.visualstudio.com/"
    # My setup : https://gist.github.com/ghostwan/fdf88470e77989592e6651c195bdb8ff
    caskInstall visual-studio-code

    info="The most porweful IDE"
    url="https://www.jetbrains.com/idea/"
    caskInstall intellij-idea-ce

    info="Visually compare and merge files"
    url="https://sourcegear.com/diffmerge/"
    caskInstall diffmerge

    info="SQLite Browser : browser for sql database"
    url="https://sqlitebrowser.org/"
    caskInstall db-browser-for-sqlite

    info="Cacher: Snippet manager"
    url="https://www.cacher.io/"
    caskInstall cacher
}

#########################################################
########### android development ######################
#########################################################
function install_androidDev() {

    info="provides the fastest tools for building apps on every type of Android device"
    url="https://developer.android.com/studio"
    caskInstall android-studio

    info="APKtool : A tool for reverse engineering 3rd party, closed, binary Android apps"
    url="https://ibotpeaches.github.io/Apktool/"
    brewInstall apktool

    info="Colored logcat script which only shows log entries for a specific application package."
    url="https://github.com/JakeWharton/pidcat"
    brewInstall pidcat

    info="Tools to work with android .dex and java .class files"
    url="https://sourceforge.net/p/dex2jar/wiki/UserGuide/"
    brewInstall dex2jar

    info="Java decompiler"
    url="https://www.benf.org/other/cfr/"
    brewInstall cfr-decompiler

    info="Java decompiler"
    url="http://java-decompiler.github.io/"
    caskInstall jd-gui

    info="Hand Shaker : Android file transfer"
    url="https://www.smartisan.com/"
    caskInstall handshaker

    info="Vysor : Remote disaply for android"
    url="https://www.vysor.io/"
    caskInstall vysor

    info="KeyStore Explorer : Keystore management"
    url="http://keystore-explorer.org/"
    caskInstall keystore-explorer

    info="Export remoote for android device"
    url="https://github.com/Genymobile/scrcpy"
    brewInstall scrcpy
}

#########################################################
########### python ##################################
#########################################################
function install_pythonDev() {

    info="Anaconda : Machine learning environement"
    url="https://www.anaconda.com/distribution/"
    caskInstall anaconda
}

#########################################################
########### CI ######################################
#########################################################
function install_ci() {
    
    info="Docker : Container engine"
    url="https://www.docker.com/"
    caskInstall docker

    info="Kubernetes : Container orchestration"
    url="https://kubernetes.io"
    brewInstall kubernetes-cli
    caskInstall minikube
}

#########################################################
########### HACKING ################################
#########################################################
function install_hacking() {

    info="WireShark : Network analyzer"
    url="https://www.wireshark.org/"
    caskInstall wireshark

    info="Mitmproxy : Man in the middle"
    url="https://mitmproxy.org/"
    brewInstall mitmproxy

    info="Burp : Pen test"
    url="https://portswigger.net/burp"
    caskInstall burp-suite

}

#########################################################
########### WEB #####################################
#########################################################
function install_web() {

    info="Insomnia : Rest client"
    url="https://insomnia.rest/"
    caskInstall insomnia

    info="Chrome : Web browser"
    url="https://www.google.com/chrome/"
    caskInstall google-chrome

    info="Transmit : FTP Client"
    url="https://panic.com/transmit/"
    caskInstall transmit

    info="Tor Browser : Anonymous browser"
    url="https://www.torproject.org/"
    caskInstall tor-browser
}

#########################################################
########### PRODUCTIVITY ############################
#########################################################
function install_productivity() {

    info="Alfed : Poweful spotlight"
    url="https://www.alfredapp.com/"
    caskInstall alfred

    info="Dash : API documentation browser"
    url="https://kapeli.com/dash"
    caskInstall dash

    info="Dropbox : oneline storage"
    url="https://www.dropbox.com/"
    caskInstall dropbox

    info="Notion : evernote replacement"
    url="https://www.notion.so/"
    caskInstall notion

    info="Better Touch tool : powerful shortcuts customisation"
    url="https://folivora.ai/"
    caskInstall bettertouchtool

    info="Better Snap tool : manage your window positions and sizes"
    url="https://folivora.ai/bettersnaptool"
    masInstall BetterSnapTool 417375580

    info="MacDown : Markdown editor:"
    url="https://macdown.uranusjr.com/"
    caskInstall macdown

}

#########################################################
############## COMMUNICATION ########################
#########################################################
function install_communication() {

    info="Skype : visioconference"
    url="https://www.skype.com"
    caskInstall skype

    info="Slack : a collaboration hub for work"
    url="https://slack.com"
    caskInstall slack

    info="TeamViewer : remote control"
    url="https://www.teamviewer.com/"
    caskInstall teamviewer

    info="Shift : Account manager"
    url="https://tryshift.com/"
    manualInstall Shift https://tryshift.com/

    info="Tunnel Blick : VPN"
    url="https://tunnelblick.net/"
    caskInstall tunnelblick

    info="Discord: Gamer chat"
    url="https://discordapp.com/"
    caskInstall discord
}

#########################################################
############## OS  #################################
#########################################################
function install_os() {

    info="DaisyDisk : disk analyser"
    url="https://daisydiskapp.com/"
    caskInstall daisydisk

    info="The unarchiver: multi zip unarchiver"
    url="https://theunarchiver.com/"
    caskInstall the-unarchiver
}

#########################################################
############## MULTIMEDIA  #################################
#########################################################
function install_multimedia() {

    info="MPlayerX : video player"
    url="http://mplayerx.org"
    caskInstall mplayerx

    info="VLC : video player"
    url="https://www.videolan.org/vlc/index.fr.html"
    caskInstall vlc

    info="SusbMarine : subtitles downloader"
    url="https://cocoawithchurros.com/subsmarine.php"
    caskInstall subsmarine

    info="Transmission : torrent"
    url="https://transmissionbt.com/"
    caskInstall transmission

    info="Spotify : Music streaming "
    url="https://www.spotify.com/"
    caskInstall spotify

    info="Whatsapp : Music streaming" 
    url="https://www.whatsapp.com/"
    caskInstall whatsapp

    info="Molotov : TV"
    url="https://www.molotov.tv/"
    caskInstall molotov

    info="Youtube-dl : Youtube downloader"
    url="https://ytdl-org.github.io/youtube-dl/index.html"
    brewInstall youtube-dl

    info="ffmepg : record library"
    url="https://ffmpeg.org/"
    brewInstall ffmepg

    info="popcorntime : Watch movie and tv shows"
    url="https://popcorntime.app/fr/"
    manualInstall PopcornTime https://popcorntime.app/fr/
}

#########################################################
############## DESIGN  #################################
#########################################################
function install_design() {

    info="Sketch : proto desgner"
    url="https://www.sketch.com/"
    caskInstall sketch

    info="Sketch : UI designer"
    url="https://zeplin.io/"
    caskInstall zeplin
}

#########################################################
############## FUN  #################################
#########################################################
function install_fun() {

    info="Garage Band : music composer"
    url="https://www.apple.com/fr/mac/garageband/"
    masInstall GarageBand 682658836

    info="Battle.net : Game center"
    url="https://www.blizzard.com"
    caskInstall battle-net

    info="Steam : Game center"
    url="https://store.steampowered.com"
    caskInstall steam
}

# # A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

category=""
fun=1
package=1

display_usage() {
  echo
  echo "Usage: ${0##*/} [-h] [-f] [-c <category> | -p <package>]"
  echo
  echo " -h             Display usage instructions"
  echo
  echo " -f             Force app installation"
  echo " -x             Add fun package"
  echo " -p <package>   Installation of a specific package with brewInstall / caskInstall / masInstall / pipInstall "
  echo "                => example:  ${0##*/} -p caskInstall spotify"
  echo ""
  echo " -c <category>  Choose which category to install (default is all) among : base terminal genericDev androidDev pythonDev ci 
                                                                          hacking web productivity communication os multimedia design fun"
  echo "                => example:  ${0##*/} -c multimedia"
  echo
}


while getopts "h?vfc:px" opt; do
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
    install_packageManager
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
