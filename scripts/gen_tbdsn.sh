#!/bin/bash
# Default value setting

client_config_template=$TB_HOME/config/tbdsn.template
client_config_file_key=$TB_HOME/config/tbdsn.key
client_config_file=$TB_HOME/client/config/tbdsn.tbr

if test -f $client_config_file_key ; then
    echo "There's already ${client_config_file}!!  Nothing has changed!!" >&2
    cp $client_config_file_key $TB_HOME/client/config/tbdsn.tbr
    ln -s $client_config_file_key $TB_HOME/client/config/tbdsn.tbr

else
    sed_pattern=""
    sed_pattern=$sed_pattern" -e s/@TB_SID@/$TB_SID/g"
    sed_pattern=$sed_pattern" -e s/@LISTENER_PORT@/$LISTENER_PORT/"
    sed_pattern=$sed_pattern" -e s/@LISTENER_SPECIAL_PORT@/`expr $LISTENER_PORT + 1`/"
    sed_pattern=$sed_pattern" -e s/@DB_NAME@/$DB_NAME/g"

    if [ "$PRIMARY" == 'Y'  ]; then
        sed_pattern=$sed_pattern" -e s/@MY_IP@/$PRIMARY_IP/g"
    else
        sed_pattern=$sed_pattern" -e s/@MY_IP@/$STANDBY_IP/g"
    fi

#generate tip

    echo "# tip file generated from $client_config_template (`date`)" > $client_config_file
    echo "# tip file generated from $client_config_template (`date`)" > $client_config_file_key

    sed $sed_pattern $client_config_template >> $client_config_file
    sed $sed_pattern $client_config_template >> $client_config_file_key

    echo "$client_config_file generated" >&2
fi

#old create form
#cat >$client_config_file <<EOF
#$TB_SID=(
#    (INSTANCE=(HOST=localhost)
#EOF
#    echo "              (PORT=$LISTENER_PORT)" >>$client_config_file;
#    cat >>$client_config_file <<EOF
#              (DB_NAME=$DB_NAME)
#    )
#)
#EOF
