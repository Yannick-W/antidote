#!/bin/bash

TEMPLATES_DIR=$(bash getConfig.sh templates_dir);

kubectl apply -f $TEMPLATES_DIR/storageclass_local-storage-template.yaml