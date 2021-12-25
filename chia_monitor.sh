#!/bin/bash
current_blockchain=chia
current_directory=$(pwd)
current_user_home=$HOME

printf " * $current_blockchain MONITOR SCRIPT"

if [[ $EUID -eq 0 ]]; then
  echo "ERROR: This script must NOT be run as root. Please re-run as user!" 1>&2
  exit 1
fi

local_disk_free_threshold=10
vfs_cache_dir=$current_user_home/vfs_cache_dir
while :
do
	
	#neofetch --stdout
	mkdir -p $vfs_cache_dir
	current_local_disk_free=$(expr $(df -k $vfs_cache_dir | tail -1 | awk '{print $4}') / 1000 / 1000)
	echo "INFO: $vfs_cache_dir space is ${current_local_disk_free}G"
	if [ "$current_local_disk_free" -le $local_disk_free_threshold ]
	then
		echo "INFO: Require at least ${local_disk_free_threshold}G. Cleaning VFS cache ..."
		cd $current_directory
		./$current_blockchain_start.sh
		exit
	fi
	printf "\n$current_blockchain VFS CACHE STATUS\n"
	findmnt | grep "gdrive"
	du -h --max-depth=0 $vfs_cache_dir
	printf "\n$current_blockchain FARM SUMMARY\n"
	$current_blockchain farm summary
	printf "\n$current_blockchain DEBUG.LOG WARNING & ERROR\n"
	sudo cat $current_user_home/.$current_blockchain/mainnet/log/debug.log | grep "WARNING" | tail -n 10
	sudo cat $current_user_home/.$current_blockchain/mainnet/log/debug.log | grep "ERROR" | tail -n 10
	
	sleep 60
	clear
done
