#For windows files
locals {
  module_path                = "${replace(path.module, "\\", "/")}"
  workstation-external-cidr  = "${chomp(data.http.workstation-external-ip.response_body)}/32"
}


#Retrieve my public ip address
data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}


resource "aws_eip_association" "openvpn" {
  instance_id           = aws_instance.openvpn.id
  allocation_id         = var.eip_openvpn

  lifecycle {
    ignore_changes = [network_interface_id]
  }
}

# Create AWS openvpn
resource "aws_instance" "openvpn" {
  ami                           = var.ami_openvpn
  instance_type                 = var.instance_type_openvpn
  key_name                      = var.key_name_openvpn
  subnet_id                     = var.public_subnet_id[0]
  vpc_security_group_ids        = [var.bastion_ssh_from_security_group_id, aws_security_group.openvpn_sg.id]
  associate_public_ip_address   = true
  iam_instance_profile          = aws_iam_instance_profile.openvpn_ec2_profile.name

#  user_data                     = "${file("${local.module_path}/scripts/openvpn-user-data.sh")}"

  tags = {
    Name       = "os-project-openvpn"
    OSType     = "openvpn"
    Openvpn    = "server"
    Consul     = "agent"
    Stop       = "false"
    Monitoring = "node_exporter"
    Logging    = "filebeat"
  }
}


# Create security group for connection for openvpn
resource "aws_security_group" "openvpn_sg" {
  name = "opsschhol-project-openvpn-sg"
  vpc_id = var.vpc_id
  
  
  ingress {
    description      = "OpenVpn access"
    from_port        = 1194
    to_port          = 1194
    protocol         = "TCP"
    cidr_blocks      = [var.openvpn_cidr_range]
  }

  ingress {
    description      = "OpenVpn access"
    from_port        = 1194
    to_port          = 1194
    protocol         = "UDP"
    cidr_blocks      = [var.openvpn_cidr_range]
  }

  ingress {
    description      = "additional https access"
    from_port        = 943
    to_port          = 943
    protocol         = "TCP"
    cidr_blocks      = [var.openvpn_cidr_range]
  }

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = [var.openvpn_cidr_range]
  }

  ingress {
    description      = "https access"
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    cidr_blocks      = [var.openvpn_cidr_range]
  }

  ingress {
    description      = "Allow consul self access"
    from_port        = 8300
    to_port          = 8301
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]  
  }

  ingress {
    description        = "Allow node_exporter access"
    from_port          = 9100
    to_port            = 9100
    protocol           = "tcp"
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
    description        = "Kibana UI"
    from_port          = 5601
    to_port            = 5601
    protocol           = "TCP"
    cidr_blocks        = [var.vpc_cidr_range]
  }

  egress {
    description      = "Allow all access"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.openvpn_cidr_range]
  }
  
  tags   = {
    Name = "opsschool-project-openvpn-SG"
  }
}


# IAM policy for openvpn
resource "aws_iam_policy" "openvpn_policy" {
  name   = "opsschool-project-openvpn"
  policy =  "${file("${local.module_path}/scripts/openvpn-describe-ec2.json")}"
}

# Attach the policy
resource "aws_iam_policy_attachment" "openvpn_policy_attach" {
  name       = "opsschool-project-openvpn-policy-attach"
  roles      = [aws_iam_role.openvpn_role.name]
  policy_arn = aws_iam_policy.openvpn_policy.arn
}

#Create iam role for describe ec2
resource "aws_iam_role" "openvpn_role" {
  name               = "opsschool-project-openvpn"
  assume_role_policy = "${file("${local.module_path}/scripts/openvpn-assume-role.json")}"
}

#Pass the role information to an EC2 instance
resource "aws_iam_instance_profile" "openvpn_ec2_profile" {
  name = "opsschool-project-openvpn-profile"
  role = aws_iam_role.openvpn_role.name
}