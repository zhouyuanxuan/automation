#!/bin/sh
# NOTICE:shell used to upgrade squid
# TIME:2014-05-21
# AUTHOR:zhouyx
source $scriptsdir/common/function.sh
source $scriptsdir/common/global_variable
source $scriptsdir/common/soft_model.sh
cd $basedir
function_squid "squid upgrade"
