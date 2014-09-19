#!/bin/sh
# NOTICE:common soft to used
# TIME:2013-08-12
# AUTHOR:zhouyx
source $scriptsdir/common/function.sh
source $scriptsdir/common/global_variable
function_comm_soft() 
{
	function_wget $1
	function_zip_format ${soft_detail}
	cd ${basedir}/${soft_detail%.*.*}
	./configure 
	function_check "$1 configure"
	function_install_check "$1 install"
	/sbin/ldconfig
}
function_nginx_configure()
{
	function_wget nginx
	function_zip_format ${soft_detail}
	cd ${basedir}/${soft_detail%.*.*}
	function_id_check webadm 1801 /sbin/nologin	
	./configure  --prefix=${soft_path}/nginx --with-http_stub_status_module --with-http_realip_module --with-http_ssl_module
	function_check "nginx configure"
}
function_nginx_make()
{
	function_install_check "nginx install"
	function_directory_check $logbak
	echo "0 0 * * * sh $scriptsdir/tool/cut_nginx_log.sh" >>/var/spool/cron/root
}
function_nginx_web()
{
	echo "doing"
}
function_squid()
{
	function_wget squid
	function_zip_format ${soft_detail}
	cd ${basedir}/${soft_detail%.*.*}
	
	./configure --prefix=$squid_path --enable-gnuregex --enable-async-io=80 \
	--enable-cache-digests --enable-epoll --disable-internal-dns --enable-linux-netfilter \
	--enable-dlmalloc --enable-kill-parent-hack --enable-storeio=aufs,coss,diskd,ufs --with-maxfd=65536
	function_check "squid configure"
	function_install_check "$1"
}
function_squid_sub()
{
	function_directory_check $logbak
	echo "59 23 * * * $squid_path/sbin/squid -k rotate"
}
function_apache()
{
	function_directory_check $logbak
	function_id_check webadm 1801 /bin/bash
	function_wget httpd
	function_zip_format ${soft_detail}
	cd ${basedir}/${soft_detail%.*.*}
	
	 ./configure --prefix=${soft_path}/apache2 --enable-rewrite --enable-deflate --enable-expires --enable-headers \
	 --with-mpm=prefork --enable-so --enable-ssl --with-ssl
	function_check "apache configure"
	function_install_check "apache install"
	echo "0 0 * * * sh $scriptsdir/tool/cut_apache_log.sh" >>/var/spool/cron/root
}
function_php_basic_soft()
{
	yum install -y libxml2
	yum install -y libxml2-devel
	yum install -y bzip2
	yum install -y bzip2-devel
	yum install -y curl
	yum install -y curl-devel
	yum install -y libjpeg
	yum install -y libjpeg-devel
	yum install -y libpng
	yum install -y libpng-devel
	yum install -y freetype-devel
	yum install -y bison
	function_comm_soft libmcrypt
}

###notic this function have a $1 (parm: --disable-fileinfo),for those server which memory less then 1G
function_php_daemon()
{
	function_wget php
	function_zip_format ${soft_detail}
	cd ${basedir}/${soft_detail%.*.*}
	
   ./configure  --prefix=${soft_path}/php5 --with-apxs2=${soft_path}/apache2/bin/apxs --enable-shmop \
   --with-config-file-path=${soft_path}/php5/etc  --with-openssl --with-zlib --with-bz2  --with-gd \
   --enable-sockets --with-curl --with-iconv --enable-inline-optimization --disable-debug  --enable-bcmath \
   --with-mcrypt --enable-sysvmsg  --enable-sysvsem --enable-sysvshm --with-jpeg-dir --with-png-dir \
   --with-freetype-dir --with-mysql=${soft_path}/mysql --with-mysqli --with-pdo-mysql=${soft_path}/mysql  \
   --enable-mbstring   --enable-zip $1
    function_check "php-daemon configure"
	function_install_check "php-daemon install" ZEND_EXTRA_LIBS='-liconv'
} 

function_php_fpm()
{
	function_wget php
	function_zip_format ${soft_detail}
	cd ${basedir}/${soft_detail%.*.*}
	function_id_check webadm 1801 /bin/bash
	
	./configure --prefix=${soft_path}/php5 --with-config-file-path=${soft_path}/php5/etc \
	--with-mysql=${soft_path}/mysql --with-mysqli=${soft_path}/mysql/bin/mysql_config \
	--with-iconv-dir --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir \
	--enable-xml --disable-rpath --enable-discard-path --enable-safe-mode --enable-bcmath \
	--enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers \
	--enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring \
	--with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl \
	--enable-sockets --with-pdo-mysql=${soft_path}/mysql $1
	function_check "php-fpm configure"
	function_install_check "php-fpm install"  ZEND_EXTRA_LIBS='-liconv'
}

