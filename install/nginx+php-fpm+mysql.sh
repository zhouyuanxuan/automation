#!/bin/sh
# NOTICE:Used to auto install nginx && squid
# TIME:2013-08-12
# AUTHOR:zhouyx
# basedir="/home/soft"
scriptsdir="/root/scripts"
source $scriptsdir/common/global_variable
source $scriptsdir/common/function.sh
source $scriptsdir/common/soft_model.sh
cd $basedir
function_comm_soft pcre
function_php_basic_soft
function_comm_soft mhash
function_comm_soft libiconv
function_system_version
if [ ${system_version} = 64 ]
then
	lib_version="64"
fi
ln -s /usr/local/lib/libmcrypt.la /usr/lib${lib_version}/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib${lib_version}/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib${lib_version}/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib${lib_version}/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib${lib_version}/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib${lib_version}/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib${lib_version}/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib${lib_version}/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib${lib_version}/libmhash.so.2.0.1
function_comm_soft mcrypt-2.6
function_nginx_configure
function_nginx_make
function_mysql
ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib${lib_version}/libmysqlclient.so.18
function_php_fpm
