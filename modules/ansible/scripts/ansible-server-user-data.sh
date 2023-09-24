#!/bin/bash

#Updates the os software
sudo apt-get update -y

#Install ansible
sudo apt-get install python3-pip -y
sudo python3 -m pip install --user ansible

#Instal aws-cli version 2
sudo apt-get install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

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