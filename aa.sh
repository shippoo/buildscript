#!/bin/bash
#define colors for display
FRONT_COLOR_RED=31
FRONT_COLOR_GREEN=32
FRONT_COLOR_BLUE=34
BACK_COLOR_RED=41
BACK_COLOR_GREEN=42
BACK_COLOR_BLUE=44
COLOR_CLEAN=0

#set color for display
#set color for display
function set_color()
{
    echo -n -e "\033[$1m"
}

function echo_green()
{
    echo -e "\033[32m $1 \033[0m" 
    set_color $COLOR_CLEAN
}

function echo_red()
{
    echo -e "\033[31m $1 \033[0m"
    set_color $COLOR_CLEAN

}

function main()
{
    if [ $# = 2 ];then
        get_action $2    
    elif [ $# = 1 ];then
	    get_action $1
    else
	    echo_red "Usage:$0 <file directory> <rb/rc/rbl>"
	    exit 1
    fi
    action_push $1
}

function get_action()
{
   case $1 in
       rb)
            action="reboot"
            ;;
        rc)
            action="reboot recovery"
            ;;
        rbl)
            action="reboot bootloader"
            ;;
        *)
            action=""
            ;;
    esac
}
function start_adb()
{
    adbsrc=`which adb`
    if [ -z "$adbsrc" ]
    then
        set_color $FRONT_COLOR_GREEN
        echo "###########################################################################"
        echo "#                                                                         #"
        echo "#      can't find adb tools please install adb-tools and fastboot tools   #"  
        echo "#      use below commandsi                                                #"
        echo "#      sudo add-apt-repository ppa:phablet-team/tools                     #"
        echo "#      sudo apt-get update                                                #"
        echo "#      sudo apt-get insall android-tools-adb android-tools-fastboot       #"
        echo "#                                                                         #"
        echo "###########################################################################"
        set_color $COLOR_CLEAN
        exit 1
    else
        sudo `which adb` kill-server
        sudo `which adb` start-server
    fi
}
function action_push()
{
    echo $1
    pids=`ps -ef |grep adb |grep -v grep |awk '{print $2}'`
    echo "adb pids = "$pids
    if [ -z "$pids" ]
    then
        start_adb
    fi

    adb remount
    echo_red "adberro = "$?
    param3=$(echo $1 |awk -F '/' '{print $(NF-2) "/" $(NF-1)}')
    if [ -n "$param3" ]
    then
        echo_green "ready to push "$1" to "$param3
        adb push $1 $param3
    fi

    if [ -n "$action" ]
    then
        echo_green "ready to  "$action
        adb $action
    fi
}
main $*
