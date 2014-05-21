#!/bin/bash

#使用adb reboot bootloader进入bootloader模式后
#使用fastboot flash usbmsc usbdisk.img进行烧录


#定义需要制作的usb镜像的源目录
USB_DIR="/workspace/usbdisk/"

#定义挂载点
MOUNT_DIR="/mnt/usb1/"

#定义临时镜像
TEMP_USB=$(pwd)/"usbdisk.tmp"

#创建临时镜像
mkfs.vfat -n "Internal SD" -F 32 -C $TEMP_USB 11534336

#创建挂载点
sudo mkdir $MOUNT_DIR

#挂载临时镜像
sudo mount -t vfat $TEMP_USB $MOUNT_DIR -o iocharset=utf8

#将源目录中的文件拷贝至挂载目录中
sudo cp -r  $USB_DIR/* $MOUNT_DIR

#卸载挂载点
sudo umount $MOUNT_DIR

#打包成img文件 coumt/1024 为多少M 这个值要大于你制作镜像的大小
dd if=$TEMP_USB of=usbdisk.img bs=1024 count=122880

#删除临时目录
rm -rf $TEMP_USB
echo "###############  usbdisk.img制作完成  ###########"

