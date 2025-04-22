#!/bin/bash
set -e

USERNAME="idaemon"
PASSWORD="Thaigaing\$3101"

if ! id "$USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    usermod -aG sudo "$USERNAME"
fi

SSHD_CONFIG="/etc/ssh/sshd_config"
cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak"

sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' "$SSHD_CONFIG"
sed -i 's/^#\?UsePAM .*/UsePAM yes/' "$SSHD_CONFIG"

CLOUD_CFG="/etc/ssh/sshd_config.d/60-cloudimg-settings.conf"
if [ -f "$CLOUD_CFG" ]; then
    cp "$CLOUD_CFG" "${CLOUD_CFG}.bak"
    sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' "$CLOUD_CFG"
fi

systemctl restart ssh || service ssh restart