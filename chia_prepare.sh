#!/bin/bash
current_blockchain=chia
current_directory=$(pwd)
current_user_home=$HOME

printf " * $current_blockchain PREPARE SCRIPT"

if [[ $EUID -eq 0 ]]; then
  echo "ERROR: This script must NOT be run as root. Please re-run as user!" 1>&2
  exit 1
fi

sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.7 unzip

curl ipinfo.io

# Usefull of u want to change the VM time to your localtime
#sudo rm -rf /etc/localtime
#sudo ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
#date

curl "https://rclone.org/install.sh" | sudo bash

cd $current_user_home
git clone "https://github.com/Chia-Network/chia-blockchain.git" &>/dev/null
cd $current_user_home/$current_blockchain-blockchain
sh install.sh
cd $current_user_home/$current_blockchain-blockchain
chmod +x $current_user_home/$current_blockchain-blockchain/activate
$current_user_home/$current_blockchain-blockchain/activate
sudo ln -s $current_user_home/$current_blockchain-blockchain/venv/bin/$current_blockchain /usr/bin/$current_blockchain
sudo ln -s $current_user_home/$current_blockchain-blockchain/venv/bin/$current_blockchain_harvester /usr/bin/$current_blockchain_harvester
echo ""
echo "INFO: $current_blockchain CLI installed is complete!"
$current_blockchain keys add
echo "INFO: Please proceed to add plot_folder and farmer_peer in the $current_blockchain_start.sh"
