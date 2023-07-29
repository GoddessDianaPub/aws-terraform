#!/bin/bash

sudo apt-get update -y

jenkins_default_name="jenkins"
jenkins_home="/home/ubuntu/jenkins_home"
jenkins_home_mount="${jenkins_home}:/var/jenkins_home"
docker_sock_mount="/var/run/docker.sock:/var/run/docker.sock"
java_opts="JAVA_OPTS=-Djenkins.install.runSetupWizard=false"

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
mkdir -p ${jenkins_home}
sudo chown -R 1000:1000 ${jenkins_home}

sudo docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v ${jenkins_home_mount} -v ${docker_sock_mount} --env ${java_opts} jenkins/jenkins

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


