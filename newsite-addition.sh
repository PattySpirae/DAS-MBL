#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USERNAME="mblsite4" #add new site name here
FTP_ROOT="/home/mbl_ftp"
PASSWORD="mbldasftp!123"

USER_HOME="$FTP_ROOT/$USERNAME"

# Create the user
sudo useradd -m -d "$USER_HOME" -s /usr/sbin/nologin "$USERNAME"
echo "$USERNAME:$PASSWORD" | sudo chpasswd

# Create and set permissions for files dir
sudo mkdir -p "$USER_HOME/files"
sudo chown "$USERNAME:$USERNAME" "$USER_HOME/files"
sudo chmod 755 "$USER_HOME"

# Add to vsftpd userlist if not already there
grep -qxF "$USERNAME" /etc/vsftpd.userlist || echo "$USERNAME" | sudo tee -a /etc/vsftpd.userlist

# Restart vsftpd
sudo systemctl restart vsftpd

echo "✅ User '$USERNAME' added with password '$PASSWORD'"
