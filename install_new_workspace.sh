#!/bin/bash

function print() {
    printf "\033[0;33m $1 \033[0m"
}
function println() {
    printf "\033[0;33m $1 \033[0m\n"
}

function printError() {
    printf "\033[0;31m $1 \033[0m\n"
}

function ask_yes_or_No() { # The Captial letter is the default one
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) return 0 ;;
        *)     return 1 ;;
    esac
}

function question_ready_to() {
    printf "\033[0;100m !! Tap enter to $1 ... \033[0m"
    read -p "  "
}

function selectAmongValues(){
    select RESULT in $1 
    do
      if [ -z "$RESULT" ]
      then
          echo "Invalid entry. Retry!"
      else
          echo "You have chosen $RESULT"
          break #To end the loop remove otherwise
      fi
    done
}

function getExistingSSHKey() {
    println "Looking for SSH key..."
    files=$( ls ~/.ssh/*.pub)
    selectAmongValues "${files[@]}"
    RESULT=$(cat $RESULT)
}

function generateSSHKey(){
  println "Generating SSH key..."
  read -p "What is your email? "
  ssh-keygen -t rsa -b 4096 -C $REPLY
  getExistingSSHKey 
}

function openLink(){
    case "$OSTYPE" in
        linux*)     xdg-open $1 > /dev/null 2>&1;;
        darwin*)    open $1;;
        *)          printAlert "system not handle";;
    esac
}

function copyContentClipboard(){
    case "$OSTYPE" in
        linux*)     echo "$1" | xclip -selection c ;;
        darwin*)    echo "$1" | pbcopy;;
        *)          printAlert "system not handle";;
    esac
}

function getWorkingBranch () {
  RESULT=$(git branch --all --format='%(refname:short)')
  RESULT="${RESULT//origin\//}"
  selectAmongValues "${RESULT[@]}"
}


if ! ask_yes_or_No "Did you add your ssh key on gihub ?"
then
    keys=$(ls ~/.ssh/*.pub)
    if [ $? -eq 0 ]; then
        getExistingSSHKey
    else
        generateSSHKey
    fi
    println "Your public key is:"
    println "$RESULT"
    copyContentClipboard "$RESULT"
    println "Key copied in the clipboard!"
    question_ready_to "to open github settings"
    openLink https://github.com/settings/ssh/new
fi

if ask_yes_or_No "Do you want to install the full stack ?"
then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ghostwan/workspace-setup/master/install_software_stack.sh)"    
else
    curl https://raw.githubusercontent.com/ghostwan/workspace-setup/master/install_software_stack.sh | bash -s -- -f -c base
fi

# For testing purpose
read -p "Where do you want to clone the workspace ? (current directory): "
path=$REPLY
if [ -n "$path" ]; then
    println "Going to $path"
    eval cd $path
fi

println "Cloning workspace..."
# Replace this repo by your own private workspace, this is my private gws config
# This repo has a file .projects.gws that describe workspace tree
# Each branch is a different configuration, master is the core one then I have: personal, work, doc
# To know more about gws: https://github.com/StreakyCobra/gws 
git clone git@github.com:ghostwan/workspace.git
cd workspace
rm -f .cache.gws*
getWorkingBranch
git checkout $RESULT
gws update
# Replace this part by your configuration
# Finalize my workspace installation by configuring my apps as zsh, alfred, iterm ...
# Import paid app licence and create symlink

if ask_yes_or_No "Do you want to restore apps configuration ?"
then
    # I cloned a repo named configs where I put all my app configs
    config_directory=$(pwd)"/configs"
    cd $config_directory
    
    println "Wich config branch do you want to use?"
    getWorkingBranch
    git checkout $RESULT

    println "---- ZSH CONFIGURATION ----"

    println "install oh my zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    rm $HOME/.zshrc

    println "Create symlink for zshrc: $config_directory/zsh/zshrc_current"
    ln -s $config_directory/zsh/zshrc_current $HOME/.zshrc

    println "Add plugin for oh-my-zsh"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions

    println "---- APPS CONFIGURATION ----"
    FILE=$config_directory/mackup.cfg
    if [ -f "$FILE" ]; then
        println "Restore apps configuration using mackup..."
        ln -s $config_directory/mackup.cfg $HOME/.mackup.cfg
        mackup retore
    else
        printError "No mackup configuration found"
    fi
fi
