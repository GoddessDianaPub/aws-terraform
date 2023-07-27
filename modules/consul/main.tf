#For windows files
locals {
  module_path = "${replace(path.module, "\\", "/")}"
}

#Create security group
resource "aws_security_group" "opsschool_consul_sg" {
  name        = "opsschool-project-consul-sg"
  description = "Allow ssh & consul inbound traffic"
  vpc_id      = var.vpc_id

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
    description      = "Allow consul UI access"
    from_port        = 8500
    to_port          = 8500
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

  ingress {
    description      = "Allow Min + Max ports for Sidecar Proxy"
    from_port        = 21000
    to_port          = 21255
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr_range]   
  }
  
  egress {
    description      = "Allow all outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.consul_cidr_range]
  }

  tags   = {
    Name = "opsschool-project-consul-sg"
  }
}


# Create an IAM role for the auto-join
resource "aws_iam_role" "consul_role" {
  name               = "opsschool-project-consul"
  assume_role_policy = "${file("${local.module_path}/scripts/consul-assume-role.json")}"
}

# Create the policy
resource "aws_iam_policy" "consul_policy" {
  name        = "opsschool-project-consul"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = "${file("${local.module_path}/scripts/consul-describe-instances.json")}"
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul_policy_attach" {
  name       = "opsschool-project-consul-policy-attach"
  roles      = [aws_iam_role.consul_role.name]
  policy_arn = aws_iam_policy.consul_policy.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul_ec2_profile" {
  name  = "opsschool-project-consul-profile"
  role = aws_iam_role.consul_role.name
}


data "template_file" "consul_server" {
  count    = var.consul_instances_count
  template = "${file("${local.module_path}/scripts/consul_servers.sh.tpl")}"

  vars = {
    consul_version = var.consul_version
    config = <<EOF
      "node_name": "opsschool-project-consul-server-${count.index}",
      "server": true,
      "bootstrap_expect": 3,
      "ui_config": {"enabled": true},
      "client_addr": "0.0.0.0"
    EOF
  }
}

#Create consul server instances
resource "aws_instance" "consul_server" {
  count                        = var.consul_instances_count
  ami                          = var.ami_consul_servers
  instance_type                = var.instance_type_consul_servers
  key_name                     = var.key_name_consul
  subnet_id                    = var.private_subnet_id[count.index % 2]
  iam_instance_profile         = aws_iam_instance_profile.consul_ec2_profile.name
  vpc_security_group_ids       = [var.bastion_ssh_from_security_group_id, aws_security_group.opsschool_consul_sg.id]
  user_data                    = element(data.template_file.consul_server.*.rendered, count.index)
  
  root_block_device {
    volume_type = var.ebs_type_consul_server
    volume_size = var.ebs_size_consul_server
  #  tags = {
  #    Name = "opschool-project-consul-server-ebs-${count.index}"
  #  }    
  }

  tags = {
    Name       = "os-project-consul-server-${count.index}"
    OSType     = "ubuntu"
    Consul     = "server"
    Monitoring = "node_exporter"
    Logging    = "filebeat"
  }
}
