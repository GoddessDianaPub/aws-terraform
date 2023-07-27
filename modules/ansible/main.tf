#For windows files
locals {
  module_path = "${replace(path.module, "\\", "/")}"
  workstation-external-cidr  = "${chomp(data.http.workstation-external-ip.response_body)}/32"
}


#Retrieve my public ip address
data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}


#Create ansible security group
resource "aws_security_group" "ansible_sg" {
 name        = "opsschool-project-ansible-sg"
 description = "security group for ansible servers"
 vpc_id      = var.vpc_id
  
  ingress {
   description = "allow testing ping on port 8"
   from_port   = 8
   to_port     = 0
   protocol    = "icmp"
   cidr_blocks = [var.vpc_cidr_range]
 }
  
  egress {
   description  = "Allow all outgoing traffic"
   from_port    = 0
   to_port      = 0
   protocol     = "-1"
   cidr_blocks  = [var.ansible_cidr_range]
 }
  
  tags   = {
    Name = "opsschool-project-ansible-sg"
  }
}


#Install ansible server
resource "aws_instance" "ansible_server" {
  count                        = var.servers_count_ansible
  ami                          = var.ami_ansible_server_ubuntu
  instance_type                = var.instance_type_ansible_servers
  subnet_id                    = var.private_subnet_id[0]
  vpc_security_group_ids       = [var.bastion_ssh_from_security_group_id, aws_security_group.ansible_sg.id]
  key_name                     = var.key_name_ansible
  user_data                    = "${file("${local.module_path}/scripts/ansible-server-user-data.sh")}"
  
  root_block_device {
    volume_type = var.ebs_type_ansible_server
    volume_size = var.ebs_size_ansible_server
    tags = {
      Name = "opschool-project-ansible-server-ebs-${count.index}"
    }    
  }

  tags = {
    Name       = "os-project-ansible-server"
    OSType     = "ubuntu"
    Ansible    = "server"
    Consul     = "agent_"
    Monitoring = "node_exporter_"
    Logging    = "filebeat_"
  }
}

