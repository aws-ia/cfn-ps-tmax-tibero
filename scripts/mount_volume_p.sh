#!/bin/bash

USER_PARAM=$1
source $USER_PARAM

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

sleep 1

if [[ "$device" =~ "nvme" ]]; then
    partition=p1
else
    partition=1
fi


echo -e "n\np\n1\n\n\nw\n" | fdisk $device

sleep 2

mkfs -t xfs "$device$partition"

sleep 2

uuid="$(blkid | grep -i "$device$partition" | awk '{print $2}' | cut -d '"' -f 2)"

cat << EOF >> /etc/fstab
UUID=$uuid $DATABASE_DIRECTORY xfs     defaults        0 0
EOF

mount -a

sleep 2

chown $USER_NAME:$USER_NAME $DATABASE_DIRECTORY
