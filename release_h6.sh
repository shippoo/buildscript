#!/bin/bash
source  $HOME/.profile
BUILD_DIR="/workspace/build/"
cd $BUILD_DIR
ANDROID_GIT=git@172.0.0.158:software/h6_oemlhc.git
MODEM_GIT=git@172.0.0.158:software/h6_modem_img.git

TOP_DIR=$(pwd)
ANDROID_DIR=$TOP_DIR/h6_oemlhc/android235_oemlhc
MODEM_DIR=$TOP_DIR/h6_modem_img

PUB_DIR_NAME=
#add-s by wumigen for add nightly build
TODAY_DIR=`date +%F`
NIGHTLY_DIR="/workspace/share/H6_nightly/"$TODAY_DIR"/"
#add-e by wumigen for add nightly build

HW_V=3.0
HC_W_MBIN_V="MBIND3"
W_MBIN_V="WBIN29"

PRODUCT_MODEL="H6C+W"
ANDROID_GET=
ANDROID_V="MAP8035"
MODEM_V="MBIND2"
version_prompt=("Android_version" "Modem_version")
version_list=("ANDROID_V" "MODEM_V")

################################################################################################################################
#define colors for display
FRONT_COLOR_RED=31
FRONT_COLOR_GREEN=32
FRONT_COLOR_BLUE=34
BACK_COLOR_RED=41
BACK_COLOR_GREEN=42
BACK_COLOR_BLUE=44
COLOR_CLEAN=0
 
#set color for display
function set_color()
{
	echo -n -e "\033[$1m"
}



#select option for different version
function option_config()
{
	set_color $BACK_COLOR_GREEN
	echo ""
	echo "##################################"
	echo "# release script version : 1.0.2 #"
	echo "# 	modify by wumigen      #"
	echo "##################################"
	echo ""
	set_color $COLOR_CLEAN	
}
function deal_code()
{
	set_color $BACK_COLOR_RED
		echo "========Begin deal_code============"
	set_color $COLOR_CLEAN	
	set_color $BACK_COLOR_GREEN
	echo "========Begin auto compile!============"
	set_color $COLOR_CLEAN	
	cd $ANDROID_DIR
	git log -8  > $TOP_DIR/android_lg
	cd $TOP_DIR

	ANDROID_V=`head -n 1 android_lg`
	ANDROID_V=${ANDROID_V:7:5}
}

function decide_public_name()
{
	ANDROIDDISP=$ANDROID_V
	MBINDISP=${MODEM_V:4:2}
	PUB_VERSION_NAME=${PRODUCT_MODEL}_${HW_V}_${ANDROIDDISP}${MBINDISP}	
	
	CURDATE=$(date +%y%m%d)
	PUB_DIR_NAME=${PUB_VERSION_NAME}_${CURDATE}
	
	set_color $FRONT_COLOR_BLUE
	echo PUB_DIR_NAME=$PUB_DIR_NAME
	set_color $COLOR_CLEAN	
	
#	export PUB_DIR_NAME
}

