#!/bin/bash

USER_PARAM=$1
OPTION=$2

source $USER_PARAM
source $INST_ENV

if [ "$OPTION" == "DBdown" ];
then
    echo y | tbdown clean
    sleep 2
    tbboot recovery
elif [ "$OPTION" == "CMdown" ];
then
    tbcm -b
    echo y | tbdown clean
    sleep 2
    tbboot recovery
elif [ "$OPTION" == "OBSdown" ];
then
    tbcmobs -b
    sleep 10
    cmrctl set --tscid 123 --mode disaster_plan
fi
