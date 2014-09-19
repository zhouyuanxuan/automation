#!/bin/sh
# NOTICE:shell used to upgrade curl
# TIME:2014-04-02
# AUTHOR:zhouyx
source $scriptsdir/common/function.sh
source $scriptsdir/common/global_variable
source $scriptsdir/common/soft_model.sh
cd $basedir
curl_version=`curl -V | grep curl | awk '{ print $2 }'`
if [ "${curl_version}" != "7.34.0" ]
then
	function_comm_soft curl
	\cp -a ${soft_path}/bin/curl /usr/bin/curl
else
	echo "The Newest Version!!!!!"
fi