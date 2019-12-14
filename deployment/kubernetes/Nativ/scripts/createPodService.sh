#!/bin/bash
APP_LABEL=$1
POD_NAME=$2

POD_YAML_TEMPLATE=$3
SERVICE_DIR=$4

## Begin

echo Creating yaml file.

## create connector ressource to connect this data center
SERVICE=$SERVICE_DIR/$POD_NAME-LoadBalancer-Service.yaml;
cp $POD_YAML_TEMPLATE $SERVICE;
sed -i s/"\${antidote_datacenter}"/"$APP_LABEL"/g $SERVICE;
sed -i s/"\${pod_name}"/"$POD_NAME"/g $SERVICE;

echo Done.

echo Calling kubectl to create the service.
kubectl apply -f $SERVICE;
echo Done.

