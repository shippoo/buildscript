#!/bin/bash

#android代码下载路径
ANDROID_GIT=git@172.0.0.158:software/hd508_android.git

#modem下载路径
MODEM_GIT=git@172.0.0.158:software/hd508_modem.git

#编译路径
BUILD_DIR=

#android代码路径
ANDROID_DIR=

#modem文件路径 
MODEM_DIR=

#项目名称
PRODUCT_MODEL="HD508"

#硬件版本号，一位
HW_V="2"

#主版本号， 两位
MAIN_V="10"

#子版本号，两位
SUB_V="01"

#修正版本号，两位
REVISE_V="00"

#日期
TODAY=`date +%Y%m%d`

#夜版编译路径
NIGHTLY_DIR="/workspace/share/HD508_nightly/"$TODAY"/"

#组合版本号名称
PUB_DIR_NAME=${PRODUCT_MODEL}_${HW_V}_${MAIN_V}_${SUB_V}_${REVISE_V}_${TODAY}

#android 最近提交的HASH码 方便溯源
COMMIT_AP=

#modem最近提交的HASH码 方便溯源
COMMIT_CP=

function copy_and_zip()
{
    cd $BUILD_DIR
#复制android编译出来的文件    
    cp -a $OUT/*.img $BUILD_DIR/$PUB_DIR_NAME/
    cp -a $OUT/*.mbn $BUILD_DIR/$PUB_DIR_NAME/
    cp -a $OUT/*.xml $BUILD_DIR/$PUB_DIR_NAME/
    cp -a $OUT/*.zip $BUILD_DIR/$PUB_DIR_NAME/
#编译modem bin 文件
    cp -a $MODEM_DIR/* $BUILD_DIR/$PUB_DIR_NAME/
#删掉拷贝多余的文件
    rm -rf $BUILD_DIR/$PUB_DIR_NAME/ramdisk*
#打包文件
    rar a $PUB_DIR_NAME.rar $BUILD_DIR/$PUB_DIR_NAME
}


function compile_deal()
{
    cd $ANDROID_DIR
#开始编译android代码
    source build/envsetup.sh
#选择user版本或者选择eng版本 choosecombo 1 d508 3 Common
    choosecombo 1 d508 1 Common
    source go.sh -j8
#编译完成后与modem代码一起打包
    copy_and_zip
}


function compile_code()
{
	date_start=$(date +%s)
	date_end=$(date +%s)
    compile_deal
	waste_seconds=$((date_end-date_start))
	waste_minutes=$(($waste_seconds/60))
	echo experienced $waste_minutes minutes.
}


#初始化一些路径，以及调用环境变量
function init()
{
    source ~/.profile
    BUILD_DIR="/workspace/build/"
    cd $BUILD_DIR
    ANDROID_DIR=$BUILD_DIR/hd508_android
    MODEM_DIR=$BUILD_DIR/hd508_modem
    rm -rf $PUB_DIR_NAME
    mkdir $PUB_DIR_NAME
}

#下载代码并设置参数
function clone_code()
{
    git clone $ANDROID_GIT
    cd $ANDROID_DIR
    git log -10 > $BUILD_DIR/android_log
    cd $BUILD_DIR
    git clone $MODEM_GIT
    cd $MODEM_DIR
    git log -10 > $BUILD_DIR/modem_log
    cd $BUILD_DIR
    COMMIT_AP=`head -1 android_log`
    COMMIT_CP=`head -1 modem_log`

}

#设置需要传到代码去的变量
function export_pub()
{
    echo "nothing to export"    
}
function print_vars()
{
	echo -en "\n"
	echo "##################################"
	echo "# release script version : 1.0.0 #"
	echo "#     author  wumigen            #"
	echo "##################################"
    echo -en "\n\n"
    echo "ANDROID_GIT   = "$ANDROID_GIT
    echo "MODEM_GIT     = "$MODEM_GIT
    echo "BUILD_DIR     = "$BUILD_DIR
    echo "ANDROID_DIR   = "$ANDROID_DIR
    echo "MODEM_DIR     = "$MODEM_DIR
    echo "COMMIT_AP     = "$COMMIT_AP
    echo "COMMIT_CP     = "$COMMIT_CP
    echo "ANDROID_GIT   = "$ANDROID_GIT
    echo "PUB_DIR_NAME  = "$PUB_DIR_NAME
    echo -en "\n\n"
	which javac
}
init
clone_code
print_vars
compile_code
