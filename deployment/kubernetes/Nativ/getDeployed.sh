#!/bin/bash

###---
### Simply returns all statefulsets that are also labeled as type=antidote-deployments
### from the kubernetes cluster.
###---

kubectl get statefulsets -l type=antidote-deployment