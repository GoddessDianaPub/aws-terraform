#For windows files
locals {
  module_path  = "${replace(path.module, "\\", "/")}"
}

# Create iam for kandula-sa
module "iam_iam-assumable-role-with-oidc-kandula" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.20.0"
  create_role                   = true
  role_name                     = "opsschool-project-sa-kandula"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.sa_kandula_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kandula:kandula-sa"]   
}

# IAM policy for sa kandula
resource "aws_iam_policy" "sa_kandula_policy" {
  name   = "opsschool-project-sa-kandula"
  policy =  "${file("${local.module_path}/scripts/sa-kandula-policy.json")}"
}


# Create iam for filebeat sa
module "iam_iam-assumable-role-with-oidc-filebeat" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.20.0"
  create_role                   = true
  role_name                     = "opsschool-project-sa-filebeat"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.sa_filebeat_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:filebeat:filebeat-sa"]   
}


# IAM policy for sa filebeat
resource "aws_iam_policy" "sa_filebeat_policy" {
  name   = "opsschool-project-sa-filebeat"
  policy =  "${file("${local.module_path}/scripts/sa-filebeat-policy.json")}"
}


#Create eks from a public module
module "eks" {
  source                                 = "terraform-aws-modules/eks/aws"
  version                                = "19.15.3"
  vpc_id                                 = var.vpc_id
  cluster_name                           = var.cluster_name
  cluster_version                        = var.eks_version
  subnet_ids                             = [var.private_subnet_id[0], var.private_subnet_id[1]]
  cluster_endpoint_private_access        = true
  cluster_endpoint_public_access         = false
  enable_irsa                            = true
  cluster_additional_security_group_ids  = [aws_security_group.eks_sg.id]
    
  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  eks_managed_node_group_defaults = {
      ami_type                 = "AL2_x86_64"
      instance_types           = ["t3.medium"]
      key_name                 = var.key_name_eks
      vpc_security_group_ids   = [var.bastion_ssh_from_security_group_id, aws_security_group.all_worker_mgmt_sg.id]
  }

  eks_managed_node_groups = {
    
    os_project_eks_node_1 = {
      min_size                 = 2
      max_size                 = 4
      desired_size             = 2
      private_ip               = true
      tags = {
        OSType = "amazon"
      }
    }

#    os_project_eks_node_2 = {
#      min_size                 = 1
#      max_size                 = 4
#      desired_size             = 2
#      instance_types           = ["t3.large"]
#    }   
  }
}


data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
  depends_on = [module.eks.cluster_id]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}


# create worker nodes security group
resource "aws_security_group" "all_worker_mgmt_sg" {
  name               = "opsschool-project-nodes-sg"
  vpc_id             = var.vpc_id

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = [var.vpc_cidr_range]
  }
  
  ingress {
    description      = "https access"
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    cidr_blocks      = [var.vpc_cidr_range]
  }
  
  ingress {
    description      = "Allow ICMP access"
    from_port        = 8
    to_port          = 0
    protocol         = "icmp"
    cidr_blocks      = [var.vpc_cidr_range]   
  }
 
  ingress {
    description      = "Allow consul self access"
    from_port        = 8300
    to_port          = 8302
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]   
  }

  ingress {
    description      = "Allow consul self access"
    from_port        = 8301
    to_port          = 8302
    protocol         = "udp"
    cidr_blocks      = [var.vpc_cidr_range]   
  }

  ingress {
    description      = "Allow consul access"
    from_port        = 8500
    to_port          = 8500
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]   
  }

  ingress {
    description      = "Allow consul access"
    from_port        = 8600
    to_port          = 8600
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]   
  }

  ingress {
    description      = "Allow consul access"
    from_port        = 8600
    to_port          = 8600
    protocol         = "udp"
    cidr_blocks      = [var.vpc_cidr_range]   
  }

  ingress {
    description      = "Allow Min + Max ports for Sidecar Proxy"
    from_port        = 21000
    to_port          = 21255
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]   
  }

  ingress {
    description      = "Allow node_exporter access"
    from_port        = 9100
    to_port          = 9100
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]   
  }

  ingress {
    description      = "Allow python_exporter access"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]   
  }

  ingress {
    description        = "Filebeat access"
    from_port          = 5044
    to_port            = 5044
    protocol           = "TCP"
    cidr_blocks        = [var.vpc_cidr_range]
  }

  ingress {
    description        = "Kibana UI"
    from_port          = 5601
    to_port            = 5601
    protocol           = "TCP"
    cidr_blocks        = [var.vpc_cidr_range]
  }

  ingress {
    description      = "Allow consul self access"
    from_port        = 8300
    to_port          = 8301
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]   
  }
  
  ingress {
    description      = "Allow grafana UI access"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    security_groups  = [var.alb_sg]
  }

  ingress {
    description      = "Allow prometheus UI access"
    from_port        = 9090
    to_port          = 9090
    protocol         = "tcp"
    security_groups  = [var.alb_sg] 
  }
  
  egress {
    description      = "all trafic access"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.eks_cidr_range]
 }
  
  tags   = {
    Name = "opsschool-project-worker-nodes-sg"
  }
}
  
  
# create eks security group
resource "aws_security_group" "eks_sg" {
  name               = "opsschool-project-eks-sg"
  vpc_id             = var.vpc_id
 
  ingress {
    description      = "https access"
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    cidr_blocks      = [var.vpc_cidr_range]
  }

  egress {
    description      = "all trafic access"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.eks_cidr_range]
 }  

  tags   = {
    Name = "opsschool-project-eks-sg"
  }
}

# # Kubernetes provider
# # https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}


# Provides permission to make calls to other AWS services and manage the resources used with the service
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role" "eksClusterRole" {
  name               = "opsschool-project-eksClusterRole"
  description        = "Provides permission to make calls to other AWS services and manage the resources used with the service"
  assume_role_policy = "${file("${local.module_path}/scripts/cluster-role-assume-policy.json")}"
  depends_on         = [module.eks]
}

# IAM policy for eksClusterRole
resource "aws_iam_policy" "eksClusterRole_policy" {
  name        = "opsschool-project-eksClusterRole"
  policy      =  "${file("${local.module_path}/scripts/cluster-role-policy.json")}"
  depends_on  = [module.eks]
}

# Provides an attachment of the default AmazonEKSClusterPolicy policy to the new eksClusterRole role
resource "aws_iam_role_policy_attachment" "eksClusterRole" {
  policy_arn = aws_iam_policy.eksClusterRole_policy.arn
  role       = aws_iam_role.eksClusterRole.name
}


#resource "helm_release" "monitoring" {
#  depends_on       = [module.eks]
#  name             = "prometheus-grafana-monitoring"
#  repository       = "https://prometheus-community.github.io/helm-charts"
#  chart            = "kube-prometheus-stack"
#  namespace        = "monitoring"
#  create_namespace = true
#}


#resource "kubectl_manifest" "nginx_ingress_controller" {
#  depends_on = [module.eks, data.aws_eks_cluster_auth.eks] 
#  yaml_body  = "${file("${local.module_path}/manifests/nginx-ingress-controller-manifests/controller-v1.8.0.yaml")}"
#}