#vpc variables:
variable "aws_region" {}

variable "vpc_cidr_range" {}

variable "public_subnet_cidr_range" {}

variable "private_subnet_cidr_range" {}

variable "private_data_subnet_cidr_range" {}

variable "anyware_cidr_range" {}

variable "cert_arn" {}


#bastion variables
variable "ami_bastion" {}

variable "instance_type_bastion" {}

variable "ebs_type_bastion" {}

variable "ebs_size_bastion" {}

variable "key_name_bastion" {}

variable "bastion_cidr_range" {}

variable "bastion_host_instances_count" {}


#eks variables
variable "eks_cidr_range" {}

variable "eks_consul_cidr_range" {}

variable "eks_version" {}

variable "key_name_eks" {}

<<<<<<< HEAD
variable "eks_consul_cidr_range" {}

=======
>>>>>>> c6a3e08f36ddd465fc6d02c8807e20c5ed830db6

#rds variables
variable "rds_instances_count" {}


#ansible variables:
variable "key_name_ansible" {}

variable "ami_ansible_server_ubuntu" {}

variable "instance_type_ansible_servers" {}

variable "servers_count_ansible" {}

variable "ansible_cidr_range" {}

variable "ebs_type_ansible_server" {}

variable "ebs_size_ansible_server" {}



#alb



#jenkins variables:
variable "key_name_jenkins" {}

variable "jenkins_server_instances_count" {}

variable "ami_jenkins_server" {}

variable "instance_type_jenkins_server" {}

variable "ebs_type_jenkins_server" {}

variable "ebs_size_jenkins_server" {}

variable "cidr_range_jenkins_server" {}

variable "instances_count_jenkins_agent" {}

variable "ami_jenkins_agent" {}

variable "instance_type_jenkins_agent" {}

variable "ebs_type_jenkins_agent" {}

variable "ebs_size_jenkins_agent" {}

variable "cidr_range_jenkins_agent" {}


#consul variables:
variable "ami_consul_servers" {}

variable "consul_version" {}

variable "consul_instances_count" {}

variable "key_name_consul" {}

variable "consul_cidr_range" {}

variable "ebs_type_consul_server" {}

variable "ebs_size_consul_server" {}

variable "instance_type_consul_servers" {}


#openvpn variables
variable "ami_openvpn" {}

variable "instance_type_openvpn" {}

variable "key_name_openvpn" {}

variable "openvpn_cidr_range" {}

variable "openvpn_cidr_ip" {}

variable "eip_openvpn" {}



#logging variables
variable "ami_logging" {}

variable "instance_type_logging" {}

variable "key_name_logging" {}

variable "logging_cidr_range" {}

variable "logging_ipv6_cidr_range" {}

variable "ebs_type_logging" {}

variable "ebs_size_logging" {}

variable "logging_instances_count" {}
