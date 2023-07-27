variable "aws_region" {}

variable "vpc_id" {}

variable "vpc_cidr_range" {}

variable "consul_cidr_range" {}

variable "consul_instances_count" {}

variable "private_subnet_id" {}

variable "consul_version" {}

variable "ami_consul_servers" {}

variable "ebs_type_consul_server" {}

variable "ebs_size_consul_server" {}

variable "instance_type_consul_servers" {}

variable "key_name_consul" {}

variable "alb_sg" {}

variable "bastion_ssh_from_security_group_id" {}