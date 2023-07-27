variable "vpc_id" {}

variable "vpc_cidr_range" {}

#variable "anyware_cidr_range" {}

variable "bastion_cidr_range" {}

variable "ami_bastion" {}

variable "instance_type_bastion" {}

variable "ebs_type_bastion" {}

variable "ebs_size_bastion" {}

variable "public_subnet_id" {}

variable "key_name_bastion" {}

variable "openvpn_cidr_ip" {}

#variable "ansible_server_private_address" {}

variable "bastion_host_instances_count" {}
