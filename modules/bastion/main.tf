#For windows files
locals {
  module_path                = "${replace(path.module, "\\", "/")}"
  workstation-external-cidr  = "${chomp(data.http.workstation-external-ip.response_body)}/32"
}


#Retrieve my public ip address
data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}


# Allocate elastic ip. this eip will be used for the bastion host in the public subnet
resource "aws_eip" "eip_bastion" {
  domain = "vpc"

  tags   = {
    Name = "opsschool-project-bastion-EIP"
  }
}

resource "aws_eip_association" "bastion" {
  instance_id           = aws_instance.bastion.id
#  network_interface_id  = aws_network_interface.bastion.id
  allocation_id         = aws_eip.eip_bastion.id

  lifecycle {
    ignore_changes = [network_interface_id]
  }
}

# Create bastion host
resource "aws_instance" "bastion" {
  ami                           = var.ami_bastion
  instance_type                 = var.instance_type_bastion
  key_name                      = var.key_name_bastion
  subnet_id                     = var.public_subnet_id[0]
  vpc_security_group_ids        = [aws_security_group.allow_ssh_to_bastion_sg.id]
  associate_public_ip_address   = true
  iam_instance_profile          = aws_iam_instance_profile.bastion_ec2_profile.name

  user_data                     = "${file("${local.module_path}/scripts/bastion-user-data.sh")}"

  tags = {
    Name       = "os-project-bastion"
    OSType     = "amazon"
    Bastion    = "server"
    Consul     = "agent_"
    Monitoring = "node_exporter_"
    Logging    = "filebeat_"
  }
}


# Create security group for ssh connection for bastion host
resource "aws_security_group" "allow_ssh_to_bastion_sg" {
  name = "opsschhol-project-allow-ssh-to-bastion-sg"
  vpc_id = var.vpc_id

  ingress {
    description   = "ssh access"
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks   = [local.workstation-external-cidr]
  }

  ingress {
    description   = "ansible ssh access"
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks   = ["10.0.2.17/32"]
  }

  egress {
    description   = "ssh access"
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks   = [var.vpc_cidr_range]
  }

  egress {
    description   = "http access"
    from_port     = 80
    to_port       = 80
    protocol      = "tcp"
    cidr_blocks   = [local.workstation-external-cidr]
  }

  egress {
    description   = "https access"
    from_port     = 443
    to_port       = 443
    protocol      = "tcp"
    cidr_blocks   = [local.workstation-external-cidr]
  }

  egress {
    description   = "postgres access"
    from_port     = 5432
    to_port       = 5432
    protocol      = "tcp"
    cidr_blocks   = [var.bastion_cidr_range]
  }
  
  tags   = {
    Name = "opsschool-project-ssh-to-bastion-SG"
  }
}

# Creates SSH traffic from a bastion host located in a public subnet to the hosts in a private subnet
# Should be applied to hosts in the private subnet
resource "aws_security_group" "allow_ssh_from_bastion_sg" {
  name = "opsschhol-project-allow-ssh-from-bastion-sg"
  vpc_id = var.vpc_id

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.allow_ssh_to_bastion_sg.id]
  }

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]
  }

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.openvpn_cidr_ip]
  }
  
  tags   = {
    Name = "opsschool-project-ssh-from-bastion-SG"
  }
}


# IAM policy for bastion
resource "aws_iam_policy" "bastion_policy" {
  name   = "opsschool-project-bastion"
  policy =  "${file("${local.module_path}/scripts/bastion-describe-ec2.json")}"
}

# Attach the policy
resource "aws_iam_policy_attachment" "bastion_policy_attach" {
  name       = "opsschool-project-bastion-policy-attach"
  roles      = [aws_iam_role.bastion_role.name]
  policy_arn = aws_iam_policy.bastion_policy.arn
}

#Create iam role for describe ec2
resource "aws_iam_role" "bastion_role" {
  name               = "opsschool-project-bastion"
  assume_role_policy = "${file("${local.module_path}/scripts/bastion-assume-role.json")}"
}

#Pass the role information to an EC2 instance
resource "aws_iam_instance_profile" "bastion_ec2_profile" {
  name = "opsschool-project-bastion-profile"
  role = aws_iam_role.bastion_role.name
}