#!/bin/bash

USER_PARAM=$1

while :
do
    PRIMARY="$(cmrctl show | awk '$(NF-1) == "UP(NRML)" {print $(NF-4)}')"
    TARGET="$(cmrctl show | awk '$(NF-1) == "UP(RECO)" {print $(NF-4)}')"

    if [ ${#PRIMARY} != 0 ] && [ ${#TARGET} != 0 ];
    then
        cmrctl set --tscid 123 --mode disaster_plan
		echo "* * * * * $TB_HOME/scripts/lambda_event.sh $USER_PARAM" | crontab -
		break
    else
        sleep 5
    fi
done

