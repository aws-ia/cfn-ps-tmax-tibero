#!/bin/bash

db_create_file=$TB_HOME/config/db_create_s.sh

if test -f $db_create_file ; then
    echo "There's already ${db_create_file}!!  Nothing has changed!!" >&2

else
    echo -e "#-------------------------------------------------------------------------------\n#" >> $db_create_file
    echo "# Creating Database Script" >> $db_create_file
    echo -e "#\n#-------------------------------------------------------------------------------\n" >> $db_create_file
    echo -e "export CM_SID=$CM_SID\n" >> $db_create_file
    echo -e "tbcm -b\n" >> $db_create_file
    echo "cmrctl add network --name net0 --ipaddr $STANDBY_IP --portno $CM_CLUSTER_PORT" >> $db_create_file
    echo "cmrctl add cluster --name cls_standby --incnet net0 --cfile $TB_HOME/config/cls_standby_cfile" >> $db_create_file
    echo "cmrctl start cluster --name cls_standby" >> $db_create_file
    echo "cmrctl add service --name $DB_NAME --cname cls_standby --tscid 123 --obsip $OBSERVER_IP --obsport $OBSERVER_PORT" >> $db_create_file
    echo -e "echo y | cmrctl add db --name $TB_SID --svcname $DB_NAME --dbhome $TB_HOME\n" >> $db_create_file
    echo -e "sleep 2\n" >> $db_create_file
    echo -e "export TB_SID=$TB_SID\n" >> $db_create_file
    echo -e "tbboot mount\n" >> $db_create_file
    echo "tbsql sys/tibero << EOF" >> $db_create_file
    echo -e "alter database standby controlfile;\nEOF\n" >> $db_create_file
    echo -e "sleep 2\n\ntbdown\n\nsleep 2\n\ntbboot recovery" >> $db_create_file

    chmod 755 $db_create_file
    echo "$db_create_file generated" >&2

fi
