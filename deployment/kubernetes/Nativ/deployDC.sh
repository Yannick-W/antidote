#!/bin/bash

### ---
### This deploys an antidote datacenter with:
### 	- name: $1
###		- number of nodes: $2
### Including:
###		- statefulset
###		- headless service for the statefulset
###		- job to create the antidote dc
###		- services that expose each node to the outside net
### Configuration:
###		Can be done through editing the templates or variables given in this script.
###		${*} expressions in the templates are replaced by this and other scripts.
### Output:
###		This script creates a new directory in resources/deployments/$1
###		There can be found all created yaml files that were deployed to the kubernetes cluster.
### ---

APP_LABEL=$1
NUM_NODES=$2

## Configuration
ANTIDOTE_DATACENTER="$APP_LABEL"
IMAGE= "antidotedb/"##"192.168.2.106:5000\/antidotedb-local-build:0.2.2" ## needs to be sed friendly;
IMAGE_PULL_POLICY="Never"
STORAGE_CLASS_NAME="local-storage"

### ---

## Dirs
RES_DIR=$(bash getConfig.sh resources_dir);
DEPLOYMENTS_DIR=$(bash getConfig.sh deployments_dir);
TEMPLATES_DIR=$(bash getConfig.sh templates_dir);

## Begin

echo app=$APP_LABEL
echo replicas=$NUM_NODES

## Create directory for deployment
if [ ! -d "$DEPLOYMENTS_DIR/$APP_LABEL" ]; then
	mkdir "$DEPLOYMENTS_DIR/$APP_LABEL"
	mkdir "$DEPLOYMENTS_DIR/$APP_LABEL/services_pod-exposer"
		
	## add to config TODO...
fi

## Create statefulset yaml
STATEFUL_SET=$DEPLOYMENTS_DIR/$APP_LABEL/statefulset_$APP_LABEL.yaml
cp $TEMPLATES_DIR/statefulset_antidote-template.yaml $STATEFUL_SET;
sed -i s/"\${antidote_datacenter}"/"$ANTIDOTE_DATACENTER"/g $STATEFUL_SET;
sed -i s/"\${antidote_image}"/"$IMAGE"/g $STATEFUL_SET;
sed -i s/"\${image_pull_policy}"/"$IMAGE_PULL_POLICY"/g $STATEFUL_SET;
sed -i s/"\${storage_class_name}"/"$STORAGE_CLASS_NAME"/g $STATEFUL_SET;

## Create headless service yaml
HEADLESS_SERVICE=$DEPLOYMENTS_DIR/$APP_LABEL/service_$APP_LABEL-headless.yaml
cp $TEMPLATES_DIR/service_antidote-headless-template.yaml $HEADLESS_SERVICE;
sed -i s/"\${antidote_datacenter}"/"$ANTIDOTE_DATACENTER"/g $HEADLESS_SERVICE;

###
## Deploy
kubectl apply -f $DEPLOYMENTS_DIR/$APP_LABEL
kubectl scale --replicas=$NUM_NODES statefulset/$APP_LABEL

## CreateDC
echo "Creating data center from statefulset "$APP_LABEL"..." 
echo "Check if the statefulset is ready:"
while [ $(bash ./scripts/readyProbe.sh $APP_LABEL) -eq -1 ] 
	do 
		echo $(bash ./scripts/readyProbe.sh $APP_LABEL)" -> sleep 10 seconds, then try again."
		sleep 10
done
echo $(bash ./scripts/readyProbe.sh $APP_LABEL)" -> Statefulset for data center "$APP_LABEL" is ready!"
echo "Procede to create the data center for $APP_LABEL..."
bash ./scripts/createDC_goClient.sh $APP_LABEL
echo "Expose all nodes to the outside net for datacenter $APP_LABEL."
bash ./scripts/exposeDatacenter.sh $APP_LABEL
echo Done.

echo Deployment complete.