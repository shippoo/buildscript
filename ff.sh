#!/bin/bash
ADB=`which adb`
FASTBOOT=`which fastboot`
INSTALL_LIST=
PIDS=
function install_tools()
{
    add-apt-repository ppa:phablet-team/tools
     apt-get update
    echo $INSTALL_LIST
    apt-get install $INSTALL_LIST
}
function check_tools()
{
    PIDS=`ps -ef |grep adb |grep -v grep | awk '{print $2}'`
if [ -z $PIDS ] 
    then

    if [ -z $ADB ]
    then 
        echo "cant't find adb, install adb-tools;"
        INSTALL_LIST=$INSTALL_LIST" android-tools-adb "
    fi
    if [ -z $FASTBOOT ]
    then
        echo "can't find fastboot, install fastboot-tools"
        INSTALL_LIST=$INSTALL_LIST" android-tools-fastboot "
    fi
    echo "check_tools ---->"$INSTALL_LIST    
    if [ -n INSTALL_LIST ]
    then
        install_tools
    fi
fi
}
check_tools

