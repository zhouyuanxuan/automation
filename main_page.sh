#!/bin/sh
# NOTICE:The whole entrance,the main_page
# TIME:2014-03-10
# AUTHOR:zhouyx
scriptsdir="/root/scripts"
source $scriptsdir/common/global_variable
source $scriptsdir/common/function.sh
source $scriptsdir/common/soft_model.sh
function_rpm_check wget
function_unite_file
while :
do
tput clear
############################################################################################################					 
	echo "version:`[ -e $scriptsdir/version.old ] && cat $scriptsdir/version.old`"
	cat "$scriptsdir/menu/menu_1.txt"	
	function_version_check
	echo -n -e  " Chose what setup to do!!![1\2\3\4]>>:"
	read chose
	case $chose in
		1)
		tput clear
		cat "$scriptsdir/menu/menu_2.txt"	
		echo -n -e  "choice system>>:"
		read system
		case $system in
			1) sh $scriptsdir/install/init_aliyun.sh
			;;
			2) sh $scriptsdir/install/init_centos.sh
			;;
			3) sh $scriptsdir/main_page.sh
			;;			
		esac
		;;
		2)	
		tput clear
		cat "$scriptsdir/menu/menu_2.txt"	
		echo -n -e  "choice system>>:"
		read system
		case $system in
			1) sh $scriptsdir/install/env_aliyun.sh
			;;
			2) sh $scriptsdir/install/env_centos.sh
			;;
			3) sh $scriptsdir/main_page.sh
			;;			
		esac
		;;
		3) sh $scriptsdir/patch/patch.sh
		;;
		4) sh $scriptsdir/update_scripts.sh  
		;;
		5)  echo "Bye Bye!"
		 exit 0
		;;
		*) echo "You only allow to chose [1\2\3\4]"
		;;
	esac

done
