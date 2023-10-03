#!/bin/bash

if [ -z $CM_MODE_OBSERVER ]; then
    CM_MODE_OBSERVER=Y
fi

observer_tip_template=$TB_HOME/config/observer.template
observer_tip_file=$TB_HOME/config/$CM_SID.tip

if test -f $observer_tip_file ; then
    echo "There's already ${observer_tip_file}!!  Nothing has changed!!" >&2
else
    sed_pattern=""
    sed_pattern=$sed_pattern" -e s/@OBSERVER_NAME@/$CM_SID/g"
    sed_pattern=$sed_pattern" -e s/@CM_MODE_OBSERVER@/$CM_MODE_OBSERVER/g"
    sed_pattern=$sed_pattern" -e s/@OBSERVER_PORT@/$OBSERVER_PORT/g"
    sed_pattern=$sed_pattern" -e s/@CM_UIPORT@/$CM_PORT/g"

#generate tip

    echo "# tip file generated from $observer_tip_template (`date`)" > $observer_tip_file

    sed $sed_pattern $observer_tip_template >> $observer_tip_file

    echo "$observer_tip_file generated" >&2
fi
