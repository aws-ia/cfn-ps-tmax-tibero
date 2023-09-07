#!/bin/bash

USER_PARAM=$2
source $USER_PARAM

aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/install_tibero.sh $USER_HOME/install_tibero.sh
chmod 755 $USER_HOME/install_tibero.sh
$USER_HOME/install_tibero.sh $USER_HOME
rm -rf $USER_HOME/install_tibero.sh

aws s3 cp s3://db25-quickstart/tibero_install/license.xml $TB_HOME/license/license.xml

aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/tbdsn.template $TB_HOME/config/tbdsn.template
aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/gen_tbdsn.sh $TB_HOME/config/gen_tbdsn.sh
chmod 755 $TB_HOME/config/gen_tbdsn.sh
$TB_HOME/config/gen_tbdsn.sh

aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/tibero.template $TB_HOME/config/tibero.template
aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/gen_tibero_tip.sh $TB_HOME/config/gen_tibero_tip.sh
chmod 755 $TB_HOME/config/gen_tibero_tip.sh
$TB_HOME/config/gen_tibero_tip.sh

aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/set_kernel_env.sh $TB_HOME/config/set_kernel_env.sh
chmod 755 $TB_HOME/config/set_kernel_env.sh
sudo $TB_HOME/config/set_kernel_env.sh root $USER_PARAM

aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'lambda'/lambda_failover.sh $TB_HOME/scripts/lambda_failover.sh
chmod 755 $TB_HOME/scripts/lambda_failover.sh

aws s3 cp s3://db25-quickstart/tibero_install/jdk-7u80-linux-x64.tar.gz $USER_HOME/jdk-7u80-linux-x64.tar.gz
sudo tar -zxvf $USER_HOME/jdk-7u80-linux-x64.tar.gz -C /usr/local/bin
cd /usr/local/bin
sudo ln -s /usr/local/bin/jdk1.7.0_80 java
echo 'JAVA_HOME=/usr/local/bin/java/' | sudo tee -a /etc/profile > /dev/null
echo 'JRE_HOME=/usr/local/bin/java/' | sudo tee -a /etc/profile > /dev/null
echo 'PATH=$PATH:$JRE_HOME/bin:$JAVA_HOME/bin' | sudo tee -a /etc/profile > /dev/null
echo 'export JAVA_HOME' | sudo tee -a /etc/profile > /dev/null
echo 'export JRE_HOME' | sudo tee -a /etc/profile > /dev/null
echo 'export PATH' | sudo tee -a /etc/profile > /dev/null
rm $USER_HOME/jdk-7u80-linux-x64.tar.gz

if [ "$1" == 'primary' ];
then
    aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/cm.template $TB_HOME/config/cm.template
    aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/gen_cm_tip.sh $TB_HOME/config/gen_cm_tip.sh
    chmod 755 $TB_HOME/config/gen_cm_tip.sh
    $TB_HOME/config/gen_cm_tip.sh

    aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/mount_volume_p.sh $TB_HOME/config/mount_volume_p.sh
    chmod 755 $TB_HOME/config/mount_volume_p.sh
    mkdir $DATABASE_DIRECTORY

    aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/make_snap_p.sh $TB_HOME/config/make_snap_p.sh
    chmod 755 $TB_HOME/config/make_snap_p.sh

    aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/gen_db_p.sh $TB_HOME/config/gen_db_p.sh
    chmod 755 $TB_HOME/config/gen_db_p.sh
    $TB_HOME/config/gen_db_p.sh
elif [ "$1" == 'standby' ];
then
    aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/cm.template $TB_HOME/config/cm.template
    aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/gen_cm_tip.sh $TB_HOME/config/gen_cm_tip.sh
    chmod 755 $TB_HOME/config/gen_cm_tip.sh
    $TB_HOME/config/gen_cm_tip.sh

    aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/make_volume_s.sh $TB_HOME/config/make_volume_s.sh
    chmod 755 $TB_HOME/config/make_volume_s.sh
    mkdir $DATABASE_DIRECTORY

    aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/gen_db_s.sh $TB_HOME/config/gen_db_s.sh
    chmod 755 $TB_HOME/config/gen_db_s.sh
    $TB_HOME/config/gen_db_s.sh
elif [ "$1" == 'observer' ];
then
    aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/observer.template $TB_HOME/config/observer.template
    aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/gen_observer_tip.sh $TB_HOME/config/gen_observer_tip.sh
    chmod 755 $TB_HOME/config/gen_observer_tip.sh
    $TB_HOME/config/gen_observer_tip.sh

    aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'scripts'/wait_tsc_o.sh $TB_HOME/config/wait_tsc_o.sh
    chmod 755 $TB_HOME/config/wait_tsc_o.sh

    aws s3 cp s3://$S3_BUCKET_NAME/$S3_KEY_PREFIX'lambda'/lambda_event.sh $TB_HOME/scripts/lambda_event.sh
    chmod 755 $TB_HOME/scripts/lambda_event.sh
fi

sleep 2
