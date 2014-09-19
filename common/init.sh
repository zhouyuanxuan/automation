#!/bin/sh
# NOTICE:init the environment
# TIME:2014-02-18
# AUTHOR:zhouyx
init_DNS()
{
	set dns
	echo "options timeout:1 attempts:1 rotate" > /etc/resolv.conf
	echo "nameserver 114.114.114.114" >> /etc/resolv.conf
	echo "nameserver 223.5.5.5" >> /etc/resolv.conf
	echo "nameserver 202.96.128.68" >> /etc/resolv.conf
	echo "nameserver 8.8.8.8" >> /etc/resolv.conf
	echo "$server_addr g9.untx.cn">> /etc/hosts
	
}
init_time()
{
        NTP_SVR_1="time.windows.com"
        NTP_SVR_0="ntp.api.bz"
        ntpdate $NTP_SVR_0
        if [[ $? != "0" ]]
        then
                sleep 2
                ntpdate $NTP_SVR_1
                if [[ $? != "0" ]]
                then
                        echo "[$(date)] adj_time(): ntpdate error, check your network and dns!!!"
                        exit
                fi
        fi

        hwclock -w
}
config_inittab()
{
        cp -fpv /etc/inittab $BACKUP

        sed -i 's/^id.*$/id:3:initdefault:/' /etc/inittab
        sed -i 's|^ca::ctrlaltdel:/sbin/shutdown -t3 -r now$|#ca::ctrlaltdel:/sbin/shutdown -t3 -r now|' /etc/inittab
        if [ -e "/etc/init/control-alt-delete.conf" ]
        then
            cp -fpv /etc/init/control-alt-delete.conf $BACKUP
            sed -i 's|^start on control-alt-delete$|#start on control-alt-delete|' /etc/init/control-alt-delete.conf
            sed -i 's|^exec /sbin/shutdown -r now "Control-Alt-Delete pressed"$|#exec /sbin/shutdown -r now "Control-Alt-Delete pressed"|' /etc/init/control-alt-delete.conf
        fi
}


#init iptables
config_iptables()
{
/etc/init.d/iptables stop

sh /root/iptables.sh
}
#init server
config_ntsysv()
{
        local_keep_proc="auditd cpuspeed crond fail2ban microcode_ctl network sshd syslog rsyslog snmpd irqbalance"

        for procs in $(chkconfig --list | grep 3:on | awk '{print $1}')
        do
                if ! echo $local_keep_proc | grep "\<$procs\>" > /dev/null 2>&1
                then

                  chkconfig --level 3 $procs off
                fi
        done

        chkconfig --list | grep 3:on
}

###system parameter ! modprobe bridge
init_centos_limit()
{
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_max_syn_backlog = 6553600
net.core.netdev_max_backlog =  32768
net.core.somaxconn = 32768
net.ipv4.ip_conntrack_max = 6553600
fs.file-max = 65535

EOF
sysctl -p
}
init_hostname()
{
	echo -n -e "ENTER THE HOSTNAME FOR THIS MACHINE:"
	read host_name
	hostname $host_name
	sed -i 's/^HOSTNAME=.*$/HOSTNAME='"$host_name"'/' /etc/sysconfig/network
}
init_crontab()
{
cat >> /var/spool/cron/root << EOF
*/30 * * * * /usr/sbin/ntpdate -u ntp.api.bz &> /dev/null
10 1 * * * find /var/spool/clientmqueue/ -type f -mtime +10|xargs -i rm -rf {}
0 0 * * * /bin/sh /root/iptables.sh
EOF
/etc/init.d/crond restart
}
init_profile()
{
cat >>/etc/profile<<EOF
ulimit -n 65535
export HISTTIMEFORMAT="%F %T "
export scriptsdir="/root/scripts"
EOF
source /etc/profile
echo "/usr/local/lib" >> /etc/ld.so.conf
}
sftp_log()
{
	sed -i '/^local7.*$/a auth,authpriv.*                                         /var/log/sftp.log' /etc/rsyslog.conf 
	sed -i 's/sftp-server/& -l INFO -f AUTH/g' /etc/ssh/sshd_config
	/etc/init.d/sshd restart
	/etc/init.d/rsyslog restart
}
#init sshd
config_ssh()
{
        cp -fpv /etc/ssh/sshd_config $BACKUP
		sed -i 's/#Port 22/Port '$1'/g' /etc/ssh/sshd_config 
		sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
        /etc/init.d/sshd reload
}
#close selinux
close_selinux()
{
        cp -fpv /etc/selinux/config $BACKUP

        sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config

}
install_soft()
{ 
  yum install gcc -y
  yum install  automake -y
  yum install autoconf -y
  yum install libtool -y
  yum install make -y
  yum install gcc-c++ -y 
  yum install vixie-cron -y
  yum install crontabs -y
  yum install wget -y
  yum install ntpdate -y
  yum install zlib	-y
  yum install telnet -y
  yum install file -y
  yum install ntp -y
  yum install man -y
  yum install traceroute -y
  yum install bind-utils -y
  yum install iptraf -y
  yum install lsof -y
  yum install tcpdump -y
 #used for iostat
  yum install sysstat -y
 #used for nagios
  yum install openssl-devel -y
 #used for dailybak mail
  yum install sharutils -y
  yum install zip -y
 #used for snmpd
  yum install perl-ExtUtils-MakeMaker -y
  yum install file-libs -y
}
init_aliyun_limit()
{
sed -i 's/^net.bridge.bridge-nf/#net.bridge.bridge-nf/' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_max_syn_backlog = 6553600
net.core.netdev_max_backlog =  32768
net.core.somaxconn = 32768
fs.file-max = 65535

EOF
sysctl -p
}
config_yum_repo()
{
	mv /etc/yum.repos.d/CentOS-Base.repo $BACKUP
	\cp $scriptsdir/model_conf/CentOS-Base.repo /etc/yum.repos.d/
}