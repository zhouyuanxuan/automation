#!/bin/sh
# NOTICE:common class to used
# TIME:2013-08-12
# AUTHOR:zhouyx
source ${scriptsdir}/common/global_variable
#function version check
function_version_check()
{
	function_file_check ${scriptsdir}/version.old
	rm -rf ${scriptsdir}/version.txt*
	wget -q $url/version.txt -P ${scriptsdir}  
	if [[ `cat ${scriptsdir}/version.txt` != ` cat ${scriptsdir}/version.old ` ]]
	then
		echo -e "\\033[44;37;5m update script version \033[0m" 
		echo "----------------------------------------------------------------------------------------------------------------"
		return 10
	fi
}

#function download and md5
function_wget()
{
	cd ${scriptsdir}
	wget -N $url/softlist.zip -P ${scriptsdir}
	function_zip_format ${scriptsdir}/softlist.zip "password"
    if [ ! -d "${basedir}" ]
    then
            mkdir ${basedir}
    fi
	for  soft in "$@"
	do
		soft_detail=`cat ${basedir}/softlist.txt|grep $soft |awk '{ print $2}'`
		wget  -N -T 8  -t 5 $url/soft/${soft_detail} -P ${basedir}
		# -t 次数，-T 超时时间 -P download路径
		if [ $? -eq 0 ]
		then
			md5=`grep $1 ${basedir}/softlist.txt | awk '{ print $1 }'`
			md5_new=`md5sum ${basedir}/${soft_detail} | awk '{ print $1 }'`
			if [ $md5 != $md5_new ]
			then
				echo "$datetime $1 md5 value is not the same">>${basedir}/soft.log
				exit 0
			fi
		else
			echo "$datetime $1 can not be download!!!check">>${basedir}/soft.log
			exit 0
		fi
		shift
	done
	rm -r ${scriptsdir}/softlist.*
	rm -r ${basedir}/softlist.*
}
#function check the zip format
function_zip_format()
{
	cd ${basedir}
	soft_format=`file $1 |awk -F: '{print $2}'|awk '{ print $1}'`
	if [[ ${soft_format} = bzip2 ]]
	then
		tar -jxvf $1
	elif [[ ${soft_format} = gzip ]]
	then
		tar -zxvf $1
	elif [[ ${soft_format} = Zip ]]
	then
		unzip -o -q -P "$2" $1
	elif [[ ${soft_format} = RPM ]]
	then
		rpm -ivh $1
	else
		echo "$1 is zip format not in the function,you should check it!">>${basedir}/soft.log
	fi
}
#function check the configure processlist success or not 
function_check()
{
	if [ $? -eq 0 ]
	then
		echo "$datetime $1 successful">>${basedir}/soft.log
	else
		echo "$datetime $1 fail">>${basedir}/soft.log
		exit 0
	fi
}
#function check the install processlist success or not 
function_install_check()
{
	function_thread_make  $2 && make install 
	if [ $? -eq 0 ]
	then
		echo "$datetime $1 successful">>${basedir}/soft.log
	else
		echo "$datetime $1 fail">>${basedir}/soft.log
		# return 10
		exit 0
	fi
	cd ${basedir}
}
#function define the system version
function_system_version()
{
	if [ `uname -m` == "x86_64" ]
	then
		system_version="64"
	else
		system_version="32"
	fi
}
#function check the user esxits or not
function_id_check()
{
#webadm:1801 /bin/bash
#oracle:1802 /bin/bash
#mysql:1803 /bin/bash
#nagios:1804 /sbin/nologin
#nagcmd:1805 /sbin/nologin
	if [ $# -eq 3 ]
	then
		id $1 2>&1 >/dev/null
		if [ $? -ne 0 ]
		then
			groupadd $1 -g $2
			useradd -g $1 $1 -u $2 -d /home/$1 -s $3
		fi
	else
		echo "create user format:user:uid:login or nologin">>${basedir}/soft.log
	fi
}
function_directory_check()
{
	if [ ! -d "$1" ]
	then
		mkdir -p $1
	fi
}
function_file_check()
{
	if [ ! -e "$1" ]
	then
		touch $1
	fi
}
#function check the rpm install esxits or not
function_rpm_check()
{
	rpm -q $1 2>&1>/dev/null
	if [ $? -ne 0 ]
	then
		yum install $1 -y
	fi
}
#check user
function_user_check()
{
	if [ $(id -u) != "0" ]
	then
	  echo -e "\033[1;40;31mError: You must be root to run this script, please use root to install this script.\033[0m"
	  exit 0
	fi
}
#get filename exclude .sh
function_get_filename()
{
	if [[ $0 =~ .sh$ ]]
	then
		basename $0|rev|cut -c4-|rev
	else
	   basename $0
	fi
}
#used to update unite the file
function_unite_file()
{
	a="${scriptsdir}/patch.sh ${scriptsdir}/env_centos.sh ${scriptsdir}/env_aliyun.sh ${scriptsdir}/ver.txt"
	for file in $a
	do
		[ -e $file ] && rm -rf $file
	done
}
# used to comfire
function_yesno()
{
	while true; do
		read -p "`echo -e "\033[41;37m$1 ?[Y/N].\033[0m"`" var
		case $var in
			Y|y)
				return 0
				;;
			N|n)
				return 1
				;;
			*)
				echo "Choose Y(y) or N(n)!"
				continue
				;;
		esac
	done
}
# used to generate random strings
# $1: strings length < 40
# $2: null or nonum
function_random_str()
{
	if [ "$2" == "nonum" ]; then
			echo $RANDOM | sha256sum |base64 | head -1 |sed 's/[0-9]//g' | tail -c "$1"
	else
			echo $RANDOM | sha256sum |base64 | head -1 | tail -c "$1"
	fi
}
#function used to defined how many threads to make!
function_thread_make()
{
	CPU_NUM=$(cat /proc/cpuinfo | grep processor | wc -l)
	if [ $CPU_NUM -gt 1 ];then
		make -j$CPU_NUM
	else
		make
	fi
}