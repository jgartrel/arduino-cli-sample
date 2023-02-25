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
    all                  make arduino-cli config-file cores libs nrf52_blink_info
    arduino-cli          Install arduino-cli
    clean                Remove all generated files
    config-file          Create local config file and add BOARD_MANAGER_URLS 
    cores                Install the required platform cores
    distclean            Remove all non-versioned files
    libs                 Install required libraries
    nrf52_blink_info     Build nrf52_blink_info
    ```
3.  Run `make all` to install arduino-cli, and begin building the sample sketch
    ```
    $ make all
    ```
