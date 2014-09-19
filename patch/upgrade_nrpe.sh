#!/bin/sh
# NOTICE:shell used to upgrade nrpe
# TIME:2014-03-27
# AUTHOR:dengxd
source $scriptsdir/common/function.sh
source $scriptsdir/common/global_variable
source $scriptsdir/common/soft_model.sh

function_wget nrpe
function_zip_format ${soft_detail}
cd ${basedir}/${soft_detail%.*.*}
./configure --enable-ssl --enable-command-args
make all
make install-daemon
make install-daemon-config
\cp  -a $scriptsdir/model_conf/nrpe.cfg  ${soft_path}/nagios/etc/
ps -ef | grep nrpe | grep -v grep | awk '{print $2}' | xargs kill -9
${soft_path}/nagios/bin/nrpe -c ${soft_path}/nagios/etc/nrpe.cfg -d
