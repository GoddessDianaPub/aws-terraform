# Saving the state in a remote s3
terraform {
  backend "s3" {
    bucket   = "my-tf-test-bucket-logs"
    key      = "opsschool-project/terraform.tfstate"
    region   = "us-east-1"
    profile  = "terraform"
  }
}



# Create vpc
module "vpc" {
  source                                 = "../modules/vpc"
  aws_region                             = var.aws_region
  vpc_cidr_range                         = var.vpc_cidr_range
  public_subnet_cidr_range               = var.public_subnet_cidr_range
  private_subnet_cidr_range              = var.private_subnet_cidr_range
  private_data_subnet_cidr_range         = var.private_data_subnet_cidr_range
  anyware_cidr_range                     = var.anyware_cidr_range
}


# Create bastion host
module "bastion" {
  source                                 = "../modules/bastion"
  vpc_id                                 = module.vpc.vpc_id
  public_subnet_id                       = module.vpc.public_subnet_id
  vpc_cidr_range                         = var.vpc_cidr_range
  bastion_host_instances_count           = var.bastion_host_instances_count
  ami_bastion                            = var.ami_bastion
  instance_type_bastion                  = var.instance_type_bastion
  ebs_type_bastion                       = var.ebs_type_bastion
  ebs_size_bastion                       = var.ebs_size_bastion  
  bastion_cidr_range                     = var.bastion_cidr_range
  openvpn_cidr_ip                        = var.openvpn_cidr_ip
  key_name_bastion                       = var.key_name_bastion
}


# Create eks cluster
module "eks" {
  source                                 = "../modules/eks"
  vpc_id                                 = module.vpc.vpc_id
  vpc_cidr_range                         = var.vpc_cidr_range
  eks_consul_cidr_range                  = var.eks_consul_cidr_range
  private_subnet_id                      = module.vpc.private_subnet_id
  eks_version                            = var.eks_version
  subnet_ids                             = var.public_subnet_cidr_range
  key_name_eks                           = var.key_name_eks 
  cluster_name                           = module.vpc.cluster_name
  eks_cidr_range                         = var.eks_cidr_range
  alb_sg                                 = module.alb.alb_sg
  bastion_ssh_from_security_group_id     = module.bastion.bastion_ssh_from_security_group_id 
}


# Create rds instances for DB
module "rds" {
  source                                 = "../modules/rds"
  vpc_id                                 = module.vpc.vpc_id
  rds_instances_count                    = var.rds_instances_count
  private_subnet_id                      = module.vpc.private_subnet_id
  vpc_cidr_range                         = var.vpc_cidr_range
  logging_sg                             = module.logging.logging_sg
  anyware_cidr_range                     = var.anyware_cidr_range
  availability_zones_names               = module.vpc.availability_zones_names
  bastion_ssh_from_security_group_id     = module.bastion.bastion_ssh_from_security_group_id
}


#Create ansible servers and nodes
module "ansible" {
  source                                 = "../modules/ansible"
  vpc_id                                 = module.vpc.vpc_id
  private_subnet_id                      = module.vpc.private_subnet_id
  vpc_cidr_range                         = var.vpc_cidr_range
  aws_region                             = var.aws_region
  key_name_ansible                       = var.key_name_ansible
  ami_ansible_server_ubuntu              = var.ami_ansible_server_ubuntu
  ansible_cidr_range                     = var.ansible_cidr_range
  servers_count_ansible                  = var.servers_count_ansible 
  instance_type_ansible_servers          = var.instance_type_ansible_servers
  ebs_type_ansible_server                = var.ebs_type_ansible_server
  ebs_size_ansible_server                = var.ebs_size_ansible_server
  bastion_ssh_from_security_group_id     = module.bastion.bastion_ssh_from_security_group_id
}


#Create alb
module "alb" {
  source                                 = "../modules/alb/"
  vpc_id                                 = module.vpc.vpc_id
  public_subnet_id                       = module.vpc.public_subnet_id
  private_subnet_id                      = module.vpc.private_subnet_id
  anyware_cidr_range                     = var.anyware_cidr_range
  aws_region                             = var.aws_region
  consul_instances_count                 = var.consul_instances_count
  consul_server_instance_id              = module.consul.consul_server_instance_id
  consul_cidr_range                      = var.consul_cidr_range
  logging_instance_id                    = module.logging.logging_instance_id
  logging_instances_count                = var.logging_instances_count
  logging_cidr_range                     = var.logging_cidr_range
  jenkins_server_instances_count         = var.jenkins_server_instances_count
  jenkins_server_instance_id             = module.jenkins.jenkins_server_instance_id
  eip_openvpn                            = module.openvpn.eip_openvpn
  cert_arn                               = var.cert_arn
}


