#!/bin/bash

JOB_NAME=$1
COUNTER=$2
IMAGE=$3
CONFIG=$4

DEPLOYMENT=$5
TEMPLATE=$6

mapfile -t CONFIG_LINES < $CONFIG
printf -v CONFIG_LINES_STR "%s\n" "${CONFIG_LINES[@]}"

echo "$CONFIG_LINES_STR"

## Create statefulset yaml
JOB=$DEPLOYMENT/$JOB_NAME-$COUNTER.yaml
cp $TEMPLATE $JOB;
sed -i s/"\${job-name}"/"$JOB_NAME"/g $JOB;
sed -i s/"\${counter}"/"$COUNTER"/g $JOB;
#sed -i s/"\${configLines}"/"$CONFIG_LINES_STR"/g $JOB;
sed -i s/"\${image}"/"$IMAGE"/g $JOB;

(awk -v v1="${configLines}" -v v2="$CONFIG_LINES_STR" 'BEGIN{FS=OFS="${configLines}"} $2==v1{$2=v2} 1' $JOB) >> $JOB;
