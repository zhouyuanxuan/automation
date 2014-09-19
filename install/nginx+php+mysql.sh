#!/bin/sh
# NOTICE:Used to auto install nginx && squid
# TIME:2013-08-12
# AUTHOR:zhouyx
# basedir="/home/soft"
source $scriptsdir/common/global_variable
source $scriptsdir/common/function.sh
source $scriptsdir/common/soft_model.sh
cd $basedir
function_comm_soft pcre
function_nginx_configure
function_nginx_make
function_mysql
