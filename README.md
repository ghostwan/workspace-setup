# Workspace setup

This script is installing all the tools / apps / commands that I need for my workspace for Mac OS X.
This script is self contained (doesn't need any other script) and bootstrap itself (install all needed tools for it to work), the only things needed are a shell and curl.
  
It will install four package managers:
 - HomeBrew: package manager for macOS
 - Pip: package manager for Python tools
 - NPM: package manager for Javascript tools
 - Mas : A simple command line interface for the Mac App Store

For each application, if the app is not already install it will ask you wether you want to install it or not.
You can force the installation by giving the "-f" flag. You can add the fun package by giving the "-x" flag.

You can start it on a terminal by doing:

> sh -c "$(curl -fsSL https://raw.githubusercontent.com/ghostwan/workspace/install.sh)"


