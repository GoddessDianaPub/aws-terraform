variable "cluster_name" {}

variable "vpc_id" {}

variable "vpc_cidr_range" {}

variable "key_name_eks" {}

variable "eks_cidr_range" {}

variable "eks_consul_cidr_range" {}

variable "subnet_ids" {}

variable "eks_version" {}

variable "private_subnet_id" {}

variable "alb_sg" {}

variable "bastion_ssh_from_security_group_id" {}
