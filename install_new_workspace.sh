#!/bin/bash

OPTIND=1 # Reset in case getopts has been used previously in the shell.

full=false

while getopts "h?f" opt; do
    case "$opt" in
    h | \?)
        echo "Usage: install_new_workspace.sh [-h] [-f]
Options:
-h Help: Show this screen 
-f Full: install all apps">&2
        exit 0
        ;;
    f)
        full=true
        ;;
    esac
done

if [ $full = true ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ghostwan/workspace-setup/master/install_software_stack.sh)"    
else
    curl https://raw.githubusercontent.com/ghostwan/workspace-setup/master/install_software_stack.sh | bash -s -- -f -c terminal
fi

echo "Cloning workspace..."
# Replace this by your own private workspace, this is my private gws config
# This repo has a file .projects.gws that describe workspace tree
# Each branch is a different configuration, master is the core one then I have: personal, work, doc
# To know more about gws: https://github.com/StreakyCobra/gws 
git clone https://ghostwan@github.com/ghostwan/workspace
cd workspace
rm -f .cache.gws*
branches=$(git branch -r)
echo "What configuration do you want ? " 
echo "${branches//origin\//}"
read -p "> " branch
git checkout $branch
gws update
# Replace this part by your configuration
# Finalize my workspace installation by configuring my apps as zsh, alfred, iterm ...
# Import paid app licence and create symlink
.bootstrap/configs/install_software_configuration.sh

