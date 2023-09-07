#!/bin/bash


if [ -z $MAX_SESSION_COUNT ]; then
    MAX_SESSION_COUNT=200
fi

if [ -z $TOTAL_SHM_SIZE ]; then
    TOTAL_SHM_SIZE=2G
fi

if [ -z $MEMORY_TARGET ]; then
    MEMORY_TARGET=4G
fi

if [ -z $UNDO_TABLESPACE ]; then
    UNDO_TABLESPACE="UNDO0"
fi

# Related to DB Clustering

if [ -z $CLUSTER_DATABASE ]; then
    CLUSTER_DATABASE=Y
fi

if [ -z $THREAD_NO ]; then
    THREAD_NO=0
fi

# Related to TSC-OBS mode

if [ -z $LOG_REPLICATION_MODE ]; then
    LOG_REPLICATION_MODE=PERFORMANCE
fi

if [ -z $STANDBY_USE_OBSERVER ]; then
    STANDBY_USE_OBSERVER=Y
fi

if [ -z $STANDBY_NETWORK_TIMEOUT ]; then
    STANDBY_NETWORK_TIMEOUT=60
fi

if [ -z $STANDBY_ENABLE_LOG_RECOVERY ]; then
    STANDBY_ENABLE_LOG_RECOVERY=Y
fi

DB_CLUSTER_PORT=`expr $LISTENER_PORT + 50`
LOG_TARGET_DB_PORT=`expr $LISTENER_PORT + 4`

tac_tip_template=$TB_HOME/config/tibero.template
tac_tip_file=$TB_HOME/config/$TB_SID.tip

if test -f $tac_tip_file ; then
    echo "There's already ${tac_tip_file}!!  Nothing has changed!!" >&2

    if [ "$PRIMARY" == 'Y' ]
    then
        sed -ri "s/LOCAL_CLUSTER_ADDR=([^\)]*)(.*)/LOCAL_CLUSTER_ADDR=$PRIMARY_IP/g" "$TB_HOME/config/${TB_SID}.tip"
    else
        sed -ri "s/LOCAL_CLUSTER_ADDR=([^\)]*)(.*)/LOCAL_CLUSTER_ADDR=$STANDBY_IP/g" "$TB_HOME/config/${TB_SID}.tip"
    fi

else
    sed_pattern=""
    sed_pattern=$sed_pattern" -e s/@DB_NAME@/$DB_NAME/g"
    sed_pattern=$sed_pattern" -e s/@LISTENER_PORT@/$LISTENER_PORT/"
    sed_pattern=$sed_pattern" -e s/@LISTENER_SPECIAL_PORT@/`expr $LISTENER_PORT + 1`/"
    sed_pattern=$sed_pattern" -e s/@DATABASE_DIRECTORY@/`echo $DATABASE_DIRECTORY | sed  's|\/|\\\/|g'`/g"
    sed_pattern=$sed_pattern" -e s/@MAX_SESSION_COUNT@/$MAX_SESSION_COUNT/"
    sed_pattern=$sed_pattern" -e s/@TOTAL_SHM_SIZE@/$TOTAL_SHM_SIZE/"
    sed_pattern=$sed_pattern" -e s/@MEMORY_TARGET@/$MEMORY_TARGET/"
    sed_pattern=$sed_pattern" -e s/@UNDO_TABLESPACE@/$UNDO_TABLESPACE/g"
    sed_pattern=$sed_pattern" -e s/@CLUSTER_DATABASE@/$CLUSTER_DATABASE/g"
    sed_pattern=$sed_pattern" -e s/@DB_CLUSTER_PORT@/$DB_CLUSTER_PORT/g"
    sed_pattern=$sed_pattern" -e s/@THREAD@/$THREAD_NO/g"
    sed_pattern=$sed_pattern" -e s/@CM_PORT@/$CM_PORT/g"
    sed_pattern=$sed_pattern" -e s/@LOG_REPLICATION_MODE@/$LOG_REPLICATION_MODE/g"
    sed_pattern=$sed_pattern" -e s/@LOG_TARGET_DB_PORT@/$LOG_TARGET_DB_PORT/g"
    sed_pattern=$sed_pattern" -e s/@STANDBY_USE_OBSERVER@/$STANDBY_USE_OBSERVER/g"
    sed_pattern=$sed_pattern" -e s/@STANDBY_NETWORK_TIMEOUT@/$STANDBY_NETWORK_TIMEOUT/g"
    sed_pattern=$sed_pattern" -e s/@STANDBY_ENABLE_LOG_RECOVERY@/$STANDBY_ENABLE_LOG_RECOVERY/g"

    if [ "$PRIMARY" == 'Y' ]
    then
        sed_pattern=$sed_pattern" -e s/@MY_IP@/$PRIMARY_IP/g"
        sed_pattern=$sed_pattern" -e s/@TARGET_IP@/$STANDBY_IP/g"
    else
        sed_pattern=$sed_pattern" -e s/@MY_IP@/$STANDBY_IP/g"
        sed_pattern=$sed_pattern" -e s/@TARGET_IP@/$PRIMARY_IP/g"
    fi

#generate tip

    echo "# tip file generated from $tac_tip_template (`date`)" > $tac_tip_file

    sed $sed_pattern $tac_tip_template >> $tac_tip_file

    echo "$tac_tip_file generated" >&2
fi

