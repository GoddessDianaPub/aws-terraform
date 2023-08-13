#vpc
aws_region                         = "us-east-1"
vpc_cidr_range                     = "10.0.0.0/16"
private_subnet_cidr_range          = ["10.0.0.0/24", "10.0.1.0/24"]
private_data_subnet_cidr_range     = ["10.0.2.0/24"]
public_subnet_cidr_range           = ["10.0.3.0/24", "10.0.4.0/24"]
anyware_cidr_range                 = "0.0.0.0/0"
cert_arn                           = "arn:aws:acm:us-east-1:735911875499:certificate/xx"


#bastion
bastion_host_instances_count       = 1
ami_bastion                        = "ami-08a52ddb321b32a8c"
instance_type_bastion              = "t2.medium"
ebs_type_bastion                   = "gp2"
ebs_size_bastion                   = "10"
key_name_bastion                   = "opsschool"
bastion_cidr_range                 = "0.0.0.0/0"


#eks
eks_version                        = "1.26"
eks_cidr_range                     = "0.0.0.0/0"
key_name_eks                       = "opsschool"


#rds
rds_instances_count                = 1


#ansible
key_name_ansible                   = "opsschool"
servers_count_ansible              = 1
ami_ansible_server_ubuntu          = "ami-0261755bbcb8c4a84"
instance_type_ansible_servers      = "t2.medium"
ansible_cidr_range                 = "0.0.0.0/0"
ebs_type_ansible_server            = "gp2"
ebs_size_ansible_server            = "10"


#jenkins
key_name_jenkins                   = "opsschool"
jenkins_server_instances_count     = 1
ami_jenkins_server                 = "ami-0261755bbcb8c4a84"
instance_type_jenkins_server       = "t2.medium"
ebs_type_jenkins_server            = "gp2"
ebs_size_jenkins_server            = "20"
cidr_range_jenkins_server          = "0.0.0.0/0"

instances_count_jenkins_agent      = 2
ami_jenkins_agent                  = "ami-0261755bbcb8c4a84"
instance_type_jenkins_agent        = "t2.medium"
ebs_type_jenkins_agent             = "gp2"
ebs_size_jenkins_agent             = "20"
cidr_range_jenkins_agent           = "0.0.0.0/0"


#consul
key_name_consul                    = "opsschool"
consul_instances_count             = 3
ami_consul_servers                 = "ami-0261755bbcb8c4a84"
instance_type_consul_servers       = "t2.small"
consul_version                     = "1.15.2"
consul_cidr_range                  = "0.0.0.0/0"
ebs_type_consul_server             = "gp2"
ebs_size_consul_server             = "10"


#openvpn
key_name_openvpn                   = "opsschool"
eip_openvpn                        = "eipalloc-xx"
ami_openvpn                        = "ami-0f453bfa60505cf62"
instance_type_openvpn              = "t2.small"
openvpn_cidr_range                 = "0.0.0.0/0"
openvpn_cidr_ip                    = "3.210.152.xx/32"


#logging
key_name_logging                   = "opsschool"
logging_instances_count            = 1
ami_logging                        = "ami-053b0d53c279acc90"
instance_type_logging              = "t2.medium"
ebs_type_logging                   = "gp2"
ebs_size_logging                   = "20"
logging_cidr_range                 = "0.0.0.0/0"
logging_ipv6_cidr_range            = "::/0"
