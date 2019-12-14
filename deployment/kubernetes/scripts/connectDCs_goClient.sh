#!/bin/bash

### References
### - ../connectDCs.sh

### ---
### ---

## Arguments
SCRIPTS_CONFIG_SRC_DIR=$3
POSTFIX_ID_STR=$2
ANTIDOTE_SERVERS=$1

echo $SCRIPTS_CONFIG_SRC_DIR
echo postfix: $POSTFIX_ID_STR
echo servers: $ANTIDOTE_SERVERS

## Files
connectDCs=go-connector-connectDCs-template.yaml

## Dirs
if [ -z "$SCRIPTS_CONFIG_SRC_DIR" ]; then
	RES_DIR=$(bash getConfig.sh resources_dir $SCRIPTS_CONFIG_SRC_DIR);
	TEMPLATES_DIR=$(bash getConfig.sh templates_dir $SCRIPTS_CONFIG_SRC_DIR);
else
	RES_DIR=$(bash $SCRIPTS_CONFIG_SRC_DIR/getConfig.sh resources_dir $SCRIPTS_CONFIG_SRC_DIR);
	TEMPLATES_DIR=$(bash $SCRIPTS_CONFIG_SRC_DIR/getConfig.sh templates_dir $SCRIPTS_CONFIG_SRC_DIR);
fi

## Begin
JOBS_DIR="$RES_DIR/jobs"

## create connector ressource to connect this data centers
JOB_CONNECTDCS="$JOBS_DIR/go-connector-connectDCs-$POSTFIX_ID_STR.yaml"
cp $TEMPLATES_DIR/$connectDCs $JOB_CONNECTDCS

sed -i s/"\${antidote_datacenters}"/"$POSTFIX_ID_STR"/g $JOB_CONNECTDCS;
sed -i s/"\${antidote_servers}"/"$ANTIDOTE_SERVERS"/g $JOB_CONNECTDCS;


## delete old job
kubectl delete job connector-for-$POSTFIX_ID_STR
sleep 2
## deploy the connector
kubectl apply -f $JOB_CONNECTDCS
echo Done.
exit;
