#~/bin/bash
ac_root=/workspace/H6/qcom

ac_date=20140422

ac_branch=ics_chocolate 

build_id=M8260AAABQNLZA30170

ac_xml=M8260AAABQNLZA30170.xml

mkdir -pv $ac_root/$ac_branch-$build_id-$ac_date

cd $ac_root/$ac_branch-$build_id-$ac_date

 repo init -u git://codeaurora.org/platform/manifest.git -b $ac_branch -m  $ac_xml

nohup  repo sync
