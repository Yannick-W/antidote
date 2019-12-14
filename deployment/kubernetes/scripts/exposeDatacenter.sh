#!/bin/bash
APP_LABEL=$1
SCRIPTS_CONFIG_SRC_DIR=$2

if [ -z "$SCRIPTS_CONFIG_SRC_DIR" ]; then
	TEMPLATES_DIR=$(bash getConfig.sh templates_dir $SCRIPTS_CONFIG_SRC_DIR);
	DEPLOYMENTS_DIR=$(bash getConfig.sh deployments_dir $SCRIPTS_CONFIG_SRC_DIR);
	SCRIPTS_DIR=$(bash getConfig.sh scripts_dir $SCRIPTS_CONFIG_SRC_DIR);
else
	TEMPLATES_DIR=$(bash $SCRIPTS_CONFIG_SRC_DIR/getConfig.sh templates_dir $SCRIPTS_CONFIG_SRC_DIR);
	DEPLOYMENTS_DIR=$(bash $SCRIPTS_CONFIG_SRC_DIR/getConfig.sh deployments_dir $SCRIPTS_CONFIG_SRC_DIR);
	SCRIPTS_DIR=$(bash $SCRIPTS_CONFIG_SRC_DIR/getConfig.sh scripts_dir $SCRIPTS_CONFIG_SRC_DIR);
fi

# template name:
podService=service_pod-service-template.yaml

## Begin

mapfile -t POD_NAMES < <(kubectl get pods -l app=$APP_LABEL,type=instance -o yaml | awk '$1 == "statefulset.kubernetes.io/pod-name:" { print $2 }')

## create services
names=${POD_NAMES[@]}
for pod in $names
	do
		bash $SCRIPTS_DIR/createPodService.sh $APP_LABEL $pod "$TEMPLATES_DIR/$podService" "$DEPLOYMENTS_DIR/$APP_LABEL/services_pod-exposer"
done
