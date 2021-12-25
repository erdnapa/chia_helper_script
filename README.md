# chia_helper_script
Script to help farm Chia Blockchain on Google Shared Drive

# remote_harvester script (only tested on Azure B1S Ubuntu 16.04 VM)
-  chia_prepare.sh

Will install Python 3.7, Rclone & Chia. Pretty basic stuff.
-  chia_start.sh

Will mount Google Shared Drive with Rclone & start Chia Harvester. After Rclone finished cache your plots header (VFS Cache), will restart Chia Harvester once.
-  chia_monitor.sh

Will loop and show VFS Cache usage & Harvester status. If no space left for VFS Cache, it will clean and restart Chia Harvester.

# plot_uploader script
-  rclone_upload.sh

Linux/Ubuntu: Will upload all your plots to Google Shared Drive (required rclone and rclone.conf, all the 24 servicexx.json)
-  rclone_upload_win.bat

Windows: Will upload all your plots to Google Shared Drive (required WinFSP, rclone.exe ,rclone.conf, all the 24 servicexx.json)

# example rclone.conf
-  rclone_example.conf

Usage: rclone --config=rclone_example.conf config

Don't change the name for the rclone profile (gdrive_chia, gdrive_service0,...) because it will break all the scripts.
