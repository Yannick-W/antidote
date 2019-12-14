#!/bin/bash
config_name=$1
scripts_config_src_dir=$2

if [ -z "$scripts_config_src_dir" ]; then
	scripts_config=scripts.config;
	echo $(awk -v var="$config_name:" '$1 == var { print $2 }' $scripts_config)
	exit;
else
	scripts_config=$scripts_config_src_dir/scripts.config
	echo $scripts_config_src_dir/$(awk -v var="$config_name:" '$1 == var { print $2 }' $scripts_config)
fi

