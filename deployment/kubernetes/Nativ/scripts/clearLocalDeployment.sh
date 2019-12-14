#!/bin/bash
APP_LABEL=$1
SCRIPTS_CONFIG_SRC_DIR=$2

if [ -z "$SCRIPTS_CONFIG_SRC_DIR" ]; then
	DEPLOYMENTS_DIR=$(bash getConfig.sh deployments_dir $SCRIPTS_CONFIG_SRC_DIR);
else
	DEPLOYMENTS_DIR=$(bash $SCRIPTS_CONFIG_SRC_DIR/getConfig.sh deployments_dir $SCRIPTS_CONFIG_SRC_DIR);
fi

if [ -d "$DEPLOYMENTS_DIR/$APP_LABEL" ]; then
	echo rm -r "$DEPLOYMENTS_DIR/$APP_LABEL"
	rm -r "$DEPLOYMENTS_DIR/$APP_LABEL"
	echo Done.
else
	echo "$DEPLOYMENTS_DIR/$APP_LABEL" does not exist.
fi

