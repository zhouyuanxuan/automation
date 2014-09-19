#!/bin/sh
# NOTICE:shell used to upgrade nagios-plugins
# TIME:2014-03-27
# AUTHOR:dengxd
source $scriptsdir/common/function.sh
source $scriptsdir/common/global_variable
source $scriptsdir/common/soft_model.sh

nagios_id=`grep nagios /etc/passwd | awk -F ':' '{print $3}'`
if [ "$nagios_id" != "1804" ]; then
#       echo "diff"
       userdel -r nagios
       groupdel nagios
#else
#        echo "same"
fi

function_id_check  nagios 1804 /sbin/nologin
function_wget nagios
function_zip_format ${soft_detail}
cd ${basedir}/${soft_detail%.*.*}
./configure --with-nagios-user=nagios --with-nagios-group=nagios --prefix=${soft_path}/nagios
function_check "nagios configure"
function_install_check nagios
chown nagios.nagios ${soft_path}/nagios
chown -R nagios.nagios ${soft_path}/nagios/libexec
