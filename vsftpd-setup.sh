#!/bin/bash

set -e

# Define users
FTP_USERS=("ftpuser1" "ftpuser2" "ftpuser3")
FTP_ROOT="/home/ftp_users"
FTP_PASSWORD="ChangeMe123"   # Change this before using in production

# Update and install vsftpd
sudo apt update
sudo apt install -y vsftpd

# Create the FTP root directory
sudo mkdir -p $FTP_ROOT
sudo chmod 755 $FTP_ROOT

# Create each user and their isolated directory
for user in "${FTP_USERS[@]}"; do
  USER_HOME="$FTP_ROOT/$user"
  sudo useradd -m -d "$USER_HOME" -s /usr/sbin/nologin "$user" || true
  echo "$user:$FTP_PASSWORD" | sudo chpasswd

  sudo mkdir -p "$USER_HOME/files"
  sudo chown "$user:$user" "$USER_HOME/files"
  sudo chmod 755 "$USER_HOME"
done

# Backup original config
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

# Create new vsftpd config
cat <<EOF | sudo tee /etc/vsftpd.conf
listen=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
user_sub_token=\$USER
local_root=$FTP_ROOT/\$USER/files
pasv_enable=YES
pasv_min_port=1024
pasv_max_port=1048
userlist_enable=YES
userlist_deny=NO
userlist_file=/etc/vsftpd.userlist
EOF

# Add allowed users
printf "%s\n" "${FTP_USERS[@]}" | sudo tee /etc/vsftpd.userlist

# Restart vsftpd service
sudo systemctl restart vsftpd
sudo systemctl enable vsftpd

# Open passive FTP ports (if using UFW)
if command -v ufw &>/dev/null; then
  sudo ufw allow 20/tcp
  sudo ufw allow 21/tcp
  sudo ufw allow 1024:1048/tcp
fi

echo "✅ FTP setup complete!"
echo "Users and their passwords:"
for user in "${FTP_USERS[@]}"; do
  echo " - $user / $FTP_PASSWORD"
done