#this function chose the version may have problem!!!
function_mysql()
{
	# if [[ `uname -a` =~ "x86_64" ]]
	# then
		# mysql_soft_name="mysql.*x86_64.*"
	# else
		# mysql_soft_name="mysql.*i686.*"
	# fi
	function_system_version
	if [ ${system_version} = 64 ]
	then
		mysql_soft_name="mysql.*x86_64.*"
	else
		mysql_soft_name="mysql.*i686.*"
	fi
	function_wget ${mysql_soft_name}
	function_id_check mysql 1803 /bin/bash
	cd ${soft_path}
	gunzip < $basedir/${soft_detail} |tar xvf -
	ln -s ${soft_detail%.*.*} mysql
	cd mysql
	chown -R mysql .
	chgrp -R mysql .
	${soft_path}/mysql/scripts/mysql_install_db --user=mysql
	chown -R root .
	chown -R mysql data
	cp $scriptsdir/model_conf/my.cnf /etc/my.cnf 
	cp ${soft_path}/mysql/support-files/mysql.server /etc/init.d/mysqld
	${soft_path}/mysql/bin/mysqld_safe --user=mysql &
	function_check "mysql install"
	export PATH=$PATH:${soft_path}/mysql/bin
	echo "export PATH=$PATH:${soft_path}/mysql/bin">>/etc/profile
	source /etc/profile

	# 12 bytes ramdom string as password
    mysqlpwd=`function_random_str 13`
    sleep 3
	
	function_yesno "Will set mysql root password as: $mysqlpwd"

    sed 's/mysqlpassword/'${mysqlpwd}'/g' ${scriptsdir}/model_conf/mysql_secure.sql > $basedir/discuz_secure.sql

    ${soft_path}/mysql/bin/mysql -uroot < $basedir/discuz_secure.sql  >> ${basedir}/soft.log 2>&1 && rm -f $basedir/discuz_secure.sql

    #check
    function_check "Mysql_secure_config action"
}

