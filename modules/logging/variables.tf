variable "vpc_id" {}

variable "vpc_cidr_range" {}

variable "logging_cidr_range" {}

variable "logging_ipv6_cidr_range" {}

variable "ami_logging" {}

variable "instance_type_logging" {}

variable "private_subnet_id" {}

variable "key_name_logging" {}

variable "ebs_type_logging" {}

variable "ebs_size_logging" {}

variable "logging_instances_count" {}

variable "alb_sg" {}

variable "bastion_ssh_from_security_group_id" {}