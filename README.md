# Workspace setup

The `stack` script is installing all the tools and apps that I need for my workspace. 
It's currently handling Mac OS X platform. 

This script is self contained (doesn't need any other script) and bootstrap itself (install all needed tools for it to work), the only things needed are a shell and curl.
  
It will install four package managers:
 - HomeBrew: package manager for macOS
 - Pip: package manager for Python tools
 - NPM: package manager for Javascript tools
 - Mas : A simple command line interface for the Mac App Store

For each application, if the app is not already install it will ask you wether you want to install it or not.
You can force the installation by giving the "-f" flag. You can add the fun package by giving the "-x" flag.

The install_new_workspace script is initializing a brand new workspace, install the stack if needed and configure it.

You can simply install the stack by doing:

Get the stack
> curl -fsSL https://raw.githubusercontent.com/ghostwan/workspace-setup/master/stack.csv -o stack.csv

Start stack installation
> sh -c "$(curl -fsSL https://raw.githubusercontent.com/ghostwan/workspace-setup/master/scripts/stack)"

Or you can start a complete install and configure the workspace by doing:

> sh -c "$(curl -fsSL https://raw.githubusercontent.com/ghostwan/workspace-setup/master/scripts/install_new_workspace)"

**WARNING THIS WILL CONFIGURE MY WORKSPACE, EDIT THE SCRIPT FOR YOUR OWN CONFIGURATION** 

If there is an SSL issue, deactivate SSL verification:
> git config --global http.sslVerify false

# To do next

- Add support of npm
- Add workspace reconfiguration from configs folder