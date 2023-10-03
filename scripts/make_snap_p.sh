#!/bin/bash

STACK_ID=$1
VOL="$(aws ec2 describe-volumes --filters Name=tag:Name,Values=\'$STACK_ID\' --query 'Volumes[0].VolumeId' --output text)"
SNAP="$(aws ec2 create-snapshot --volume-id $VOL --tag-specifications 'ResourceType=snapshot,Tags={Key=Name,Value='$STACK_ID'}' | jq -r '.SnapshotId')"

while :
do
    STATE="$(aws ec2 describe-snapshots --snapshot-id $SNAP --query 'Snapshots[0].State' --output text)"

    if [ "$SNAP" != "null" ] && [ "$STATE" == "completed" ];
    then
        sleep 2
        break
    else
        sleep 5
    fi
done

