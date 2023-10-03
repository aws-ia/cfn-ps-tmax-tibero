#!/bin/bash

db_create_file=$TB_HOME/config/db_create_p.sh

if test -f $db_create_file ; then
    echo "There's already ${db_create_file}!!  Nothing has changed!!" >&2

else
    echo -e "#-------------------------------------------------------------------------------\n#" >> $db_create_file
    echo "# Creating Database Script" >> $db_create_file
    echo -e "#\n#-------------------------------------------------------------------------------\n" >> $db_create_file
    echo "USER_IDPW=\$1" >> $db_create_file
    echo -e "source \$USER_IDPW\n" >> $db_create_file
    echo -e "export CM_SID=$CM_SID\n" >> $db_create_file
    echo -e "tbcm -b\n" >> $db_create_file
    echo "cmrctl add network --name net0 --ipaddr $PRIMARY_IP --portno $CM_CLUSTER_PORT" >> $db_create_file
    echo "cmrctl add cluster --name cls_primary --incnet net0 --cfile $TB_HOME/config/cls_primary_cfile" >> $db_create_file
    echo "cmrctl start cluster --name cls_primary" >> $db_create_file
    echo "cmrctl add service --name $DB_NAME --cname cls_primary --tscid 123 --obsip $OBSERVER_IP --obsport $OBSERVER_PORT" >> $db_create_file
    echo -e "echo y | cmrctl add db --name $TB_SID --svcname $DB_NAME --dbhome $TB_HOME\n" >> $db_create_file
    echo -e "sleep 2\n" >> $db_create_file
    echo -e "export TB_SID=$TB_SID\n" >> $db_create_file
    echo -e "tbboot -t nomount\n" >> $db_create_file
    echo "tbsql sys/tibero << EOF" >> $db_create_file
    echo "set timing on;" >> $db_create_file
    echo "create database \"$DB_NAME\"" >> $db_create_file
    echo "user sys identified by tibero" >> $db_create_file
    echo "    maxinstances 8" >> $db_create_file
    echo "    maxdatafiles 200" >> $db_create_file
    echo "    character set $CHARACTER_SET" >> $db_create_file
    echo "    logfile" >> $db_create_file
    var=1
    if [ $REDO_LOG_DUPLICATE = "N" ] ; then
        while [ $var -le $REDO_LOG_GROUP ]
        do
        echo -n "            group $var '$DATABASE_DIRECTORY/tbdata/log$var.log' size `expr $REDO_DATAFILE_SIZE`M" >> $db_create_file
        if [[ $var == $REDO_LOG_GROUP ]] ; then
        echo -e "" >> $db_create_file
        else
        echo -e "," >> $db_create_file
        fi
        ((var++))
        done
    else
        while [ $var -le $REDO_LOG_GROUP ]
        do
        echo -n "            group $var ('$DATABASE_DIRECTORY/tbdata/system01/log`expr $var`a.log','$DATABASE_DIRECTORY/tbdata/system02/log`expr $var`b.log') size `expr $REDO_DATAFILE_SIZE`M" >> $db_create_file
        if [[ $var == $REDO_LOG_GROUP ]] ; then
        echo -e "" >> $db_create_file
        else
        echo -e "," >> $db_create_file
        fi
        ((var++))
        done
    fi
    echo "    maxloggroups 255" >> $db_create_file
    echo "    maxlogmembers 8" >> $db_create_file
    echo "    archivelog" >> $db_create_file
    echo "    datafile '$DATABASE_DIRECTORY/tbdata/system001.tdf' size `expr $SYSTEM_DATAFILE_SIZE`M" >> $db_create_file
    echo "            autoextend on next `expr $SYSTEM_DATAFILE_SIZE`M" >> $db_create_file

    echo "    syssub datafile '$DATABASE_DIRECTORY/tbdata/syssub001.tdf' size `expr $SYSSYB_DATAFILE_SIZE`M" >> $db_create_file
    echo "            autoextend on next `expr $SYSSYB_DATAFILE_SIZE`M" >> $db_create_file

    echo "    default temporary tablespace TEMP" >> $db_create_file
    echo "            tempfile '$DATABASE_DIRECTORY/tbdata/temp001.tdf' size `expr $TEMP_DATAFILE_SIZE`M" >> $db_create_file
    echo "            autoextend on next `expr $TEMP_DATAFILE_SIZE`M" >> $db_create_file
    echo "            extent management local autoallocate" >> $db_create_file

    echo "    undo tablespace UNDO0" >> $db_create_file
    echo "            datafile '$DATABASE_DIRECTORY/tbdata/undo0000.tdf' size `expr $UNDO_DATAFILE_SIZE`M" >> $db_create_file
    echo "            autoextend on next `expr $UNDO_DATAFILE_SIZE`M" >> $db_create_file
    echo "            extent management local autoallocate" >> $db_create_file

    echo "    default tablespace USR" >> $db_create_file
    echo "            datafile '$DATABASE_DIRECTORY/tbdata/usr001.tdf' size `expr $USR_DATAFILE_SIZE`M" >> $db_create_file
    echo "            autoextend on next `expr $USR_DATAFILE_SIZE`M" >> $db_create_file
    echo "            extent management local autoallocate" >> $db_create_file

    echo -e ";\nEOF\n" >> $db_create_file
    echo -e "sleep 2\n\ntbboot\n\nsleep 2\n" >> $db_create_file
    echo -e "$TB_HOME/scripts/system.sh -p1 tibero -p2 syscat -a1 y -a2 y -a3 y -a4 y\n\nsleep 2\n" >> $db_create_file
    echo -e "tbsql sys/tibero << EOF\n" >> $db_create_file
    echo -e "create user \$DATABASE_USER_ID identified by \$DATABASE_USER_PW;\ngrant dba to \$DATABASE_USER_ID;\nEOF\n" >> $db_create_file
    echo -e "tbsql sys/tibero << EOF\n" >> $db_create_file
    echo -e "alter system switch logfile;\nalter system switch logfile;\nalter system switch logfile;\nEOF\n" >> $db_create_file
    echo -e "sleep 2\n\ntbdown\n\nsleep 2\n" >> $db_create_file

    chmod 755 $db_create_file
    echo "$db_create_file generated" >&2

fi
