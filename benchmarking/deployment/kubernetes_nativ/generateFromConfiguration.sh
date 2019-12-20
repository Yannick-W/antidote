#!/bin/bash

CONFIG=$1

FULLFILENAME="${CONFIG##*/}"
FILENAME="${FULLFILENAME%.*}"

DEPLOYMENT_DIR="resources/deployments/$FILENAME"

if [ ! -d $DEPLOYMENT_DIR ]; then
	mkdir $DEPLOYMENT_DIR
else
	echo "Generated yaml files based on this configuration exist already."
	exit;
fi

