#!/bin/bash
APP_LABEL=$1;

REPLICAS=$(kubectl get statefulset -l app=$APP_LABEL -o yaml | awk '$1 == "replicas:" { print $2; exit; }')
CURRENT_REPLICAS=$(kubectl get statefulset -l app=$APP_LABEL -o yaml | awk '$1 == "currentReplicas:" { print $2; exit; }')
READY_REPLICAS=$(kubectl get statefulset -l app=$APP_LABEL -o yaml | awk '$1 == "readyReplicas:" { print $2; exit; }')

if [ -z $REPLICAS ] || [ -z $CURRENT_REPLICAS ] || [ -z $READY_REPLICAS ]
	then
		echo -1
		exit;
fi

if [ $CURRENT_REPLICAS -eq $REPLICAS ]
	then
		if [ $READY_REPLICAS -eq $REPLICAS ]
			then
				echo 0
				exit;
		fi
fi

echo -1
exit;