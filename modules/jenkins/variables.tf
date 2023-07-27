variable "vpc_id" {}

variable "vpc_cidr_range" {}

variable "jenkins_server_instances_count" {}

variable "public_subnet_id" {}

variable "cidr_range_jenkins_server" {}

variable "key_name_jenkins" {}

variable "private_subnet_id" {}

variable "bastion_ssh_from_security_group_id" {}

variable "ami_jenkins_server" {}

variable "instance_type_jenkins_server" {}

variable "ebs_type_jenkins_server" {}

variable "ebs_size_jenkins_server" {}

variable "instances_count_jenkins_agent" {}

variable "ami_jenkins_agent" {}

variable "instance_type_jenkins_agent" {}

variable "ebs_type_jenkins_agent" {}

variable "ebs_size_jenkins_agent" {}

variable "cidr_range_jenkins_agent" {}

variable "cert_arn" {}

variable "alb_sg" {}
