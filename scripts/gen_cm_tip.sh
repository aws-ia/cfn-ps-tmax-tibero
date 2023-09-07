#!/bin/bash


if [ -z $CM_HEARTBEAT_EXPIRE ]; then
    CM_HEARTBEAT_EXPIRE=3000
fi

if [ -z $CM_WATCHDOG_EXPIRE ]; then
    CM_WATCHDOG_EXPIRE=2990
fi

cm_tip_template=$TB_HOME/config/cm.template
cm_tip_file=$TB_HOME/config/$CM_SID.tip

if test -f $cm_tip_file ; then
    echo "There's already ${cm_tip_file}!!  Nothing has changed!!" >&2
else
    sed_pattern=""
    sed_pattern=$sed_pattern" -e s/@CM_NAME@/$CM_SID/g"
    sed_pattern=$sed_pattern" -e s/@CM_UIPORT@/$CM_PORT/g"
    sed_pattern=$sed_pattern" -e s/@TB_HOME@/`echo $TB_HOME | sed  's|\/|\\\/|g'`/g"
    sed_pattern=$sed_pattern" -e s/@CM_HEARTBEAT_EXPIRE@/$CM_HEARTBEAT_EXPIRE/g"
    sed_pattern=$sed_pattern" -e s/@CM_WATCHDOG_EXPIRE@/$CM_WATCHDOG_EXPIRE/g"

#generate tip

    echo "# tip file generated from $cm_tip_template (`date`)" > $cm_tip_file

    sed $sed_pattern $cm_tip_template >> $cm_tip_file

    echo "$cm_tip_file generated" >&2
fi
