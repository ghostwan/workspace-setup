#!/bin/bash

function print() {
    printf "\033[0;33m $1 \033[0m"
}
function println() {
    printf "\033[0;33m $1 \033[0m\n"
}

function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) answer=true ;;
        *)     answer=false ;;
    esac
}

ask_yes_or_no "Do you want to install the full stack ?"
full_stack=$answer

if [ $full_stack = true ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ghostwan/workspace-setup/master/install_software_stack.sh)"    
else
    curl https://raw.githubusercontent.com/ghostwan/workspace-setup/master/install_software_stack.sh | bash -s -- -f -c base
fi

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
git clone https://ghostwan@github.com/ghostwan/workspace
cd workspace
rm -f .cache.gws*
branches=$(git branch -r)
echo "What configuration do you want ?:" 
branches="${branches/master/master\n}"
println "${branches//origin\//}"
read -p ": " branch
git checkout $branch
gws update
# Replace this part by your configuration
# Finalize my workspace installation by configuring my apps as zsh, alfred, iterm ...
# Import paid app licence and create symlink
ask_yes_or_no "Do you want to configure the software ?"
if [ $answer = true ]; then 
    # I cloned a repo named configs where I put all my app configs
    config_directory=$(pwd)"/configs"

    println "install oh my zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    rm $HOME/.zshrc

    println "Create symlink for zshrc: $config_directory/zsh/zshrc_current"
    ln -s $config_directory/zsh/zshrc_current $HOME/.zshrc

    println "Add plugin for oh-my-zsh"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions
fi
