#vpc
aws_region                         = "us-east-1"
vpc_cidr_range                     = "10.0.0.0/16"
private_subnet_cidr_range          = ["10.0.0.0/24", "10.0.1.0/24"]
private_data_subnet_cidr_range     = ["10.0.2.0/24"]
public_subnet_cidr_range           = ["10.0.3.0/24", "10.0.4.0/24"]
anyware_cidr_range                 = "0.0.0.0/0"
cert_arn                           = "arn:aws:acm:us-east-1:735911875499:certificate/d416be11-bd15-404e-8bf5-a73a8b8e6e10"


#bastion
bastion_host_instances_count       = 1
ami_bastion                        = "ami-0b576fe1af4d01afa"
instance_type_bastion              = "t3.medium"
ebs_type_bastion                   = "gp2"
ebs_size_bastion                   = "20"
key_name_bastion                   = "opsschool-project"
bastion_cidr_range                 = "0.0.0.0/0"


#eks
#cluster_name                      = "opsschool-eks-diana"
eks_version                        = "1.26"
eks_cidr_range                     = "0.0.0.0/0"
key_name_eks                       = "opsschool-project"
kube_config                        = "C:\\Users\\Diana Cohen\\.kube\\config"


#rds
rds_instances_count                = 1


#ansible
ami_ansible_server_ubuntu          = "ami-0e35c37e186647818"
instance_type_ansible_servers      = "t2.medium"
servers_count_ansible              = 1
key_name_ansible                   = "opsschool-project"
ansible_cidr_range                 = "0.0.0.0/0"
ebs_type_ansible_server            = "gp2"
ebs_size_ansible_server            = "10"


#jenkins
jenkins_server_instances_count     = 1
#ami_jenkins_server                 = "ami-0261755bbcb8c4a84"
ami_jenkins_server                 = "ami-01ab53bd7cf695ff8"
instance_type_jenkins_server       = "t2.medium"
ebs_type_jenkins_server            = "gp2"
ebs_size_jenkins_server            = "20"
cidr_range_jenkins_server          = "0.0.0.0/0"
key_name_jenkins                   = "opsschool-project"
instances_count_jenkins_agent      = 2
ami_jenkins_agent                  = "ami-0261755bbcb8c4a84"
instance_type_jenkins_agent        = "t2.medium"
ebs_type_jenkins_agent             = "gp2"
ebs_size_jenkins_agent             = "20"
cidr_range_jenkins_agent           = "0.0.0.0/0"


#consul
consul_instances_count             = 3
ami_consul_servers                 = "ami-053b0d53c279acc90"
instance_type_consul_servers       = "t2.small"
consul_version                     = "1.15.2"
key_name_consul                    = "opsschool-project"
consul_cidr_range                  = "0.0.0.0/0"
ebs_type_consul_server             = "gp2"
ebs_size_consul_server             = "10"


#openvpn
eip_openvpn                        = "eipalloc-09c9e05f89c8af93c"
ami_openvpn                        = "ami-0f453bfa60505cf62"
instance_type_openvpn              = "t2.small"
key_name_openvpn                   = "opsschool-project"
openvpn_cidr_range                 = "0.0.0.0/0"
openvpn_cidr_ip                    = "3.210.152.77/32"


#logging
logging_instances_count            = 1
ami_logging                        = "ami-053b0d53c279acc90"
#ami_logging                        = "ami-0ce5f84e05dea55b7"
instance_type_logging              = "t2.medium"
ebs_type_logging                   = "gp2"
ebs_size_logging                   = "20"
key_name_logging                   = "opsschool-project"
logging_cidr_range                 = "0.0.0.0/0"
logging_ipv6_cidr_range            = "::/0"
