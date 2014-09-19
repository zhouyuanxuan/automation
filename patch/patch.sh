#!/bin/sh
source $scriptsdir/common/global_variable
while :
do
tput clear
cat "$scriptsdir/menu/menu_4.txt"
echo -n -e  " Chose the patching soft!!!>>:"
read chose
case $chose in
	1) sh $scriptsdir/patch/upgrade_nginx.sh
	;;
	2) sh $scriptsdir/patch/upgrade_curl.sh
	;;
	3) sh $scriptsdir/patch/upgrade_squid.sh
	;;
	6) sh $scriptsdir/patch/upgrade_nagios-plugins.sh
	;;
	7) sh $scriptsdir/patch/upgrade_nrpe.sh
	;;
	0)  echo "Bye Bye!"
	 exit 0
	;;
	*) echo "You only allow to chose [1\2\3\4]"
	;;
esac
done
