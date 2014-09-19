#!/bin/sh
#!/bin/sh
# NOTICE:Used to auto install nginx && squid
# TIME:2013-08-12
# AUTHOR:zhouyx
# basedir="/home/soft"
source $scriptsdir/common/global_variable
source $scriptsdir/common/function.sh
source $scriptsdir/common/soft_model.sh
cd $basedir
function_apache
function_mysql
function_php_basic_soft
function_comm_soft libiconv
function_php_daemon $1

