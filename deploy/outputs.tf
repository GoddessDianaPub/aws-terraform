#eks outputs
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "add_cluster_context" {
  value = "aws eks --region=us-east-1 update-kubeconfig --name ${module.eks.cluster_name}"
}

#output "eks_node_1_private_ips" {
#  value = module.eks.eks_node_1_private_ips
#}


# vpc outputs
output "region" {
   value = var.aws_region
}

output "vpc_id" {
   value = module.vpc.vpc_id
}


#bastion outputs
output "bastion_private_ip" {
  value = module.bastion.bastion_private_ip
}

output "eip_bastion" {
   value = module.bastion.eip_bastion
}

output "workstation-external-ip" {
   value = module.bastion.workstation-external-ip
}


#DB outputs
output "rds_private_endpoint" {
  value = module.rds.rds_private_endpoint
}


#ansible outputs
output "ansible_server_private_address" {
    value = module.ansible.ansible_server_private_address
}



#alb
output "alb_dns_name" {
   value = module.alb.alb_dns_name
}


#jenkins outputs
output "jenkins_agent_private_ip" {
  value = module.jenkins.jenkins_agent_private_ip
}

output "jenkins_server_private_ip" {
  value = module.jenkins.jenkins_server_private_ip
}

output "jenkins_url" {
  value = "http://jenkins.dianatop.lat"
}


#consul outputs
output "consul_servers_private_ip" {
  value = module.consul.consul_servers_private_ip
}

output "consul_url" {
  value = "http://consul.dianatop.lat"
}


#Openvpn outputs
output "eip_openvpn" {
   value = module.openvpn.eip_openvpn
}

output "openvpn_private_ip" {
  value = module.openvpn.openvpn_private_ip
}

output "openvpn_url" {
  value = "http://openvpn.dianatop.lat"
}


#logging outputs
output "logging_private_ip" {
  value = module.logging.logging_private_ip
}

output "kibana_url" {
  value = "http://kibana.dianatop.lat"
}
