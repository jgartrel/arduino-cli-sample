# Arduino CLI Build Demo

This repository demonstrates using Make to build arduino-cli projects with isolated build tools.

### Mac Setup Prerequisites

You will need to execute the following commands to get a clean install of MaxOSX up and running with the tools necessary to work with this repo.

1. Install Xcode Command Line tools:

    ```  
    xcode-select --install
    ```  

### Getting started
1.  Clone this repository 
2.  Run `make` to get a list of things you can do
    ```
    $ make
    arduino-cli          Install arduino-cli
    clean                Remove all generated files
    config-file          Create local config file and add BOARD_MANAGER_URLS 
    cores                Install the required platform cores
    distclean            Remove all non-versioned files
    libs                 Install required libraries
    nrf52_blink_info     Build nrf52_blink_info
    ```
3.  Run `make cores` to install arduino-cli, and the required toolchain
    ```
    $ make cores
    ...
    Installing platform sopor:nrf52@1.3.0...
    Configuring platform....
    Platform sopor:nrf52@1.3.0 installed
    ```
4.  Run `make nrf52_blink_info` to begin building
    ```
    $ make nrf52_blink_info
    ```
