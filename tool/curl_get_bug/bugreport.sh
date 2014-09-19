#!/bin/bash
#初始化
export LANG=zh_CN.GB18030
date=`date +%Y-%m-%d`
date2=`date +%Y%m%d`
# date="2013-07-21"
# date2="20130715"
#############################################################
logdir=/home/logs/getbug
dir=/root/scripts
bug=$dir/bug.txt
maillog=$dir/mail.txt
###############################################################
curlnginx=$dir/curlnginx.php
curldedecms=$dir/curldedecms.php
curlsebug=$dir/curlsebug.php
sebuglog=$logdir/sebuglog$date.log
nginxlog=$logdir/nginxlog.log
dedecmslog=$logdir/dedecmslog$date.log
sebugsub="【注意！sebug.net出现新漏洞】【请速去查看或留意下发邮件】"
nginxsub="【注意！nginx.org出现新补丁】【请速去查看或留意下发邮件】"
dedecmssub="【注意！dedecms出现新补丁】【请速去查看或留意下发邮件】"

function notice()
{
	#caigz
	# mail -s $1 caigz@mail.untx.cn < $2
	# /usr/bin/curl "http://42.121.69.249/msg/msg/caigz.php?info=$1"
	#ALL
	mail -s $1 caigz@mail.untx.cn  zhouyx@mail.untx.cn dengxd@mail.untx.cn yangyh@mail.untx.cn xiesf@untx.com zzf@mail.untx.cn < $2
	/usr/bin/curl "http://42.121.69.249/msg/msg/bugreport.php?info=$1"
}

function checkbug()
{
	# $maillog $buglog $bugsub
	if [ ! -e $2 ]
	then
		cp $1 $2
		notice $3 $1
	elif [ -n "`diff $1 $2`" ]
	then
		cp $1 $2
		notice $3 $1
	fi
}
###############################################################




##curlsebug######################################
/usr/local/php/bin/php $curlsebug |iconv -futf8 -t GB18030 -o $bug
cat $bug |grep Title|grep $date > $maillog
if [ "`cat $maillog`" ]
then
	checkbug $maillog $sebuglog $sebugsub
fi
#清理日志文件
rm -rf $bug   $maillog
#######################################################




##curlnginx######################################
/usr/local/php/bin/php $curlnginx |iconv -futf8 -t GB18030 -o $maillog
checkbug $maillog $nginxlog $nginxsub
#清理日志文件
rm -rf $bug  $maillog
##########################################################


##curldedecms######################################
/usr/local/php/bin/php $curldedecms |sed s/" "/""/g|iconv -futf8 -t GB18030 -o $bug
cat $bug |grep $date2 > $maillog
if [ "`cat $maillog`" ]
then
	checkbug $maillog $dedecmslog $dedecmssub
fi
#清理日志文件
rm -rf $bug  $maillog
##########################################################