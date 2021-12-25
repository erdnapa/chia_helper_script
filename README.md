# chia_google_shared_drive
Script to farm Chia Blockchain on Google Shared Drive

# remote_harvester script
-  chia_prepare.sh

Will install Python 3.7, Rclone & Chia on your Ubuntu 16.04 VM. Pretty basic stuff.
-  chia_start.sh

Will mount Google Shared Drive with Rclone & start Chia Harvester. After Rclone finished cache your plots header (VFS Cache), will restart Chia Harvester once.
-  chia_monitor.sh

Will loop and show VFS Cache usage & Harvester status. If no space left for VFS Cache, it will clean and restart Chia Harvester.

# plot_uploader script
-  rclone_upload.sh

Linux/Ubuntu: Will upload all your plots to Google Shared Drive (required rclone and rclone.conf)
-  rclone_upload_win.bat

Windows: Will upload all your plots to Google Shared Drive (required WinFSP, rclone.exe and rclone.conf)