function_net_snmp()
{
	function_wget snmp
	function_zip_format ${soft_detail}
	cd ${basedir}/${soft_detail%.*.*}
	
	./configure --prefix=${soft_path}/net-snmp --with-mib-modules=ucd-snmp/diskio \
	--with-default-snmp-version=2c \
	--with-sys-location=PRC --with-logfile=/var/log/snmpd.log \
	--with-persistent-directory=/var/net-snmp --disable-snmpv1
	function_check "net-snmp configure"
	function_install_check "net-snmp install"
	function_directory_check /etc/snmp
	cp $scriptsdir/model_conf/snmpd.conf /etc/snmp/
	echo "${soft_path}/net-snmp/sbin/snmpd -c /etc/snmp/snmpd.conf -LS3d -Lf /dev/null -p /var/run/snmpd.pid" >> /etc/rc.local
	${soft_path}/net-snmp/sbin/snmpd -c /etc/snmp/snmpd.conf -LS3d -Lf /dev/null -p /var/run/snmpd.pid
}
#nagios
function_nagios()
{
#nagios-plugin
	function_id_check  nagios 1804 /sbin/nologin
	function_wget nagios
	function_zip_format ${soft_detail}
	cd ${basedir}/${soft_detail%.*.*}
	./configure --with-nagios-user=nagios --with-nagios-group=nagios --prefix=${soft_path}/nagios
	function_check "nagios configure"
	function_install_check "nagios install"
	chown nagios.nagios ${soft_path}/nagios
	chown -R nagios.nagios ${soft_path}/nagios/libexec
#nrpe
	function_wget nrpe
	function_zip_format ${soft_detail}
	cd ${basedir}/${soft_detail%.*.*}
	./configure --enable-ssl --enable-command-args
	make all
	make install-daemon
	make install-daemon-config
	\cp  -a $scriptsdir/model_conf/nrpe.cfg  ${soft_path}/nagios/etc/
	echo "${soft_path}/nagios/bin/nrpe -c ${soft_path}/nagios/etc/nrpe.cfg -d" >> /etc/rc.d/rc.local
	${soft_path}/nagios/bin/nrpe -c ${soft_path}/nagios/etc/nrpe.cfg -d
} 
# Add Virtual Host to Nginx
# $1 : server_name
function_nginx_addserver(){
if [ -z $1 ]; then
    echo "Usage: function_nginx_addserver $server_name"
    exit -1
fi
function_directory_check $soft_path/nginx/conf/sites-enabled
if [[ ! `grep -E '^[ ]*include[ ].*sites-enabled/(\*|'$1')[ ]*;$' $soft_path/nginx/conf/nginx.conf` ]]; then
    sed -i -e '/^[ ]*http[ ]*{/a \\tinclude \ sites-enabled/*' $soft_path/nginx/conf/nginx.conf
fi
:>$soft_path/nginx/conf/sites-enabled/$1
sed 's@$server_name@'$1'@' $scriptsdir/model_conf/sites-enabled/discuz_nginx.default >> $soft_path/nginx/conf/sites-enabled/$1
$soft_path/nginx/sbin/nginx -t && $soft_path/nginx/sbin/nginx -s reload
function_check "Add Nginx Virtual host $1"
}
# Add Virtual Host to Apache
# $1 : server_name
function_httpd_addserver(){
if [ -z $1 ]; then
    echo "Usage: function_httpd_addserver $server_name"
    exit -1
fi
function_directory_check $soft_path/apache2/conf/sites-enabled
if [[ ! `grep -E '^[ ]*include[ ].*sites-enabled/(\*|'$1')[ ]*$' $soft_path/apache2/conf/httpd.conf` ]]; then
    echo "include $soft_path/apache2/conf/sites-enabled/*" >> $soft_path/apache2/conf/httpd.conf
fi
:>$soft_path/apache2/conf/sites-enabled/$1
sed 's@$server_name@'$1'@' $scriptsdir/model_conf/sites-enabled/discuz_httpd.default >> $soft_path/apache2/conf/sites-enabled/$1
$soft_path/apache2/bin/apachectl -t && $soft_path/apache2/bin/apachectl -k graceful
function_check "Add Httpd Virtual host $1"
}
# mysql grants with random user and password
# $1: database
# $2: root_passwd
function_mysql_grants(){
username=`function_random_str 6 nonum`
password=`function_random_str 13`
function_yesno "Grants all privileges on $1 TO user: [ $username ] password: [ $password ]"
${soft_path}/mysql/bin/mysql -uroot -p$2 <<end
GRANT ALL PRIVILEGES ON $1.* TO '$username'@'localhost' identified by '$password';
flush privileges;
end
function_check "Grants privileges for DB $1"
echo "$username $password"
}
#discuz
# $1 server_name
# $2 web server type
function_discuz_init(){
#function_wget Discuz
sitename=$1
docroot=/home/webadm/app/$1
webserver=$2

db_config=$docroot/config/config_global.php
#funciont_unzip Discuz
wget http://download.comsenz.com/DiscuzX/3.2/Discuz_X3.2_SC_UTF8.zip -P $basedir
unzip -o -q $basedir/Discuz_X3.2_SC_UTF8.zip -d $basedir/Discuz
cp -rf $basedir/Discuz/upload/* $docroot/
chown -R webadm.webadm $docroot
# create web conf file
case $webserver in
	"httpd")
		function_httpd_addserver $sitename
		;;
	"nginx")
		function_nginx_addserver $sitename
		;;
	*)
		echo "unrecognized web server!"
		exit 1
		;;
esac

########## Waiting for Discuz installed ########
echo "Please complete the install process by visiting http://$sitename."
echo -e "\033[41;37mNOTICE: After finished install, you should login site http://$sitename/admin.php.\033[0m"
echo "Perhaps need modify your hosts file."
read -p "Waiting for input ... " var
while [[ -f  $docroot/install/index.php ]]
do
        read -p "install/index.php still exists ... " var
done

###### Directory sercurity init ################
echo "Secure Discuz Directorys..."
chown -R webadm.webadm $docroot
find $docroot -type d -exec chmod 550 {} \;
find $docroot -not -type d -exec chmod 440 {} \;
for i in attachment diy sendmail.lock threadcache updatetime.lock log cache template sysdata
do 
    find $docroot/data/$i -type d -exec chmod 750 {} \;
    find $docroot/data/$i -not -type d -exec chmod 640 {} \;
done

for j in $docroot/source/plugin $docroot/config
do 
    find $j -type d -exec chmod 750 {} \;
    find $j -not -type d -exec chmod 640 {} \;
done

############### mysql sercurity init ##############
root_pwd=`grep "dbpw" $db_config |awk -F"'" '{print $8}'`
dbname=`grep "dbname" $db_config |awk -F"'" '{print $8}'`     

echo `function_mysql_grants $dbname $root_pwd` |while read username password
do 
	# update discuz config file
	sed -i -e "s/\(.*dbuser.*\)[^']*'[^']*'\([^']*\)/\1'$username'\2/" -e "s/\(.*dbpw.*\)[^']*'[^']*'\([^']*\)/\1'$password'\2/" $db_config
done

}