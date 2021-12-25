#!/bin/bash
printf " * RCLONE UPLOAD SCRIPT"
if [[ $EUID -eq 0 ]]; then
  echo "ERROR: This script must NOT be run as root. Please re-run as user!" 1>&2
  exit 1
fi

FILE=./rclone.conf
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "ERROR: $FILE does not exist. Please check and re-run this script!"
	exit 1
fi

current_user_home=$HOME
plot_folder=
final_disk=$current_user_home

if [ -z "$plot_folder" ]
then
    echo "ERROR: \$plot_folder is empty. Add plot_folder value to this script and re-run! plot_folder is the location of your plot on Google Shared Drive"
	exit 1
fi

#cd to home directory
cd $current_user_home


while :
do
	for m in "${plot_folder[@]}"
	do
		mkdir -p $final_disk/${m}
		cd $final_disk/${m}
		for f in *.plot 
		do 
			current_hour=$(date +%-k)
			rclone --config=$current_user_home/rclone.conf move $final_disk/${m}/$f gdrive_service$current_hour:${m} -P --drive-chunk-size 512M
		done
	done
	
	echo "INFO: Sleeping for 30 seconds..."
	sleep 30
	clear
done
