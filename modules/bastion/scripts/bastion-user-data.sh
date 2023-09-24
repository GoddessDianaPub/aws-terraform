#!/bin/bash

# Install necessary packages
sudo yum update -y
sudo yum install -y gcc openssl-devel libffi-devel python3 python3-devel

# Install EC2 Instance Connect
sudo yum install -y ec2-instance-connect

# Install AWS CLI version 2
sudo yum install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
<<<<<<< HEAD

=======
 
>>>>>>> c6a3e08f36ddd465fc6d02c8807e20c5ed830db6
# Install SSH server
sudo yum install -y openssh-server

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
file="opsschool.pem"

mkdir -p "/home/${user}/.ssh"
touch "/home/${user}/.ssh/${file}"
chmod 0400 "/home/${user}/.ssh/${file}"
chown "${user}:${user}" "/home/${user}/.ssh/${file}"


