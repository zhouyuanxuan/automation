#!/bin/bash
# NOTICE:shell used to cut and tar apache log
# TIME:2013-11-07
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
#copy,and clear log
cp ${soft_path}/apache2/logs/* ${backup_path}/log/$date
for file in ${soft_path}/apache2/logs/* 
   do
    file_name=`basename $file`
	if [ $file_name != "httpd.pid" ]
	then
		echo > $file
	fi
done
#tar and backup
for file in ${backup_path}/log/$date/* 
   do 
    file_name=`basename $file`
    echo $file_name
    cd ${backup_path}/log/$date
    /bin/tar -cvzf $file_name.tar.gz $file_name
    rm -rf $file
done
fi
