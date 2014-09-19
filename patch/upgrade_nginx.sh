#!/bin/sh
# NOTICE:shell used to upgrade nginx
# TIME:2013-08-19
# AUTHOR:zhouyx
source $scriptsdir/common/function.sh
source $scriptsdir/common/global_variable
source $scriptsdir/common/soft_model.sh
cd $basedir
function_nginx_configure
mv ${soft_path}/nginx/sbin/nginx ${soft_path}/nginx/sbin/nginx.bak
cp objs/nginx ${soft_path}/nginx/sbin/
${soft_path}/nginx/sbin/nginx -t

function_check "nginx test"
make upgrade
function_check "nginx upgrade"
