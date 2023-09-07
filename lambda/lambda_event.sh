#!/bin/bash

USER_PARAM=$1

generate_json()
{
    cat <<EOF
[
    {
        "Source":"user-event",
        "DetailType":"user-preferences",
        "Detail":"{ \"Region\": \"$REGION\",\"ObserverState\": \"$OBS_STATE\",\"TSCstate\": \"$TSC_STATE\",\"PRIMARY\": \"$PRIMARY\",\"DownInstID\": \"$NOT_PRI_INST_ID\",\"UserName\": \"$USER_NAME\",\"UserParamPath\": \"$USER_PARAM_PATH\",\"TBhome\": \"$TB_HOME\" }",
        "EventBusName":"$EVENT_BUS_NAME"
    }
]
EOF
}


watching_state()
{
    USER_PARAM_PATH=$1
    source $USER_PARAM_PATH
    source $INST_ENV
    EVENT_PATH=$TB_HOME/instance/$CM_SID/lambda_event.json

    REGION="$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')"
    OBSERVER="$(ps -ef | grep tbcmobs | awk '$NF == "-b" {print $(NF-1)}')"
    INST_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
    VPC_ID="$(aws ec2 describe-instances --instance-ids $INST_ID --query 'Reservations[*].Instances[*].VpcId' --output text)"

    if [ ${#OBSERVER} != 0 ];
    then
        OBS_STATE="up"
        PRIMARY="$(cmrctl show | awk '$NF == "PRIMARY" {print $(NF-4)}')"

        if [ ${#PRIMARY} != 0 ];
        then
            if [ "$PRIMARY" == "$PRIMARY_CM" ];
            then
                NOT_PRI_INST_ID="$(aws ec2 describe-instances --filters "Name=tag:Name,Values='DB Standby'" "Name=vpc-id,Values='$VPC_ID'" | jq -r '.Reservations[0].Instances[0].InstanceId')"
            else
                NOT_PRI_INST_ID="$(aws ec2 describe-instances --filters "Name=tag:Name,Values='DB Primary'" "Name=vpc-id,Values='$VPC_ID'" | jq -r '.Reservations[0].Instances[0].InstanceId')"
            fi

            N="$(cmrctl show | awk '$NF == "N" {print $(NF-4)}')"
            TARGET="$(cmrctl show | awk '$NF == "TARGET" {print $(NF-4)}')"

            if [ ${#N} != 0 ] && [ ${#TARGET} == 0 ];
            then
                echo PRIMARY and N
                TSC_STATE="DBdown"
                generate_json > $EVENT_PATH
                aws events put-events --entries file://$EVENT_PATH
            elif [ ${#N} == 0 ] && [ ${#TARGET} == 0 ];
            then
                echo PRIMARY and X
                TSC_STATE="CMdown"
                generate_json > $EVENT_PATH
                aws events put-events --entries file://$EVENT_PATH
            else
                echo Good
                TSC_STATE="clear"
                NOT_PRI_INST_ID="none"
                generate_json > $EVENT_PATH
            fi
        else
            echo NoPRIMARY
            TSC_STATE="none"
            PRIMARY="none"
            NOT_PRI_INST_ID="none"
            generate_json > $EVENT_PATH
        fi
    else
        echo OBSERVER DOWN
        OBS_STATE="down"
        TSC_STATE="none"
        PRIMARY="none"
        NOT_PRI_INST_ID=$INST_ID
        generate_json > $EVENT_PATH
        aws events put-events --entries file://$EVENT_PATH
    fi
}

watching_state $USER_PARAM

