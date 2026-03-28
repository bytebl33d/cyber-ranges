#!/bin/bash

# Fill in as appropriate
echo "Cleaning apt cache..."
apt -qq -y clean &> /dev/null
rm -rf /var/lib/apt/lists/*

sed -i 's/^#\\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#\\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config