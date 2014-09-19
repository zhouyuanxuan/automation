#/bin/bash
# NOTICE:init the centos environment
# TIME:2013-08-17
# AUTHOR:zhouyx
PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
source $scriptsdir/common/function.sh
source $scriptsdir/common/global_variable
source $scriptsdir/common/soft_model.sh
source $scriptsdir/common/init.sh
function_directory_check  $BACKUP
function_directory_check  $scriptsdir
function_directory_check  $basedir
#####################
init_DNS
init_hostname
config_yum_repo
install_soft
close_selinux
function_net_snmp   #class in soft_model.sh
function_nagios		#class in soft_model.sh
init_time
config_ssh 58022
config_inittab
config_iptables
config_ntsysv
init_centos_limit
init_crontab
init_profile
sftp_log