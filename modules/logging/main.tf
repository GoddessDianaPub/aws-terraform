#For windows files
locals {
  module_path                = "${replace(path.module, "\\", "/")}"
  workstation-external-cidr  = "${chomp(data.http.workstation-external-ip.response_body)}/32"
}


#Retrieve my public ip address
data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

# Create logging instance
resource "aws_instance" "logging" {
  count                         = var.logging_instances_count
  ami                           = var.ami_logging
  instance_type                 = var.instance_type_logging
  key_name                      = var.key_name_logging
  subnet_id                     = var.private_subnet_id[1]
  vpc_security_group_ids        = [var.bastion_ssh_from_security_group_id, aws_security_group.logging_sg.id]
  associate_public_ip_address   = false
  iam_instance_profile          = aws_iam_instance_profile.logging_ec2_profile.name
  user_data                     = "${file("${local.module_path}/scripts/logging-userdata.sh")}"

  root_block_device {
    volume_type = var.ebs_type_logging
    volume_size = var.ebs_size_logging
    tags = {
      Name = "opschool-project-logging-ebs"
    }    
  }
 
  tags = {
    Name       = "os-project-logging"
    OSType     = "ubuntu"
    Service    = "logging"
    Consul     = "agent"
    Stop       = "false"
    Monitoring = "node_exporter"
  }
}


# Create security group for logging instance 
resource "aws_security_group" "logging_sg" {
  name = "opsschhol-project-logging-sg"
  vpc_id = var.vpc_id

  ingress {
    description        = "http access"
    from_port          = 80
    to_port            = 80
    protocol           = "TCP"
    security_groups    = [var.alb_sg]
  }
  
  ingress {
    description        = "https access"
    from_port          = 443
    to_port            = 443
    protocol           = "tcp"
    security_groups    = [var.alb_sg] 
  }
  
  ingress {
    description        = "Kibana UI"
    from_port          = 5601
    to_port            = 5601
    protocol           = "TCP"
    security_groups    = [var.alb_sg]
  }

  ingress {
    description        = "Elasticsearch Java interface"
    from_port          = 9300
    to_port            = 9300
    protocol           = "TCP"
    cidr_blocks        = [var.vpc_cidr_range] 
  }
  
  ingress {
    description        = "Elasticsearch REST interface"
    from_port          = 9200
    to_port            = 9200
    protocol           = "TCP"
    cidr_blocks        = [var.vpc_cidr_range] 
  }

  ingress {
    description        = "Filebeat access"
    from_port          = 5044
    to_port            = 5044
    protocol           = "TCP"
    cidr_blocks        = [var.vpc_cidr_range]
  }

  ingress {
    description        = "Allow consul self access"
    from_port          = 8300
    to_port            = 8301
    protocol           = "tcp"
    cidr_blocks        = [var.vpc_cidr_range]   
  }

  ingress {
    description        = "Allow node_exporter access"
    from_port          = 9100
    to_port            = 9100
    protocol           = "tcp"
    cidr_blocks        = [var.vpc_cidr_range]   
  }

  egress {
    description        = "Allow all ipv4 access"
    from_port          = 0
    to_port            = 0
    protocol           = "-1"
    cidr_blocks        = [var.logging_cidr_range]
  }

  egress {
    description        = "Allow all ipv6 access"
    from_port          = 0
    to_port            = 0
    protocol           = "-1"
    ipv6_cidr_blocks   = [var.logging_ipv6_cidr_range]
  }
  
  tags   = {
    Name = "opsschool-project-logging-SG"
  }
}


# IAM policy for logging
resource "aws_iam_policy" "logging_policy" {
  name   = "opsschool-project-logging"
  policy =  "${file("${local.module_path}/scripts/logging-describe-ec2.json")}"
}

# Attach the policy
resource "aws_iam_policy_attachment" "logging_policy_attach" {
  name       = "opsschool-project-logging-policy-attach"
  roles      = [aws_iam_role.logging_role.name]
  policy_arn = aws_iam_policy.logging_policy.arn
}

#Create iam role for describe ec2
resource "aws_iam_role" "logging_role" {
  name               = "opsschool-project-logging"
  assume_role_policy = "${file("${local.module_path}/scripts/logging-assume-role.json")}"
}

#Pass the role information to an EC2 instance
resource "aws_iam_instance_profile" "logging_ec2_profile" {
  name = "opsschool-project-logging-profile"
  role = aws_iam_role.logging_role.name
}