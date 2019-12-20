#!/bin/bash

CONFIG="test.txt"

mapfile CONFIG_LINES < $CONFIG

## build nodes string formatted
TEST="";
for node in "${CONFIG_LINES[@]}"
	do
		#echo $node
		TEST=$TEST$node" \n "
		#echo $TEST
done
#TEST=${TEST:1:${#TEST}}

#var=$( IFS=$'\n'; echo "${CONFIG_LINES[*]}" )
printf -v var "%s" "${CONFIG_LINES[@]}"

echo "$var"

#echo $TEST
#echo "${CONFIG_LINES[@]}"
#echo -v var "%s\n" "${CONFIG_LINES[@]}"