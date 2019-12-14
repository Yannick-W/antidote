#!/bin/bash

### ---
### This script deletes a deployment with name $1 from the kubernetes cluster.
### It also deletes all local deployment files, namely the directory resources/deployments/$1
###
### Note that all persistent volumes are NOT deleted by this script, they have to be removed manually.
### Also, if you delete a deployment with name x and create a new deployment with name x, all
###	persistent volumes, that still exist from before, are reclaimed by the antidote pods/instances
### of the new deployment, if they have the same name. That they have as the pods are named x-0, x-1, ...
### for every deployment. Kubernetes will simply assume, that they restarted.
### ---

APP_LABEL=$1

TERMINATION_GRACE_PERIODS_SECONDS=$(kubectl get statefulset -l app=$APP_LABEL -l type=antidote-deployment -o yaml | awk '$1 == "terminationGracePeriodSeconds:" { print $2; exit }')

echo "Deleting data center "$APP_LABEL"... Termination grace period is "$TERMINATION_GRACE_PERIODS_SECONDS" seconds."
kubectl delete statefulset,services,pvc,job -l app=$APP_LABEL
echo Done.

echo "Deleting local files..."
bash scripts/clearLocalDeployment.sh $APP_LABEL
echo Done.
