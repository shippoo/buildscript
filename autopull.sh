#!/bin/bash
source ~/.bashrc
source /etc/profile
cd /workspace/opengrokSource
TOP=`pwd`
LOGFILE=$TOP/log.txt
echo ""
echo ""
echo "begin to do autopull ">>$TOP/log.txt
SELECT_PRJ=`ls -d *\/`
for var in $SELECT_PRJ;do
 	cd $var;
	echo "">>$LOGFILE
	echo " ">>$LOGFILE
	echo "begin to pull---------> "$var>>$LOGFILE
	/usr/local/bin/git pull;
	/usr/local/bin/git log -3 >>$LOGFILE
	cd $TOP;
done
/opt/opengrok/bin/OpenGrok update
DATE=`date`
echo "">>$LOGFILE
echo "git pull and opengrok update completed in  "$DATE >>$LOGFILE
