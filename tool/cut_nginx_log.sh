#!/bin/bash
# NOTICE:used to backup nginx log
# TIME:2013-09-03
# AUTHOR:zhouyx
scriptsdir="/root/scripts"
source $scriptsdir/common/function.sh
source $scriptsdir/common/global_variable
date=$(date -d "yesterday" +"%Y-%m-%d")
function_directory_check ${backup_path}
function_directory_check ${backup_path}/log
mkdir ${backup_path}/log/$date
if [ $? != 0 ]
then
     echo "making dir is fail! it will exit"
     exit 0
else
	mv ${soft_path}/nginx/logs/*.log ${backup_path}/log/$date
	${soft_path}/nginx/sbin/nginx -s reload
	for file in ${backup_path}/log/$date/* 
	do 
		file_name=`basename $file`
		cd ${backup_path}/log/$date
		/bin/tar -cvzf $file_name.tar.gz $file_name
		rm -rf $file
	done
fi
