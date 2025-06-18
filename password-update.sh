#!/bin/bash

# Declare user/password pairs
declare -A FTP_USERS_PASSWORDS
FTP_USERS_PASSWORDS=(
  ["mblsite1"]="mbldasftp123"
  ["mblsite2"]="mbldasftp123"
  ["mblsite3"]="mbldasftp123"
)

# Update each user's password
for user in "${!FTP_USERS_PASSWORDS[@]}"; do
  echo "$user:${FTP_USERS_PASSWORDS[$user]}" | sudo chpasswd
  echo "✅ Password updated for $user"
done
