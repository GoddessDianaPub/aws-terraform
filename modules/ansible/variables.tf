variable "vpc_id" {}

variable "aws_region" {}

variable "key_name_ansible" {}

variable "private_subnet_id" {}

variable "vpc_cidr_range" {}

variable "ansible_cidr_range" {}

variable "ami_ansible_server_ubuntu" {}

variable "servers_count_ansible" {}

variable "instance_type_ansible_servers" {}

variable "ebs_type_ansible_server" {}

variable "ebs_size_ansible_server" {}

variable "bastion_ssh_from_security_group_id" {}
