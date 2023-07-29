#!/bin/bash
set -ex

sudo apt-get update -y
sudo apt install python3-pip -y
sudo apt-get install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

sudo apt-get install docker.io git openjdk-11-jdk -y
sudo service docker start
sudo usermod -aG docker ubuntu

# Download and install kubectl
sudo apt-get install -y apt-transport-https gnupg2 curl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

sudo apt-get update -y



#yum update -y
#yum install docker git java-11 -y
#service docker start
#usermod -aG docker ec2-user