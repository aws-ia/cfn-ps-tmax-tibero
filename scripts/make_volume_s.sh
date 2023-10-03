#!/bin/bash

USER_PARAM=$1
source $USER_PARAM

# waiting for primary snap
STACK_ID=$2

while :
do
    SNAP="$(aws ec2 describe-snapshots --filters Name=tag:Name,Values=\'$STACK_ID\' --query 'Snapshots[0].SnapshotId' --output text)"
    STATE="$(aws ec2 describe-snapshots --snapshot-id $SNAP --query 'Snapshots[0].State' --output text)"

    if [ "$SNAP" != "null" ] && [ "$STATE" == "completed" ];
    then
        sleep 2
        break
    else
        sleep 5
    fi
done


# create standby volume
AZ="$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.availabilityZone')"
VOL="$(aws ec2 create-volume --volume-type $STANDBY_EBS_TYPE --iops $STANDBY_EBS_IOPS --snapshot-id $SNAP --availability-zone $AZ --tag-specifications 'ResourceType=volume,Tags={Key=Name,Value=Standby EBS}' | jq -r '.VolumeId')"


# wait for creating standby volume
while :
do
    VOL_STATE="$(aws ec2 describe-volumes --volume-ids $VOL --query 'Volumes[0].State' --output text)"

    if [ "$VOL_STATE" == "available" ];
    then
        break
    else
        sleep 5
    fi
done


# attach standby volume to standby EC2
INST="$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.instanceId')"
aws ec2 attach-volume --volume-id $VOL --instance-id $INST --device /dev/sdf
sleep 5


# mount volume
num="$(fdisk -l | grep -i "Disk /dev" | wc -l)"

for ((i=0;i<$num;i++));
do
    index=`expr $i + 1`
    row=p
    device="$(fdisk -l | grep -i "Disk /dev" | awk '{print $2}' | cut -d ':' -f1 | sed -n "$index$row")"
    res="$(mount | grep $device)"

    if [ -z "$res" ]; then
        break
    fi
done

if [[ "$device" =~ "nvme" ]]; then
    partition=p1
else
    partition=1
fi


uuid="$(blkid | grep -i "$device$partition" | awk '{print $2}' | cut -d '"' -f 2)"

cat << EOF >> /etc/fstab
UUID=$uuid $DATABASE_DIRECTORY xfs     defaults        0 0
EOF

mount -a

sleep 2

chown $USER_NAME:$USER_NAME $DATABASE_DIRECTORY


# modify primary EBS tags
VOL_PRI="$(aws ec2 describe-snapshots --filters Name=tag:Name,Values=\'$STACK_ID\' --query 'Snapshots[0].VolumeId' --output text)"
aws ec2 delete-tags --resource $VOL_PRI --tags Key=Name
aws ec2 create-tags --resources $VOL_PRI --tags 'Key=Name,Value=Primary EBS'


# delete primary snapshot and modify instance-attribute
aws ec2 delete-snapshot --snapshot-id $SNAP
aws ec2 modify-instance-attribute --instance-id $INST --block-device-mappings "[{\"DeviceName\": \"/dev/sdf\",\"Ebs\":{\"DeleteOnTermination\":true}}]"
