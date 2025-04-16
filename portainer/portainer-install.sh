#!/bin/bash
### prep server
sudo timedatectl set-timezone Asia/Bangkok
sudo apt update && sudo apt full-upgrade -y --autoremove
sudo apt update && sudo apt upgrade -y
sudo apt install ca-certificates curl


## prep for docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

### install docker
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker n_pumipuntu

sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

## configure files on /etc/apt/apt.conf.d/50unattended-upgrades
#"${distro_id}:${distro_codename}-updates";
#Unattended-Upgrade::AutoFixInterruptedDpkg "true";
#Unattended-Upgrade::Mail "gle@sonoslibra.com";
#Unattended-Upgrade::MailReport "only-on-error";
#Unattended-Upgrade::Remove-Unused-Dependencies "true";
#Unattended-Upgrade::Automatic-Reboot "true";
#Unattended-Upgrade::Automatic-Reboot-Time "04:00";



