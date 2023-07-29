#For windows files
locals {
  module_path            = "${replace(path.module, "\\", "/")}"
#  jenkins_default_name   = "opsschool-project-jenkins"
  workstation-external-cidr  = "${chomp(data.http.workstation-external-ip.response_body)}/32"
}


#Retrieve my public ip address
data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

#Create security group jenkins
resource "aws_security_group" "jenkins_sg" {
  name          = "opsschool-project-jenkins-sg"
  description   = "Allow Jenkins inbound traffic"
  vpc_id        = var.vpc_id

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    security_groups  = [var.alb_sg]
  }
  
  ingress {
    description      = "https access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [var.alb_sg]
  }

  ingress {
    description      = "http access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    security_groups  = [var.alb_sg]
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
    description      = "Allow all outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.cidr_range_jenkins_server]
  }

  tags = {
  #  Name = "opsschool-project-${local.jenkins_default_name}-sg"
    Name = "opsschool-project-jenkins-sg"
  }
}



#Create jenkins server
resource "aws_instance" "jenkins_server" {
  count                    = var.jenkins_server_instances_count
  ami                      = var.ami_jenkins_server
  instance_type            = var.instance_type_jenkins_server
  subnet_id                = var.private_subnet_id[0]
  key_name                 = var.key_name_jenkins
  vpc_security_group_ids   = [var.bastion_ssh_from_security_group_id, aws_security_group.jenkins_sg.id]
  iam_instance_profile     = aws_iam_instance_profile.jenkins_server_ec2_profile.name
  
  user_data                = "${file("${local.module_path}/scripts/jenkins-server-user-data.sh")}"

  root_block_device {
    volume_type = var.ebs_type_jenkins_server
    volume_size = var.ebs_size_jenkins_server
  #  tags = {
  #    Name = "opschool-project-jenkins-server-ebs"
  #  }    
  }

  tags = {
    Name       = "os-project-jenkins-server-${count.index}"
    OSType     = "ubuntu"
    Consul     = "agent"
    Jenkins    = "server"
    Monitoring = "node_exporter"
    Logging    = "filebeat"
  }
}


# IAM policy for jenkins
resource "aws_iam_policy" "jenkins_server" {
  name   = "opsschool-project-jenkins-server"
  policy =  "${file("${local.module_path}/scripts/jenkins-server-policy.json")}"
}

# Attach the policy
resource "aws_iam_policy_attachment" "jenkins_server_policy_attach" {
  name       = "opsschool-project-jenkins-server-policy-attach"
  roles      = [aws_iam_role.jenkins_server.name]
  policy_arn = aws_iam_policy.jenkins_server.arn
}

#Create iam role for describe ec2
resource "aws_iam_role" "jenkins_server" {
  name               = "opsschool-project-jenkins-server"
  assume_role_policy = "${file("${local.module_path}/scripts/jenkins-server-assume-role.json")}"
}

#Pass the role information to an EC2 instance
resource "aws_iam_instance_profile" "jenkins_server_ec2_profile" {
  name = "opsschool-project-jenkins-server"
  role = aws_iam_role.jenkins_server.name
}


#Create jenkins agent
resource "aws_instance" "jenkins_agent" {
  count                    = var.instances_count_jenkins_agent
  ami                      = var.ami_jenkins_agent
  instance_type            = var.instance_type_jenkins_agent
  subnet_id                = var.private_subnet_id[count.index % 2]
  key_name                 = var.key_name_jenkins
  vpc_security_group_ids   = [var.bastion_ssh_from_security_group_id, aws_security_group.jenkins_sg.id]
  iam_instance_profile     = aws_iam_instance_profile.jenkins_agent_ec2_profile.name

  user_data                = "${file("${local.module_path}/scripts/jenkins-agent-user-data.sh")}"
  
  root_block_device {
    volume_type = var.ebs_type_jenkins_agent
    volume_size = var.ebs_size_jenkins_agent
  #  tags = {
  #    Name = "opschool-project-jenkins-agent-ebs-${count.index}"
  #  }    
  } 

  tags = {
    Name       = "os-project-jenkins-agent-${count.index}"
    OSType     = "ubuntu"
    Consul     = "agent"
    Jenkins    = "agent"
    Stop       = "22:00"
    Monitoring = "node_exporter"
    Logging    = "filebeat"
  }
}


# IAM policy for jenkins
resource "aws_iam_policy" "jenkins_agent" {
  name   = "opsschool-project-jenkins-agent"
  policy =  "${file("${local.module_path}/scripts/jenkins-agent-policy.json")}"
}

# Attach the policy
resource "aws_iam_policy_attachment" "jenkins_agent_policy_attach" {
  name       = "opsschool-project-jenkins-agent-policy-attach"
  roles      = [aws_iam_role.jenkins_agent.name]
  policy_arn = aws_iam_policy.jenkins_agent.arn
}

#Create iam role for describe ec2
resource "aws_iam_role" "jenkins_agent" {
  name               = "opsschool-project-jenkins-agent"
  assume_role_policy = "${file("${local.module_path}/scripts/jenkins-agent-assume-role.json")}"
}

#Pass the role information to an EC2 instance
resource "aws_iam_instance_profile" "jenkins_agent_ec2_profile" {
  name = "opsschool-project-jenkins-agent"
  role = aws_iam_role.jenkins_agent.name
}