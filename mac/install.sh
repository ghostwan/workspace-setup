#!/bin/sh

# Install all needed tools in a fresh mac worktree

################## INSTALL UTILITY ##################

function brewInstall {
    echo "Check if $1 tool exist"
    command -v $1
    if [ $? -ne 0 ]; then
        echo "Installing by brew $1..."
        brew install $1
    else
        echo "Tool $1 already exist"
    fi    
}

function pipInstall {
    echo "Check if $1 tool exist"
    command -v $1
    if [ $? -ne 0 ]; then
        echo "Installing by pip $1..."
        pip install $1
    else
        echo "Tool $1 already exist"
    fi    
}

function caskInstall {
    echo "Check if $1 App exist"
    # how to test if a cask app exist
    # command -v $1
    if [ $? -ne 0 ]; then
        echo "Installing by brew cask $1..."
        brew cask install $1
    else
        echo "App $1 already exist"
    fi    
}

function manualInstall {
    echo "Go to $1 and download the app"
}

function masInstall {
    echo "Check if $1 tool exist"
    command -v $1
    if [ $? -ne 0 ]; then
        echo "Installing by mas $1..."
        mas install $1
    else
        echo "Tool $1 already exist"
    fi    
}

################## PACKAGE MANAGER ##################

# Hombrew : package manager for macOS (or Linux)
# https://brew.sh/index_fr
echo "Check if brew exist..."
command -v brew
if [ $? -ne 0 ]; then
    echo "Installing brew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "Brew already exist!"
fi    

# pip : package installer for Python
# https://pypi.org/project/pip/
echo "Check if pip exist..."
command -v pip 
if [ $? -ne 0 ]; then
    echo "Installing pip..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
else
    echo "Pip already exist!"
fi    

# mas : A simple command line interface for the Mac App Store
# https://github.com/mas-cli/mas
brewInstall mas

################## TERMINAL TOOLING ##################

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
echo "Check if zsh exist..."
command -v zsh 
if [ $? -ne 0 ]; then
    echo "Installing zsh..."
    brew install zsh
    echo "Installing oh my zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    echo "Link zshrc..."
    ln -s zshrc ${HOME}/.zshrc
else
    echo "Zsh already exist!"
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

################## DEV ##################

########### android ###########

# Android Studio : provides the fastest tools for building apps on every type of Android device.
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

########### code ###########

# Visual Studio Code : Powerful code editor
# https://code.visualstudio.com/
# My setup : https://gist.github.com/ghostwan/fdf88470e77989592e6651c195bdb8ff
caskInstall visual-studio-code

# Intellij IDEA : The most porweful IDE
# https://www.jetbrains.com/idea/
caskInstall intellij-idea-ce

########### python ###########

# Anaconda : Machine learning environement
# https://www.anaconda.com/distribution/
caskInstall anaconda

########### CI ###########

# Docker : Container engine
# https://www.docker.com/
caskInstall docker

########### HACKING ###########

# Mitmproxy : Man in the middle proxy
# https://mitmproxy.org/
brewInstall mitmproxy

# Burp : Pen test 
# https://portswigger.net/burp
caskInstall burp-suite

########### WEB ###########

# Insomnia : Rest client
# https://insomnia.rest/
caskInstall insomnia

# Chromme : Web browser
# https://www.google.com/chrome/
caskInstall google-chrome

############## PRODUCTIVITY ##################

# Alfed : Poweful spotlight
# https://www.alfredapp.com/
caskInstall alfred

# Dash : API documentation browser
# https://kapeli.com/dash
caskInstall dash

# Dropbox : oneline storage
# https://www.dropbox.com/
caskInstall dropbox

############## COMMUNICATION ##################

# Slack : a collaboration hub for work
# https://slack.com
caskInstall slack


############## OS UTILITY ##################

# DaisyDisk : disk analyser
# https://daisydiskapp.com/
caskInstall daisydisk

# TODO
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
