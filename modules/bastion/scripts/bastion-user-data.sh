#!/bin/bash

# Install necessary packages
yum update -y
yum install -y gcc openssl-devel libffi-devel python3 python3-devel

# Install EC2 Instance Connect
yum install -y ec2-instance-connect

# Install AWS CLI
pip3 install awscli --upgrade

# Install SSH server
yum install -y openssh-server

# Configure SSH server
# Denies root login
echo "PermitRootLogin no" >> /etc/ssh/sshd_config

# Disable password authentication
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

# Adds all the hosts, disables host key checking
echo "Host *" >> /etc/ssh/ssh_config
echo "  StrictHostKeyChecking no" >> /etc/ssh/ssh_config
echo "  IdentityFile ~/.ssh/opsschool-project.pem" >> /etc/ssh/ssh_config


# Create the .ssh directory and copy the SSH key file
user="ec2-user"
file="opsschool-project.pem"

mkdir -p "/home/${user}/.ssh"
touch "/home/${user}/.ssh/${file}"
chmod 0400 "/home/${user}/.ssh/${file}"
chown "${user}:${user}" "/home/${user}/.ssh/${file}"


