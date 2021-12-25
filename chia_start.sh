#!/bin/bash
current_blockchain=chia
current_directory=$(pwd)
current_user_home=$HOME

printf " * $current_blockchain START SCRIPT"

if [[ $EUID -eq 0 ]]; then
  echo "ERROR: This script must NOT be run as root. Please re-run as user!" 1>&2
  exit 1
fi

mkdir -p ./config_ssl_ca
FILE=./config_ssl_ca/$current_blockchain_ca.crt
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "ERROR: $FILE does not exist. Please copy your local PC .$current-blockchain/config/ssl/ca/ to this VM ./config_ssl_ca and re-run this script!"
	exit 1
fi

FILE=./rclone.conf
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "ERROR: $FILE does not exist. Please check and re-run this script!"
	exit 1
fi

# If free space is less than 10G, clean rclone VFS cache
local_disk_free_threshold=10
# Location of plots on your Google Shared Drive
plot_folder=
# IP Address / DDNS Name of your local PC
farmer_peer=
# change if needed for other forks
farmer_peer_port=8447
vfs_cache_dir=$current_user_home/vfs_cache_dir
local_mnt_dir=$current_user_home/mnt/gdrive_$current_blockchain
cloud_mnt_dir=gdrive_$current_blockchain:


if [ -z "$plot_folder" ]
then
    echo "ERROR: \$plot_folder is empty. Add plot_folder value to this script and re-run! plot_folder is the location of your plot on Google Shared Drive"
	exit 1
fi

if [ -z "$farmer_peer" ]
then
    echo "ERROR: \$farmer_peer is empty. Add farmer_peer value to this script and re-run! farmer_peer is the IP Address/ DDNS Name of your local PC"
	exit 1
fi


#cd to home directory
cd $current_user_home
$current_blockchain stop all
rm ./.$current_blockchain/mainnet/log/debug.log
rm -r ./.$current_blockchain/mainnet/config

#Clean VFS cache
mkdir -p $vfs_cache_dir
current_local_disk_free=$(expr $(df -k $vfs_cache_dir | tail -1 | awk '{print $4}') / 1000 / 1000)
printf "INFO: $vfs_cache_dir space is ${current_local_disk_free}G\n"
if [ "$current_local_disk_free" -le $local_disk_free_threshold ]
then
	printf "INFO: Require at least ${local_disk_free_threshold}G. Cleaning VFS cache...\n"
	rm -r $vfs_cache_dir
fi



#Rclone Mount $current_blockchain
echo "INFO: Mounting Rclone $cloud_mnt_dir at $local_mnt_dir ..."
rm ./mount_$current_blockchain.log
fusermount -uz $local_mnt_dir
rm -r $local_mnt_dir
mkdir -p $local_mnt_dir
rclone --config=./rclone.conf mount $cloud_mnt_dir $local_mnt_dir --cache-dir $vfs_cache_dir/current-$current_blockchain --vfs-cache-max-size 200G --vfs-cache-max-age 240000h --async-read=true --vfs-cache-mode full --buffer-size 0K --vfs-read-chunk-size 64K  --vfs-read-chunk-size-limit off --vfs-read-wait 20ms --read-only --log-level INFO --log-file ./mount_gdrive_$current_blockchain.log &>/dev/null &

#Init $current_blockchain
$current_blockchain init
$current_blockchain init -c ./config_ssl_ca
#$current_blockchain keys add
$current_blockchain configure --set-farmer-peer $farmer_peer:$farmer_peer_port
#sudo sed -i 's/localhost/127.0.0.1/g' ./.$current_blockchain/mainnet/config/config.yaml

$current_blockchain plots add -d $local_mnt_dir/$plot_folder
$current_blockchain start harvester &

#Caching VFS progress
mkdir -p $local_mnt_dir/$plot_folder
mkdir -p $vfs_cache_dir/current-$current_blockchain/vfs/gdrive_$current_blockchain/$plot_folder
while :
do
	current_plot_count=$(find ./mnt/gdrive_$current_blockchain/$plot_folder | wc -l)
	current_vfscache_count=$(find ./vfs_cache_dir/current-$current_blockchain/vfs/gdrive_$current_blockchain/$plot_folder | wc -l)
	printf "Caching VFS gdrive_$current_blockchain $current_vfscache_count/$current_plot_count ...		\\r"
	if [ "$current_vfscache_count" -ge "$current_plot_count" ]; then
		break
	fi
	sleep 10
done
echo ""
echo "INFO: Sleeping for 60 seconds..."
sleep 30
$current_blockchain stop all
sleep 30
$current_blockchain start harvester

cd $current_directory
./$current_blockchain_monitor.sh