#example:compile_deal  "H6C+W"  "guangxi" "nvbak"
function compile_deal()
{
	local TAG=
	if [ "$1" = "H6C+W" ]
	then
		PRODUCT_MODEL="H6C+W"
		MODEM_V=$HC_W_MBIN_V
	else
		if [ "$1" = "H6W" ]
		then
			PRODUCT_MODEL="H6W"
			MODEM_V=$W_MBIN_V
		fi
	fi		
	decide_public_name	
	cd $MODEM_DIR
	git co $MODEM_V	

	cp $MODEM_DIR/mbin/NON-HLOS.bin $ANDROID_DIR/bootable/recovery/modem	
	cd $ANDROID_DIR	
	if [ $3 = "nvbak" ]
	then 
		TAG=${PUB_DIR_NAME}c		
	fi
	if [ $3 = "smt" ]
	then 
		TAG=${PUB_DIR_NAME}smt		
	fi	
	. compile.sh $1  $2 $3 $TAG
	rm -drf $TOP_DIR/tools
    cp -ar $TOP_DIR/h6_oemlhc/tools $TOP_DIR
	test -e out/target/product/msm8660_surf/msm8660_surf-ota-eng.$(whoami)_mmc_incremental.zip && SUCCESS=1
	if [ "$SUCCESS" = "1" ]; then
		cd $TOP_DIR			
		PUB_DIR_NAME=${PUB_DIR_NAME}-$2
#		rm -drf ${PUB_DIR_NAME}
		test -e ${PUB_DIR_NAME}	|| mkdir ${PUB_DIR_NAME}	
	else
		echo "------> build failed ! exit !"
		echo "build failed, exit!" >> log.mkimg
		exit 0
	fi
	
	echo "#################### package ##################"
	pwd	
	PUB_DIR_FOR_MANUFACTURE_NAME=${PUB_DIR_NAME}-$3
	rm -rf $PUB_DIR_FOR_MANUFACTURE_NAME
	mkdir $PUB_DIR_FOR_MANUFACTURE_NAME
	mkdir -p $NIGHTLY_DIR/${PUB_DIR_NAME}
	
	cd ${TOP_DIR} 
	cp  -ar $ANDROID_DIR/emmc_program_3140/*  ${PUB_DIR_FOR_MANUFACTURE_NAME}/	
	mv ${PUB_DIR_FOR_MANUFACTURE_NAME}/update_full.zip ${PUB_DIR_FOR_MANUFACTURE_NAME}/update_full.zip.${PUB_DIR_NAME}c
	cp -ar tools ${PUB_DIR_FOR_MANUFACTURE_NAME}/
	cp -ar $MODEM_DIR/mbin/*  ${PUB_DIR_FOR_MANUFACTURE_NAME}/
	rm ${PUB_DIR_FOR_MANUFACTURE_NAME}/system.img.ext4
	
	if [ $3 = "nvbak" ]
	then
		rm ${PUB_DIR_FOR_MANUFACTURE_NAME}/partition_16G.xml
		rm ${PUB_DIR_FOR_MANUFACTURE_NAME}/rawprogram0_16G.xml
		cp ${PUB_DIR_FOR_MANUFACTURE_NAME}/partition_16G.xml.bakupdate ${PUB_DIR_FOR_MANUFACTURE_NAME}/partition_16G.xml 
		cp ${PUB_DIR_FOR_MANUFACTURE_NAME}/rawprogram0_16G.xml.bakupdate ${PUB_DIR_FOR_MANUFACTURE_NAME}/rawprogram0_16G.xml

		rm ${PUB_DIR_FOR_MANUFACTURE_NAME}/static_nv_bk_dvt2.bin
		rm ${PUB_DIR_FOR_MANUFACTURE_NAME}/dynamic_nv_bk_dvt2.bin
		rar a ${PUB_DIR_FOR_MANUFACTURE_NAME}.rar ${PUB_DIR_FOR_MANUFACTURE_NAME}
		mv ${PUB_DIR_FOR_MANUFACTURE_NAME}.rar $NIGHTLY_DIR/${PUB_DIR_NAME}/${PUB_DIR_NAME}-nvbackup.rar
	fi
	
	if [ $3 = "nobak" ]
	then
		rm ${PUB_DIR_FOR_MANUFACTURE_NAME}/partition_16G.xml
		rm ${PUB_DIR_FOR_MANUFACTURE_NAME}/rawprogram0_16G.xml
		cp ${PUB_DIR_FOR_MANUFACTURE_NAME}/partition_16G.xml.nobak ${PUB_DIR_FOR_MANUFACTURE_NAME}/partition_16G.xml
		cp ${PUB_DIR_FOR_MANUFACTURE_NAME}/rawprogram0_16G.xml.nobak ${PUB_DIR_FOR_MANUFACTURE_NAME}/rawprogram0_16G.xml

		rm ${PUB_DIR_FOR_MANUFACTURE_NAME}/static_nv_bk_dvt2.bin
		rm ${PUB_DIR_FOR_MANUFACTURE_NAME}/dynamic_nv_bk_dvt2.bin		
		cp ${PUB_DIR_FOR_MANUFACTURE_NAME}/static_nv_bk_dvt2.nvbak.bin ${PUB_DIR_FOR_MANUFACTURE_NAME}/static_nv_bk_dvt2.bin
		cp ${PUB_DIR_FOR_MANUFACTURE_NAME}/dynamic_nv_bk_dvt2.nvbak.bin ${PUB_DIR_FOR_MANUFACTURE_NAME}/dynamic_nv_bk_dvt2.bin
		
		cp ${PUB_DIR_FOR_MANUFACTURE_NAME}/boot-imei.img ${PUB_DIR_FOR_MANUFACTURE_NAME}/boot.img
		rar a ${PUB_DIR_FOR_MANUFACTURE_NAME}.rar ${PUB_DIR_FOR_MANUFACTURE_NAME}
		mv ${PUB_DIR_FOR_MANUFACTURE_NAME}.rar $NIGHTLY_DIR/${PUB_DIR_NAME}/${PUB_DIR_NAME}-nvnobak.rar
	fi
	
	if [ $3 = "smt" ]
	then
		rm ${PUB_DIR_FOR_MANUFACTURE_NAME}/partition_16G.xml
		rm ${PUB_DIR_FOR_MANUFACTURE_NAME}/rawprogram0_16G.xml
		cp ${PUB_DIR_FOR_MANUFACTURE_NAME}/partition_16G.xml.nobak ${PUB_DIR_FOR_MANUFACTURE_NAME}/partition_16G.xml
		cp ${PUB_DIR_FOR_MANUFACTURE_NAME}/rawprogram0_16G.xml.nobak ${PUB_DIR_FOR_MANUFACTURE_NAME}/rawprogram0_16G.xml

		rm ${PUB_DIR_FOR_MANUFACTURE_NAME}/static_nv_bk_dvt2.bin
		rm ${PUB_DIR_FOR_MANUFACTURE_NAME}/dynamic_nv_bk_dvt2.bin
		
		cp ${PUB_DIR_FOR_MANUFACTURE_NAME}/static_nv_bk_dvt2.nvbak.bin ${PUB_DIR_FOR_MANUFACTURE_NAME}/static_nv_bk_dvt2.bin
		cp ${PUB_DIR_FOR_MANUFACTURE_NAME}/dynamic_nv_bk_dvt2.nvbak.bin ${PUB_DIR_FOR_MANUFACTURE_NAME}/dynamic_nv_bk_dvt2.bin

		mv ${PUB_DIR_FOR_MANUFACTURE_NAME}/NON-HLOS-SMT.bin ${PUB_DIR_FOR_MANUFACTURE_NAME}/NON-HLOS.bin
		rar a ${PUB_DIR_FOR_MANUFACTURE_NAME}.rar ${PUB_DIR_FOR_MANUFACTURE_NAME}
		mv ${PUB_DIR_FOR_MANUFACTURE_NAME}.rar $NIGHTLY_DIR/${PUB_DIR_NAME}/${PUB_DIR_NAME}-smt.rar
	fi
}


function compile_code()
{
	date_start=$(date +%s)
	compile_deal  "H6C+W"  "guangxi" "nvbak"		
	compile_deal  "H6W"  "guangxi" "nvbak"	
	
	compile_deal  "H6C+W"  "jiujiang" "nvbak"		
	compile_deal  "H6W"  "jiujiang" "nvbak"	

	compile_deal  "H6C+W"  "hunan" "nvbak"		
	compile_deal  "H6W"  "hunan" "nvbak"	

	compile_deal  "H6C+W"  "haerbin" "nvbak"		
	compile_deal  "H6W"  "haerbin" "nvbak"	

	compile_deal  "H6C+W"  "xiamen" "nvbak"		
	compile_deal  "H6W"  "xiamen" "nvbak"	

	compile_deal  "H6C+W"  "hulian" "nvbak"		
	compile_deal  "H6W"  "hulian" "nvbak"	

	compile_deal  "H6C+W"  "keda" "nvbak"		
	compile_deal  "H6W"  "keda" "nvbak"	

#	compile_deal  "H6C+W"  "guangxi" "smt"		
#	compile_deal  "H6W"  "guangxi" "smt"	

#	compile_deal  "H6C+W"  "jiujiang" "smt"		
#	compile_deal  "H6W"  "jiujiang" "smt"	

#	compile_deal  "H6C+W"  "hunan" "smt"		
#	compile_deal  "H6W"  "hunan" "smt"	

#	compile_deal  "H6C+W"  "haerbin" "smt"		
#	compile_deal  "H6W"  "haerbin" "smt"	

#	compile_deal  "H6C+W"  "xiamen" "smt"		
#	compile_deal  "H6W"  "xiamen" "smt"	

#	compile_deal  "H6C+W"  "hulian" "smt"		
#	compile_deal  "H6W"  "hulian" "smt"	
	echo "========end of public==========="	
	echo "========end of public==========="	
	date
	date_end=$(date +%s)
	waste_seconds=$((date_end-date_start))
	waste_minutes=$(($waste_seconds/60))
	echo experienced $waste_minutes minutes.
}
################################################################################
################################################################################

option_config
git clone $ANDROID_GIT
git clone $MODEM_GIT
deal_code
compile_code
mv android_lg $NIGHTLY_DIR
mv build.log $NIGHTLY_DIR
rm -rf !(release_h6.sh|*.rar)



