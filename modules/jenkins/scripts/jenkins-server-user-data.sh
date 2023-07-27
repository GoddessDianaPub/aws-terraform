#!/bin/bash

#Install updates
apt-get update -y

# Adds all the hosts, disables host key checking
echo "Host *" >> /etc/ssh/ssh_config
echo "  StrictHostKeyChecking no" >> /etc/ssh/ssh_config
echo "  IdentityFile ~/.ssh/opsschool-project.pem" >> /etc/ssh/ssh_config


# Create the .ssh directory
file="opsschool-project.pem"
user="ubuntu"
mkdir -p "/home/${user}/.ssh"
touch "/home/${user}/.ssh/${file}"
chmod 0400 "/home/${user}/.ssh/${file}"
chown "${user}:${user}" "/home/${user}/.ssh/${file}"

