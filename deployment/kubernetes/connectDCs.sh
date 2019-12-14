#!/bin/bash

### ---
### ---

DATACENTERS=( "$@" )

## Build string of servers from datacenters to connect; assuming port 8087
for dc in ${DATACENTERS[@]}
	do
		PORT=8087
		IP=$(kubectl get pods -l app=$dc,type=instance -o yaml | awk '$1 == "podIP:" { print $2; exit }')
		NODE=$IP":"$PORT
		ANTIDOTE_NODES_STR=$ANTIDOTE_NODES_STR\,\"$NODE\"
		POSTFIX_ID_STR=$POSTFIX_ID_STR"-"$dc
done
ANTIDOTE_NODES_STR=${ANTIDOTE_NODES_STR:1:${#ANTIDOTE_NODES_STR}}
POSTFIX_ID_STR=${POSTFIX_ID_STR:1:${#POSTFIX_ID_STR}}

## ready check
for dc in ${DATACENTERS[@]}
	do
		if [ $(bash ./scripts/readyProbe.sh $dc) -eq -1 ]; then
			echo Datacenter $dc is not ready! Exiting.
			exit;
		fi
done
echo All servers are ready.

echo Connecting data centers with servers: $ANTIDOTE_NODES_STR
bash scripts/connectDCs_goClient.sh $ANTIDOTE_NODES_STR $POSTFIX_ID_STR

