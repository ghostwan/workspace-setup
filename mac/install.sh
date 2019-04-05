#!/bin/sh

# Install all needed tools in a fresh mac worktree

#########################################################
################## INSTALL UTILITY ##################
#########################################################
function printIsExits {
    printf "is \033[0;33m $1 \033[0m installed ? "
}

function printAlreadyInstall {
    printf "\033[0;32mOK\033[0m\n"
}

function printInstallingBy {
    printf "\033[0;34mNO\033[0m\n"
    printf "\033[1mInstalling by $1 $2...\033[0m\n"
}

function checkCommand {
    printIsExits $1
    command -v $1 > /dev/null 2>&1
}

function brewInstall {
    checkCommand $1
    if [ $? -ne 0 ]; then
        printInstallingBy "brew" $1
        brew install $1
    else
        printAlreadyInstall $1
    fi
}

function pipInstall {
    checkCommand $1
    if [ $? -ne 0 ]; then
        printInstallingBy "pip" $1
        pip install $1
    else
        printAlreadyInstall $1
    fi
}

function caskInstall {
    printIsExits $1
    result="$(brew cask info $1 | awk 'END{print}' | perl -wlne 'print /([a-zA-Z\-\ ]+\.app)/')"
    result=/Applications/$result
    if [ ! -d "$result" ]; then
        printInstallingBy "brew cask" $1
        brew cask install $1
    else
        printAlreadyInstall $1
    fi
}

function masInstall {
    checkCommand $1
    if [ $? -ne 0 ]; then
        printInstallingBy "mas" $1
        mas install $1
    else
        printAlreadyInstall $1
    fi
}

function manualInstall {
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
function install_packageManager {
    # Hombrew : package manager for macOS (or Linux)
    # https://brew.sh/index_fr
    checkCommand brew
    if [ $? -ne 0 ]; then
        printInstallingBy "curl" brew
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        printAlreadyInstall brew
    fi
    
    # pip : package installer for Python
    # https://pypi.org/project/pip/
    checkCommand pip
    if [ $? -ne 0 ]; then
        printInstallingBy "curl" pip
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    else
        printAlreadyInstall pip
    fi
    
    # mas : A simple command line interface for the Mac App Store
    # https://github.com/mas-cli/mas
    brewInstall mas
    
    # npm : package manager for JS
    # https://www.npmjs.com/
    brewInstall npm
}

#########################################################
################## TERMINAL TOOLING ##################
#########################################################
function install_terminalTooling {
    # iTerm2 : Powerful emulator
    # https://www.iterm2.com/
    caskInstall iterm2
    
    # AutoJump : a faster way to navigate in the filesystem
    # https://github.com/wting/autojump
    brewInstall autojump
    
    # zsh : Powerful unix shell
    # https://doc.ubuntu-fr.org/zsh
    # Oh My Zsh: Framework for managing your zsh configuration
    # https://github.com/robbyrussell/oh-my-zsh
    checkCommand zsh
    if [ $? -ne 0 ]; then
        printInstallingBy "brew" zsh
        brew install zsh
        printInstallingBy "curl" "oh my zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        echo "Link zshrc..."
        ln -s zshrc ${HOME}/.zshrc
    else
        printAlreadyInstall zsh
    fi
    
    # wget : retrieves content from web servers
    # https://www.wikiwand.com/fr/GNU_Wget
    brewInstall wget
    
    # htop : an interactive process viewer for Unix systems
    # https://hisham.hm/htop/
    brewInstall htop
    
    # rmtrash : Put files (and directories) in trash
    # https://github.com/PhrozenByte/rmtrash
    brewInstall rmtrash
    
    # ssh-copy-id : use locally available keys to authorise logins on a remote machine
    # https://www.ssh.com/ssh/copy-id
    brewInstall ssh-copy-id
    
    # sshpass : noninteractive ssh password provider
    # https://linux.die.net/man/1/sshpass
    brewInstall sshpass
}

#########################################################
########### generic development ######################
#########################################################
function install_genericDevTools {
    # Visual Studio Code : Powerful code editor
    # https://code.visualstudio.com/
    # My setup : https://gist.github.com/ghostwan/fdf88470e77989592e6651c195bdb8ff
    caskInstall visual-studio-code
    
    # Intellij IDEA : The most porweful IDE
    # https://www.jetbrains.com/idea/
    caskInstall intellij-idea-ce
}

#########################################################
########### android development ######################
#########################################################
function install_androidDevTools {
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
}

#########################################################
########### python ##################################
#########################################################
function install_pythonDevTools {
    # Anaconda : Machine learning environement
    # https://www.anaconda.com/distribution/
    caskInstall anaconda
}

#########################################################
########### CI ######################################
#########################################################
function install_ciTools {
    # Docker : Container engine
    # https://www.docker.com/
    caskInstall docker
}

#########################################################
########### HACKING ################################
#########################################################
function install_hackingTools {
    # Mitmproxy : Man in the middle proxy
    # https://mitmproxy.org/
    brewInstall mitmproxy
    
    # Burp : Pen test
    # https://portswigger.net/burp
    caskInstall burp-suite
}

#########################################################
########### WEB #####################################
#########################################################
function install_webTools {
    # Insomnia : Rest client
    # https://insomnia.rest/
    caskInstall insomnia
    
    # Chromme : Web browser
    # https://www.google.com/chrome/
    caskInstall google-chrome
    
}

#########################################################
########### PRODUCTIVITY ############################
#########################################################
function install_productivityTools {
    # Alfed : Poweful spotlight
    # https://www.alfredapp.com/
    caskInstall alfred
    
    # Dash : API documentation browser
    # https://kapeli.com/dash
    caskInstall dash
    
    # Dropbox : oneline storage
    # https://www.dropbox.com/
    caskInstall dropbox
    
    # Better Snap tool : manage your window positions and sizes
    # https://folivora.ai/bettersnaptool
    masInstall 417375580
}

#########################################################
############## COMMUNICATION ########################
#########################################################
function install_communicationTools {
    # Slack : a collaboration hub for work
    # https://slack.com
    caskInstall slack
    
    # Shift :
    # https://tryshift.com/
    manualInstall Shift https://tryshift.com/
    
}

#########################################################
############## OS  #################################
#########################################################
function install_osTools {
    # DaisyDisk : disk analyser
    # https://daisydiskapp.com/
    caskInstall daisydisk
}

# TODO
    # Better Snap tools
    # DiffMerge.app
    # Transmit.app
    # Vysor.app
    # KeyStore Explorer.app (http://keystore-explorer.org/ )
    # MPlayerX.app
    # Sketch.app
    # Skype.app
    # sqlitebrowser.app
    # Sublime Merge.app
    # SubsMarine.app
    # TeamViewer.app
    # Transmission.app

if [ "$#" -eq 1 ]; then
    install_$1
elif [ "$#" -eq 2 ]; then
    $1 $2
else
    install_packageManager
    install_terminalTooling
    install_genericDevTools
    install_androidDevTools
    install_pythonDevTools
    install_ciTools
    install_hackingTools
    install_webTools
    install_productivityTools
    install_communicationTools
    install_osTools
fi

