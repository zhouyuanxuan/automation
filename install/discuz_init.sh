#!/bin/sh
# NOTICE:Used to discuz's security Initialization
# TIME:2014-05-28
# AUTHOR:xiesf
source $scriptsdir/common/global_variable
source $scriptsdir/common/function.sh
source $scriptsdir/common/soft_model.sh
cd $basedir

install_status=0;
echo "====================================================="
echo " This script used to security discuz during install  "
echo "  You should Make sure UCenter server is available   "
echo "          NOTICE: Install discuz alone !!!           "
echo "====================================================="
##### start ######
## get servername
read -p "Please input hostname for discuz website.[discuz.localhost.com]" website_name
if [[ -z $website_name ]]; then
        website_name="discuz.localhost.com"
fi

## get document_root
echo "Discuz Will install into dir [$web_path/app/$website_name]"
function_directory_check $web_path/app/$website_name


#### check web server
echo "Checking web server status..."
if [[ `netstat -tpln |grep httpd` ]]; then
    install_status=`expr $install_status + 1`
fi
if [[ -f $soft_path/php5/bin/php ]]; then
        install_status=`expr $install_status + 2`
fi
if [[ `netstat -tpln |grep nginx` ]]; then
        install_status=`expr $install_status + 4`
fi
if [[ `netstat -tpln |grep php-fpm` ]]; then
        install_status=`expr $install_status + 8`
fi

case $install_status in
        3)
                echo "Httpd running and php installed."
                web_ser=httpd
                ;;
        14)
                echo "Nginx and php-fpm running."
                web_ser=nginx
                ;;
        *)
                echo "No available web server. Please Check."
                echo "Is httpd+php or nginx+php-fpm installed? Get it worked!"
                exit 1
                ;;
esac

function_discuz_init $website_name $web_ser 