#Create jenkins instances
module "jenkins" {
  source                                 = "../modules/jenkins/"
  vpc_id                                 = module.vpc.vpc_id
  public_subnet_id                       = module.vpc.public_subnet_id
  private_subnet_id                      = module.vpc.private_subnet_id
  vpc_cidr_range                         = var.vpc_cidr_range
  cidr_range_jenkins_server              = var.cidr_range_jenkins_server  
  key_name_jenkins                       = var.key_name_jenkins
  jenkins_server_instances_count         = var.jenkins_server_instances_count
  ami_jenkins_server                     = var.ami_jenkins_server
  instance_type_jenkins_server           = var.instance_type_jenkins_server
  ebs_type_jenkins_server                = var.ebs_type_jenkins_server
  ebs_size_jenkins_server                = var.ebs_size_jenkins_server
  instances_count_jenkins_agent          = var.instances_count_jenkins_agent
  ami_jenkins_agent                      = var.ami_jenkins_agent
  instance_type_jenkins_agent            = var.instance_type_jenkins_agent
  ebs_type_jenkins_agent                 = var.ebs_type_jenkins_agent
  ebs_size_jenkins_agent                 = var.ebs_size_jenkins_agent
  cidr_range_jenkins_agent               = var.cidr_range_jenkins_agent
  cert_arn                               = var.cert_arn
  alb_sg                                 = module.alb.alb_sg
  bastion_ssh_from_security_group_id     = module.bastion.bastion_ssh_from_security_group_id
}


#Create consul instances
module "consul" {
  source                                 = "../modules/consul/"
  vpc_id                                 = module.vpc.vpc_id
  private_subnet_id                      = module.vpc.private_subnet_id
  vpc_cidr_range                         = var.vpc_cidr_range
  consul_cidr_range                      = var.consul_cidr_range
  alb_sg                                 = module.alb.alb_sg
  consul_version                         = var.consul_version
  ami_consul_servers                     = var.ami_consul_servers
  consul_instances_count                 = var.consul_instances_count
  aws_region                             = var.aws_region
  key_name_consul                        = var.key_name_consul
  instance_type_consul_servers           = var.instance_type_consul_servers
  ebs_type_consul_server                 = var.ebs_type_consul_server
  ebs_size_consul_server                 = var.ebs_size_consul_server
  bastion_ssh_from_security_group_id     = module.bastion.bastion_ssh_from_security_group_id
}


# Create openvpn instance
module "openvpn" {
  source                                 = "../modules/openvpn"
  vpc_id                                 = module.vpc.vpc_id
  vpc_cidr_range                         = var.vpc_cidr_range
  public_subnet_id                       = module.vpc.public_subnet_id
  eip_openvpn                            = var.eip_openvpn
  ami_openvpn                            = var.ami_openvpn
  instance_type_openvpn                  = var.instance_type_openvpn
  openvpn_cidr_range                     = var.openvpn_cidr_range
  key_name_openvpn                       = var.key_name_openvpn
  bastion_ssh_from_security_group_id     = module.bastion.bastion_ssh_from_security_group_id
}


# Create logging instance
module "logging" {
  source                                 = "../modules/logging"
  vpc_id                                 = module.vpc.vpc_id
  vpc_cidr_range                         = var.vpc_cidr_range
  private_subnet_id                      = module.vpc.private_subnet_id
  alb_sg                                 = module.alb.alb_sg
  logging_instances_count                = var.logging_instances_count
  ami_logging                            = var.ami_logging
  logging_cidr_range                     = var.logging_cidr_range
  logging_ipv6_cidr_range                = var.logging_ipv6_cidr_range
  instance_type_logging                  = var.instance_type_logging
  key_name_logging                       = var.key_name_logging
  ebs_type_logging                       = var.ebs_type_logging
  ebs_size_logging                       = var.ebs_size_logging
  bastion_ssh_from_security_group_id     = module.bastion.bastion_ssh_from_security_group_id
}

