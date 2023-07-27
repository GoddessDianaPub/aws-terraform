
output "eks_security_group_id" {
   value = aws_security_group.all_worker_mgmt_sg.id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_arn" {
  value = module.eks.cluster_arn
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "iam_role_arn_kandula" {
  value = module.iam_iam-assumable-role-with-oidc-kandula.iam_role_arn
}

output "iam_role_arn_filebeat" {
  value = module.iam_iam-assumable-role-with-oidc-filebeat.iam_role_arn
}

output "cluster_id" {
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  value       = data.aws_eks_cluster.eks.endpoint
}

#output "eks_node_1_private_ips" {
#  value = module.eks.eks_managed_node_groups.os_project_eks_node_1.private_ips
#}