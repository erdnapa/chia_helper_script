# chia_google_shared_drive
Script to farm Chia Blockchain on Google Shared Drive

# save these file to your VM remote_harvester
  chia_prepare.sh :     This will install Rclone & Chia on your VM
  chia_start.sh:        This will start Rclone & Chia Harvester on your VM. Rclone will cache your plots header (VFS Cache)
  chia_monitor.sh:      This script will loop and monitor your VFS Cache usage & Harvester status. If no space left for VFS Cache, it will clean the VFS Cache and restart Chia Harvester.
