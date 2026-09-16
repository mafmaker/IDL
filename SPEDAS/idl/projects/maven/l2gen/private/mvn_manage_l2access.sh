#!/bin/csh

#An muser cronjob for L2 .htaccess
# 27 * * * * /bin/csh /home/muser/export_socware/idl_socware/projects/maven/l2gen/private/mvn_manage_l2access.sh >/dev/null 2>&1

source /usr/local/setup/setup_idl8.3		# IDL
setenv BASE_DATA_DIR /disks/data/
setenv ROOT_DATA_DIR /disks/data/
#IDL SETUP for MAVEN
if !( $?IDL_BASE_DIR ) then
    setenv IDL_BASE_DIR ~/export_socware/idl_socware
endif

if !( $?IDL_PATH ) then
   setenv IDL_PATH '<IDL_DEFAULT>'
endif

setenv IDL_PATH $IDL_PATH':'+$IDL_BASE_DIR

# create a date to append to batch otput
setenv datestr `date +%Y%m%d%H%M%S`
set suffix="$datestr"

cd /home/muser/export_socware/idl_socware/projects/maven/l2gen/private
rm -f call_mvn_manage_l2_access.out
idl call_mvn_manage_l2access.bm > call_mvn_manage_l2_access.out &


