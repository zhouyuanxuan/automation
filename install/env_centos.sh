#!/bin/sh
while :
do
tput clear
cat "$scriptsdir/menu/menu_3.txt"
echo -n -e  " Chose !!!>>:"
read chose
case $chose in
	1) sh $scriptsdir/install/nginx_squid.sh
	;;
	2) sh $scriptsdir/install/apache+php+mysql.sh 
	;;
	3) sh $scriptsdir/install/nginx+php-fpm+mysql.sh 
	;;
	4) sh $scriptsdir/install/discuz_init.sh
    ;;
    5)  echo "Bye Bye!"
	 exit 0
	;;
	*) echo "You only allow to chose [1\2\3\4\5]"
	;;
esac
done
