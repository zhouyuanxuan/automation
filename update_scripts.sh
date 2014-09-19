#!/bin/sh
# NOTICE:used to update the scripts
# TIME:2013-09-05
# AUTHOR:zhouyx
source $scriptsdir/common/global_variable
source $scriptsdir/common/function.sh
function_version_check
if [ $? -eq 10 ]
then
	wget -q $url/scripts.zip -P $scriptsdir 
	unzip -o $scriptsdir/scripts.zip -d /root 
	mv -f $scriptsdir/version.txt $scriptsdir/version.old
fi
[ -e /root/scripts/scripts.zip ] && rm -rf /root/scripts/scripts.zip*
rm -rf $scriptsdir/version.txt.*

