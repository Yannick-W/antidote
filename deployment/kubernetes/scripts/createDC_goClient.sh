#!/bin/bash

### References
### - ../deployDC.sh

### ---
### This deploys a job to kubernetes, which will start a container with the image:
### peterzel/antidote-connect
### And the arguments:
### ["--createDc", "${antidote_first_node}", ${antidote_nodes}]
### The information about the nodes is fetched from the kubernetes cluster.
### ---

## Arguments
APP_LABEL=$1 # name of the statefulset / datacenter
SCRIPTS_CONFIG_SRC_DIR=$2

## Files
createDC=go-connector-createDC-template.yaml

## Dirs
if [ -z "$SCRIPTS_CONFIG_SRC_DIR" ]; then
	RES_DIR=$(bash getConfig.sh resources_dir $SCRIPTS_CONFIG_SRC_DIR);
	DEPLOYMENTS_DIR=$(bash getConfig.sh deployments_dir $SCRIPTS_CONFIG_SRC_DIR);
	TEMPLATES_DIR=$(bash getConfig.sh templates_dir $SCRIPTS_CONFIG_SRC_DIR);
else
	RES_DIR=$(bash $SCRIPTS_CONFIG_SRC_DIR/getConfig.sh resources_dir $SCRIPTS_CONFIG_SRC_DIR);
	DEPLOYMENTS_DIR=$(bash $SCRIPTS_CONFIG_SRC_DIR/getConfig.sh deployments_dir $SCRIPTS_CONFIG_SRC_DIR);
	TEMPLATES_DIR=$(bash $SCRIPTS_CONFIG_SRC_DIR/getConfig.sh templates_dir $SCRIPTS_CONFIG_SRC_DIR);
fi

DEPLOYMENT_DIR=$DEPLOYMENTS_DIR/$APP_LABEL;


## Begin
JOBS_DIR=$RES_DIR/jobs/

mapfile -t IPS < <(kubectl get pods -l app=$APP_LABEL,type=instance -o yaml | awk '$1 == "podIP:" { print $2 }')
mapfile -t ANTIDOTE_NODES < <(kubectl get pods -l app=$APP_LABEL,type=instance -o yaml | awk '$1 == "podIP:" { print "antidote@"$2 }')

if [ ${#ANTIDOTE_NODES[@]} -eq 0 ];
	then
		echo No nodes to connect. Exiting.
		exit;
fi

## first node
ANTIDOTE_FIRST_NODE=${IPS[0]}":8087"

## build nodes string formatted
nodes=${ANTIDOTE_NODES[@]}
for node in $nodes
	do
		ANTIDOTE_NODES_STR=$ANTIDOTE_NODES_STR\,\"$node\"
done
ANTIDOTE_NODES_STR=${ANTIDOTE_NODES_STR:1:${#ANTIDOTE_NODES_STR}}

## create connector ressource to connect this data center
JOB_CREATEDC=$JOBS_DIR/go-connector-createDC-$APP_LABEL.yaml
cp $TEMPLATES_DIR/$createDC $JOB_CREATEDC

sed -i s/"\${antidote_datacenter}"/"$APP_LABEL"/g $JOB_CREATEDC;
sed -i s/"\${antidote_first_node}"/"$ANTIDOTE_FIRST_NODE"/g $JOB_CREATEDC;
sed -i s/"\${antidote_nodes}"/"$ANTIDOTE_NODES_STR"/g $JOB_CREATEDC;

## 
echo Creating data center with nodes: $ANTIDOTE_NODES_STR ...


if [ $(bash ./scripts/readyProbe.sh $APP_LABEL) -eq 0 ]
	then
		## delete old job
		kubectl delete job createdc-for-$APP_LABEL
		sleep 2
		## deploy the connector
		kubectl apply -f $JOB_CREATEDC
		echo Done.
		exit;
	else
		echo Datacenter $APP_LABEL is not ready!
		exit;
fi